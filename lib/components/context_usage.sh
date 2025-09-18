#!/bin/bash

# ============================================================================
# Claude Code Statusline - Context Usage Component
# ============================================================================
#
# This component monitors Claude Code context window utilization by parsing
# the current session's transcript file and calculating token usage against
# the 200k context limit to predict when /compact will be needed.
#
# Dependencies: core.sh, display.sh
# ============================================================================

# Component data storage
COMPONENT_CONTEXT_USAGE_PERCENTAGE=""
COMPONENT_CONTEXT_USAGE_INPUT_TOKENS=""
COMPONENT_CONTEXT_USAGE_CACHE_CREATION_TOKENS=""
COMPONENT_CONTEXT_USAGE_CACHE_READ_TOKENS=""
COMPONENT_CONTEXT_USAGE_OUTPUT_TOKENS=""
COMPONENT_CONTEXT_USAGE_TOTAL_TOKENS=""
COMPONENT_CONTEXT_USAGE_LIMIT=""

# Constants
CONTEXT_LIMIT=200000

# ============================================================================
# COMPONENT DATA COLLECTION
# ============================================================================

# Get context usage from Claude Code's internal data
# This attempts to access the same data that /context command uses
get_claude_context_usage() {
    # Look for the current session's transcript in the working directory pattern
    local current_dir="$1"
    local claude_projects_dir="$HOME/.claude/projects"

    if [[ -d "$claude_projects_dir" ]]; then
        # For current directory, use exact directory name if we can detect it
        # Try direct pattern matching for known statusline directory
        local transcript_files
        if [[ "$current_dir" == *"statusline"* ]]; then
            # Direct lookup for statusline project - look for the exact directory first
            local statusline_dir
            statusline_dir=$(find "$claude_projects_dir" -name "*statusline*" -type d 2>/dev/null | head -1)
            if [[ -n "$statusline_dir" ]]; then
                transcript_files=$(find "$statusline_dir" -name "*.jsonl" -type f 2>/dev/null)
            fi
        else
            # Convert path to project directory pattern
            local project_pattern
            project_pattern=$(echo "$current_dir" | sed 's|/|-|g' | sed 's|^-||')
            transcript_files=$(find "$claude_projects_dir" -name "*${project_pattern}*" -name "*.jsonl" -type f 2>/dev/null)
        fi

        debug_log "Looking in current_dir: $current_dir" "INFO"

        debug_log "Found transcript files: $transcript_files" "INFO"

        if [[ -n "$transcript_files" ]]; then
            # Get the most recently modified transcript file
            echo "$transcript_files" | xargs ls -t 2>/dev/null | head -1
        fi
    fi
}

# Parse transcript file for latest token usage
parse_transcript_usage() {
    local transcript_file="$1"

    if [[ -f "$transcript_file" ]]; then
        # Read from end of file to find most recent assistant message with usage
        # Using tail and reverse processing for efficiency
        local recent_lines
        recent_lines=$(tail -100 "$transcript_file" 2>/dev/null)

        # Parse JSON lines in reverse order to find latest usage
        echo "$recent_lines" | tac | while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                # Check if this is an assistant message with usage data
                if echo "$line" | grep -q '"type":"assistant"' && echo "$line" | grep -q '"usage"'; then
                    # Extract token usage using jq-like parsing with sed/grep
                    local input_tokens cache_creation_tokens cache_read_tokens output_tokens

                    input_tokens=$(echo "$line" | sed -n 's/.*"input_tokens":\([0-9]*\).*/\1/p' | head -1)
                    cache_creation_tokens=$(echo "$line" | sed -n 's/.*"cache_creation_input_tokens":\([0-9]*\).*/\1/p' | head -1)
                    cache_read_tokens=$(echo "$line" | sed -n 's/.*"cache_read_input_tokens":\([0-9]*\).*/\1/p' | head -1)
                    output_tokens=$(echo "$line" | sed -n 's/.*"output_tokens":\([0-9]*\).*/\1/p' | head -1)

                    # Default to 0 if not found
                    input_tokens=${input_tokens:-0}
                    cache_creation_tokens=${cache_creation_tokens:-0}
                    cache_read_tokens=${cache_read_tokens:-0}
                    output_tokens=${output_tokens:-0}

                    # Calculate total context usage
                    local total_tokens=$((input_tokens + cache_creation_tokens + cache_read_tokens + output_tokens))

                    if [[ $total_tokens -gt 0 ]]; then
                        # Return all 5 values: input:cache_creation:cache_read:output:total
                        echo "${input_tokens}:${cache_creation_tokens}:${cache_read_tokens}:${output_tokens}:${total_tokens}"
                        return 0
                    fi
                fi
            fi
        done
    fi

    echo "0:0:0:0:0"
}

# Estimate context usage from conversation transcript
estimate_context_from_transcript() {
    local transcript_file="$1"
    local total_estimated_tokens=0

    if [[ -f "$transcript_file" ]]; then
        # Read the entire transcript and estimate tokens based on content length
        # Based on /context showing 119k tokens for 1.3M chars: ~11 characters per token
        local total_chars
        total_chars=$(wc -c < "$transcript_file" 2>/dev/null || echo "0")

        debug_log "Transcript file size: $total_chars characters" "INFO"

        # Estimate tokens (adjusted calculation: chars / 11)
        total_estimated_tokens=$((total_chars / 11))

        debug_log "Estimated tokens: $total_estimated_tokens" "INFO"

        # Cap at context limit
        if [[ $total_estimated_tokens -gt $CONTEXT_LIMIT ]]; then
            total_estimated_tokens=$CONTEXT_LIMIT
        fi
    fi

    echo "$total_estimated_tokens"
}

# Collect context usage data
collect_context_usage_data() {
    debug_log "Collecting context_usage component data" "INFO"

    # Initialize defaults
    COMPONENT_CONTEXT_USAGE_PERCENTAGE="0.0"
    COMPONENT_CONTEXT_USAGE_INPUT_TOKENS="0"
    COMPONENT_CONTEXT_USAGE_CACHE_CREATION_TOKENS="0"
    COMPONENT_CONTEXT_USAGE_CACHE_READ_TOKENS="0"
    COMPONENT_CONTEXT_USAGE_OUTPUT_TOKENS="0"
    COMPONENT_CONTEXT_USAGE_TOTAL_TOKENS="0"
    COMPONENT_CONTEXT_USAGE_LIMIT="$CONTEXT_LIMIT"

    # Get current directory for transcript lookup
    local current_dir
    current_dir=$(pwd)

    # Find the transcript file for this session
    local transcript_file
    transcript_file=$(get_claude_context_usage "$current_dir")

    if [[ -n "$transcript_file" && -f "$transcript_file" ]]; then
        debug_log "Found transcript file: $transcript_file" "INFO"

        # Estimate context usage from transcript size and content
        local estimated_tokens
        estimated_tokens=$(estimate_context_from_transcript "$transcript_file")

        if [[ $estimated_tokens -gt 0 ]]; then
            COMPONENT_CONTEXT_USAGE_TOTAL_TOKENS="$estimated_tokens"
            # For display purposes, treat estimated tokens as "input" tokens
            COMPONENT_CONTEXT_USAGE_INPUT_TOKENS="$estimated_tokens"

            # Calculate percentage based on estimated tokens
            COMPONENT_CONTEXT_USAGE_PERCENTAGE=$(echo "scale=1; $estimated_tokens * 100 / $CONTEXT_LIMIT" | bc 2>/dev/null || echo "0.0")
        fi
    else
        debug_log "No transcript file found for current directory: $current_dir" "WARN"
    fi

    debug_log "context_usage data: ${COMPONENT_CONTEXT_USAGE_PERCENTAGE}% (~${COMPONENT_CONTEXT_USAGE_TOTAL_TOKENS} estimated tokens)" "INFO"
    return 0
}

# ============================================================================
# COMPONENT RENDERING
# ============================================================================

# Render context usage display
render_context_usage() {
    local show_context
    show_context=$(get_context_usage_config "enabled" "true")

    # Return empty if disabled
    if [[ "$show_context" != "true" ]]; then
        debug_log "Context usage component disabled" "INFO"
        return 0
    fi

    # Use display.sh formatting function if available
    if type format_context_usage &>/dev/null; then
        format_context_usage "$COMPONENT_CONTEXT_USAGE_PERCENTAGE" \
                           "$COMPONENT_CONTEXT_USAGE_INPUT_TOKENS" \
                           "$COMPONENT_CONTEXT_USAGE_CACHE_CREATION_TOKENS" \
                           "$COMPONENT_CONTEXT_USAGE_CACHE_READ_TOKENS" \
                           "$COMPONENT_CONTEXT_USAGE_OUTPUT_TOKENS" \
                           "$COMPONENT_CONTEXT_USAGE_TOTAL_TOKENS" \
                           "$COMPONENT_CONTEXT_USAGE_LIMIT"
    else
        # Fallback formatting - show only total for now
        local context_color

        # Color based on usage percentage
        local percentage_int
        percentage_int=$(echo "$COMPONENT_CONTEXT_USAGE_PERCENTAGE" | cut -d. -f1)

        if [[ $percentage_int -ge 80 ]]; then
            context_color=$(printf '\033[38;2;255;96;96m')  # Red - needs /compact soon
        elif [[ $percentage_int -ge 60 ]]; then
            context_color=$(printf '\033[38;2;255;165;0m')  # Orange - getting full
        else
            context_color=$(printf '\033[38;2;0;255;0m')    # Green - plenty of space
        fi

        # Format with comma separators for readability
        local formatted_total formatted_limit
        formatted_total=$(printf "%'d" "$COMPONENT_CONTEXT_USAGE_TOTAL_TOKENS" 2>/dev/null || echo "$COMPONENT_CONTEXT_USAGE_TOTAL_TOKENS")
        formatted_limit=$(printf "%'d" "$COMPONENT_CONTEXT_USAGE_LIMIT" 2>/dev/null || echo "$COMPONENT_CONTEXT_USAGE_LIMIT")

        echo "${CONFIG_DIM}🧠${CONFIG_RESET} ${context_color}${COMPONENT_CONTEXT_USAGE_PERCENTAGE}% (${formatted_total}/${formatted_limit})${CONFIG_RESET}"
    fi

    return 0
}

# ============================================================================
# COMPONENT CONFIGURATION
# ============================================================================

# Get context usage-specific configuration
get_context_usage_config() {
    local key="$1"
    local default="$2"
    get_component_config "context_usage" "$key" "$default"
}

# ============================================================================
# COMPONENT REGISTRATION
# ============================================================================

# Register the context usage component
register_component \
    "context_usage" \
    "Claude Code context window utilization monitoring" \
    "context display" \
    "$(get_context_usage_config 'enabled' 'true')"

debug_log "Context usage component loaded successfully" "INFO"