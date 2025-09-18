#!/bin/bash

# ============================================================================
# Claude Code Statusline - Commits Component (Atomic)
# ============================================================================
# 
# This atomic component handles only commit count display.
# Part of the atomic component refactoring to provide granular control.
#
# Dependencies: git.sh, display.sh
# ============================================================================

# Component data storage
COMPONENT_COMMITS_COUNT=""
COMPONENT_COMMITS_LAST_TIME=""

# ============================================================================
# COMPONENT DATA COLLECTION
# ============================================================================

# Collect commit count data
collect_commits_data() {
    debug_log "Collecting commits component data" "INFO"

    # Initialize defaults
    COMPONENT_COMMITS_COUNT="0"
    COMPONENT_COMMITS_LAST_TIME="never"

    # Get commit count and time since last commit if git module is loaded and we're in a git repo
    if is_module_loaded "git" && is_git_repository; then
        COMPONENT_COMMITS_COUNT=$(get_commits_today)
        COMPONENT_COMMITS_LAST_TIME=$(get_time_since_last_commit)
    fi

    debug_log "commits data: count=$COMPONENT_COMMITS_COUNT, last_time=$COMPONENT_COMMITS_LAST_TIME" "INFO"
    return 0
}

# ============================================================================
# COMPONENT RENDERING
# ============================================================================

# Render commit count display
render_commits() {
    local show_commits
    show_commits=$(get_commits_config "enabled" "true")
    
    # Return empty if disabled
    if [[ "$show_commits" != "true" ]]; then
        debug_log "Commits component disabled" "INFO"
        return 0
    fi
    
    # Build commits display with dim ballot box emoji and bright text
    # Always show time since last commit, regardless of today's count
    local commits_display="${CONFIG_DIM}☑️${CONFIG_RESET}  ${COMPONENT_COMMITS_COUNT} (${COMPONENT_COMMITS_LAST_TIME})"

    echo "$commits_display"
    return 0
}

# ============================================================================
# COMPONENT CONFIGURATION
# ============================================================================

# Get commits-specific configuration
get_commits_config() {
    local key="$1"
    local default="$2"
    get_component_config "commits" "$key" "$default"
}

# ============================================================================
# COMPONENT REGISTRATION
# ============================================================================

# Register the commits component
register_component \
    "commits" \
    "Today's git commit count" \
    "display git" \
    "$(get_commits_config 'enabled' 'true')"

debug_log "Commits component (atomic) loaded successfully" "INFO"