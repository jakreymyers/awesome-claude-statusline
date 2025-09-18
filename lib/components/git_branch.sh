#!/bin/bash

# ============================================================================
# Claude Code Statusline - Git Branch Component
# ============================================================================
#
# This component handles git branch display with leaf emoji.
# Separated from repo_info for better modularity.
#
# Dependencies: git.sh, display.sh
# ============================================================================

# Component data storage
COMPONENT_GIT_BRANCH_NAME=""
COMPONENT_GIT_BRANCH_STATUS=""

# ============================================================================
# COMPONENT DATA COLLECTION
# ============================================================================

# Collect git branch information data
collect_git_branch_data() {
    debug_log "Collecting git_branch component data" "INFO"

    # Initialize defaults
    COMPONENT_GIT_BRANCH_NAME=""
    COMPONENT_GIT_BRANCH_STATUS="not_git"

    # Get git information if git module is loaded and we're in a git repo
    if is_module_loaded "git" && is_git_repository; then
        COMPONENT_GIT_BRANCH_NAME=$(get_git_branch)
        COMPONENT_GIT_BRANCH_STATUS=$(get_git_status)
    fi

    debug_log "git_branch data: name=$COMPONENT_GIT_BRANCH_NAME, status=$COMPONENT_GIT_BRANCH_STATUS" "INFO"
    return 0
}

# ============================================================================
# COMPONENT RENDERING
# ============================================================================

# Render git branch information display
render_git_branch() {
    # Return empty if not in a git repository
    if [[ -z "$COMPONENT_GIT_BRANCH_NAME" ]]; then
        return 0
    fi

    # Add git branch info with dim leaf emoji and bright text
    echo "${CONFIG_DIM}🌿${CONFIG_RESET}  ${CONFIG_GREEN}(${COMPONENT_GIT_BRANCH_NAME})${CONFIG_RESET}"
    return 0
}

# ============================================================================
# COMPONENT CONFIGURATION
# ============================================================================

# Get component configuration
get_git_branch_config() {
    local config_key="$1"
    local default_value="$2"

    case "$config_key" in
        "enabled")
            get_component_config "git_branch" "enabled" "${default_value:-true}"
            ;;
        *)
            echo "$default_value"
            ;;
    esac
}

# ============================================================================
# COMPONENT REGISTRATION
# ============================================================================

# Register the git_branch component
register_component \
    "git_branch" \
    "Git branch information" \
    "display git" \
    "$(get_git_branch_config 'enabled' 'true')"

debug_log "Git branch component loaded" "INFO"