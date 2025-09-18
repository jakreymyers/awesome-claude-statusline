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
SYSTEM_OVERHEAD_TOKENS=15000  # Estimated tokens for system prompt and system tools

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Format tokens to thousands (38k format)
format_tokens_to_thousands() {
    local tokens="$1"

    if [[ -z "$tokens" || "$tokens" == "0" ]]; then
        echo "0k"
        return 0
    fi

    # Round to nearest thousand
    local thousands=$((($tokens + 500) / 1000))
    echo "${thousands}k"
}

# ============================================================================
# COMPONENT DATA COLLECTION
# ============================================================================

# Get context usage from Claude Code's internal data
# This attempts to access the same data that /context command uses
get_claude_context_usage() {
    local current_dir="$1"
    local claude_projects_dir="$HOME/.claude/projects"

    if [[ -d "$claude_projects_dir" ]]; then
        # Convert current directory path to Claude's project directory naming convention
        # Claude Code converts /Users/jak/dev/project-name to -Users-jak-dev-project-name
        local project_pattern
        project_pattern=$(echo "$current_dir" | sed 's|/|-|g' | sed 's|^-||')

        debug_log "Looking for project pattern: $project_pattern" "INFO"
        debug_log "Current directory: $current_dir" "INFO"

        # Find the exact project directory
        local project_dir
        project_dir=$(find "$claude_projects_dir" -maxdepth 1 -name "*${project_pattern}*" -type d 2>/dev/null | head -1)

        if [[ -n "$project_dir" ]]; then
            debug_log "Found project directory: $project_dir" "INFO"

            # Get the most recently modified transcript file from this project
            local latest_transcript
            latest_transcript=$(find "$project_dir" -name "*.jsonl" -type f -exec ls -t {} + 2>/dev/null | head -1)

            if [[ -n "$latest_transcript" && -f "$latest_transcript" ]]; then
                debug_log "Found latest transcript: $latest_transcript" "INFO"
                echo "$latest_transcript"
                return 0
            else
                debug_log "No transcript files found in $project_dir" "WARN"
            fi
        else
            debug_log "No project directory found for pattern: $project_pattern" "WARN"

            # Fallback: try to find any recent transcript across all projects
            local fallback_transcript
            fallback_transcript=$(find "$claude_projects_dir" -name "*.jsonl" -type f -exec ls -t {} + 2>/dev/null | head -1)

            if [[ -n "$fallback_transcript" ]]; then
                debug_log "Using fallback transcript: $fallback_transcript" "INFO"
                echo "$fallback_transcript"
                return 0
            fi
        fi
    fi

    debug_log "No transcript file found" "ERROR"
    return 1
}

# Parse transcript file for latest token usage
parse_transcript_usage() {
    local transcript_file="$1"

    if [[ -f "$transcript_file" ]]; then
        debug_log "Parsing transcript file: $transcript_file" "INFO"

        # Use grep to find the most recent usage data more efficiently
        # Look for the last occurrence of usage data in the file
        local usage_line
        usage_line=$(grep '"usage":{' "$transcript_file" | tail -1)

        if [[ -n "$usage_line" ]]; then
            debug_log "Found usage line: ${usage_line:0:100}..." "INFO"

            # Extract token values using more robust regex patterns
            local input_tokens cache_creation_tokens cache_read_tokens output_tokens

            input_tokens=$(echo "$usage_line" | grep -o '"input_tokens":[0-9]*' | grep -o '[0-9]*$' | head -1)
            cache_creation_tokens=$(echo "$usage_line" | grep -o '"cache_creation_input_tokens":[0-9]*' | grep -o '[0-9]*$' | head -1)
            cache_read_tokens=$(echo "$usage_line" | grep -o '"cache_read_input_tokens":[0-9]*' | grep -o '[0-9]*$' | head -1)
            output_tokens=$(echo "$usage_line" | grep -o '"output_tokens":[0-9]*' | grep -o '[0-9]*$' | head -1)

            # Default to 0 if not found
            input_tokens=${input_tokens:-0}
            cache_creation_tokens=${cache_creation_tokens:-0}
            cache_read_tokens=${cache_read_tokens:-0}
            output_tokens=${output_tokens:-0}

            # Calculate total context usage (include system overhead)
            local total_tokens=$((input_tokens + cache_creation_tokens + cache_read_tokens + output_tokens + SYSTEM_OVERHEAD_TOKENS))

            debug_log "Parsed tokens: input=$input_tokens, cache_creation=$cache_creation_tokens, cache_read=$cache_read_tokens, output=$output_tokens, total=$total_tokens" "INFO"

            if [[ $total_tokens -gt 0 ]]; then
                # Return all 5 values: input:cache_creation:cache_read:output:total
                echo "${input_tokens}:${cache_creation_tokens}:${cache_read_tokens}:${output_tokens}:${total_tokens}"
                return 0
            fi
        else
            debug_log "No usage data found in transcript file" "WARN"
        fi
    else
        debug_log "Transcript file not found or not readable: $transcript_file" "ERROR"
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

        # Estimate tokens (adjusted calculation: chars / 11) plus system overhead
        total_estimated_tokens=$((total_chars / 11 + SYSTEM_OVERHEAD_TOKENS))

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

        # Parse actual usage data from the transcript
        local usage_data
        usage_data=$(parse_transcript_usage "$transcript_file")

        if [[ "$usage_data" != "0:0:0:0:0" ]]; then
            # Parse the usage data (format: input:cache_creation:cache_read:output:total)
            local input_tokens cache_creation_tokens cache_read_tokens output_tokens total_tokens

            IFS=':' read -r input_tokens cache_creation_tokens cache_read_tokens output_tokens total_tokens <<< "$usage_data"

            # Store the parsed data
            COMPONENT_CONTEXT_USAGE_INPUT_TOKENS="$input_tokens"
            COMPONENT_CONTEXT_USAGE_CACHE_CREATION_TOKENS="$cache_creation_tokens"
            COMPONENT_CONTEXT_USAGE_CACHE_READ_TOKENS="$cache_read_tokens"
            COMPONENT_CONTEXT_USAGE_OUTPUT_TOKENS="$output_tokens"
            COMPONENT_CONTEXT_USAGE_TOTAL_TOKENS="$total_tokens"

            # Calculate percentage based on actual token usage
            COMPONENT_CONTEXT_USAGE_PERCENTAGE=$(echo "scale=1; $total_tokens * 100 / $CONTEXT_LIMIT" | bc 2>/dev/null || echo "0.0")

            debug_log "Parsed actual usage data: ${total_tokens} tokens (${COMPONENT_CONTEXT_USAGE_PERCENTAGE}%)" "INFO"
        else
            debug_log "No valid usage data found in transcript, using file size estimation as fallback" "WARN"

            # Fallback to file size estimation
            local estimated_tokens
            estimated_tokens=$(estimate_context_from_transcript "$transcript_file")

            if [[ $estimated_tokens -gt 0 ]]; then
                COMPONENT_CONTEXT_USAGE_TOTAL_TOKENS="$estimated_tokens"
                COMPONENT_CONTEXT_USAGE_INPUT_TOKENS="$estimated_tokens"
                COMPONENT_CONTEXT_USAGE_PERCENTAGE=$(echo "scale=1; $estimated_tokens * 100 / $CONTEXT_LIMIT" | bc 2>/dev/null || echo "0.0")

                debug_log "Using estimated tokens: ${estimated_tokens} (${COMPONENT_CONTEXT_USAGE_PERCENTAGE}%)" "INFO"
            fi
        fi
    else
        debug_log "No transcript file found for current directory: $current_dir" "WARN"
    fi

    debug_log "Final context_usage data: ${COMPONENT_CONTEXT_USAGE_PERCENTAGE}% (${COMPONENT_CONTEXT_USAGE_TOTAL_TOKENS} tokens)" "INFO"
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
            context_color="${CONFIG_CONTEXT_CRITICAL:-$(printf '\033[38;2;255;96;96m')}"  # Red - needs /compact soon
        elif [[ $percentage_int -ge 60 ]]; then
            context_color="${CONFIG_CONTEXT_WARNING:-$(printf '\033[38;2;255;165;0m')}"  # Orange - getting full
        else
            context_color="${CONFIG_CONTEXT_SAFE:-$(printf '\033[38;2;0;255;0m')}"    # Green - plenty of space
        fi

        # Format tokens in thousands
        local formatted_total formatted_limit
        formatted_total=$(format_tokens_to_thousands "$COMPONENT_CONTEXT_USAGE_TOTAL_TOKENS")
        formatted_limit=$(format_tokens_to_thousands "$COMPONENT_CONTEXT_USAGE_LIMIT")

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