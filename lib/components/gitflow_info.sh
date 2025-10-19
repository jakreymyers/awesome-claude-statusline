#!/bin/bash

# ============================================================================
# Claude Code Statusline - Git Flow Info Component
# ============================================================================
#
# This component provides comprehensive Git Flow information including:
# - Branch name with type-specific icon (🌿 feature, 🚀 release, 🔥 hotfix, etc.)
# - Sync status with remote (↑ ahead, ↓ behind)
# - File changes (● modified, ✚ added, ✖ deleted, ? untracked)
# - Merge target (🎯 where this branch will merge)
#
# Dependencies: git.sh, display.sh
# ============================================================================

# Component data storage
COMPONENT_GITFLOW_BRANCH=""
COMPONENT_GITFLOW_TYPE=""
COMPONENT_GITFLOW_ICON=""
COMPONENT_GITFLOW_SYNC=""
COMPONENT_GITFLOW_CHANGES=""
COMPONENT_GITFLOW_TARGET=""

# ============================================================================
# COMPONENT DATA COLLECTION
# ============================================================================

# Collect Git Flow information data
collect_gitflow_info_data() {
    debug_log "Collecting gitflow_info component data" "INFO"

    # Initialize defaults
    COMPONENT_GITFLOW_BRANCH=""
    COMPONENT_GITFLOW_TYPE="unknown"
    COMPONENT_GITFLOW_ICON="📁"
    COMPONENT_GITFLOW_SYNC=""
    COMPONENT_GITFLOW_CHANGES=""
    COMPONENT_GITFLOW_TARGET=""

    # Get git information if git module is loaded and we're in a git repo
    if is_module_loaded "git" && is_git_repository; then
        # Get branch name
        COMPONENT_GITFLOW_BRANCH=$(get_git_branch)

        # Get branch type and icon
        local type_info
        type_info=$(get_git_flow_branch_type)
        COMPONENT_GITFLOW_TYPE="${type_info%%:*}"
        COMPONENT_GITFLOW_ICON="${type_info##*:}"

        # Get sync status
        COMPONENT_GITFLOW_SYNC=$(get_git_sync_status)

        # Get file changes
        COMPONENT_GITFLOW_CHANGES=$(get_git_file_changes)

        # Get merge target
        COMPONENT_GITFLOW_TARGET=$(get_git_flow_merge_target)
    fi

    debug_log "gitflow_info data: branch=$COMPONENT_GITFLOW_BRANCH, type=$COMPONENT_GITFLOW_TYPE, sync=$COMPONENT_GITFLOW_SYNC, changes=$COMPONENT_GITFLOW_CHANGES, target=$COMPONENT_GITFLOW_TARGET" "INFO"
    return 0
}

# ============================================================================
# COMPONENT RENDERING
# ============================================================================

# Render Git Flow information display
render_gitflow_info() {
    # Return empty if not in a git repository
    if [[ -z "$COMPONENT_GITFLOW_BRANCH" ]]; then
        return 0
    fi

    # Get configuration
    local show_icon=$(get_gitflow_info_config "show_icon" "true")
    local show_sync=$(get_gitflow_info_config "show_sync" "true")
    local show_changes=$(get_gitflow_info_config "show_changes" "true")
    local show_target=$(get_gitflow_info_config "show_target" "true")

    # Build display as array of parts that will be joined with separator
    local parts=()

    # 1. Branch with dimmed icon (always use brown color for consistency)
    local branch_color="${CONFIG_GIT_BRANCH_COLOR:-$(printf '\033[38;2;127;86;50m')}"

    if [[ "$show_icon" == "true" ]]; then
        parts+=("${CONFIG_DIM}${COMPONENT_GITFLOW_ICON}${CONFIG_RESET} ${branch_color}(${COMPONENT_GITFLOW_BRANCH})${CONFIG_RESET}")
    else
        parts+=("${branch_color}(${COMPONENT_GITFLOW_BRANCH})${CONFIG_RESET}")
    fi

    # 2. Sync status (always show with dimming)
    if [[ "$show_sync" == "true" && -n "$COMPONENT_GITFLOW_SYNC" ]]; then
        case "$COMPONENT_GITFLOW_SYNC" in
            synced:*)
                # Always show ↑N ↓N when synced (dimmed)
                local sync_info="${COMPONENT_GITFLOW_SYNC#synced:}"
                parts+=("${CONFIG_DIM}${sync_info}${CONFIG_RESET}")
                ;;
            diverged:*)
                # Show diverged status (dimmed)
                local diverged_info="${COMPONENT_GITFLOW_SYNC#diverged:}"
                parts+=("${CONFIG_DIM}${diverged_info}${CONFIG_RESET}")
                ;;
        esac
    fi

    # 3. File changes (always show with colors from git.sh)
    if [[ "$show_changes" == "true" && -n "$COMPONENT_GITFLOW_CHANGES" ]]; then
        parts+=("${COMPONENT_GITFLOW_CHANGES}")
    fi

    # 4. Merge target (disabled for now - can be re-enabled in config)
    # if [[ "$show_target" == "true" && -n "$COMPONENT_GITFLOW_TARGET" && "$COMPONENT_GITFLOW_TYPE" != "main" ]]; then
    #     parts+=("${CONFIG_DIM}🎯 → ${COMPONENT_GITFLOW_TARGET}${CONFIG_RESET}")
    # fi

    # Join parts with separator if multiple parts exist
    if [[ ${#parts[@]} -gt 1 ]]; then
        local result=""
        for i in "${!parts[@]}"; do
            if [[ $i -eq 0 ]]; then
                result="${parts[$i]}"
            else
                result="${result} ･ ${parts[$i]}"
            fi
        done
        echo "$result"
    else
        echo "${parts[0]}"
    fi

    return 0
}

# ============================================================================
# COMPONENT CONFIGURATION
# ============================================================================

# Get component configuration
get_gitflow_info_config() {
    local config_key="$1"
    local default_value="$2"

    case "$config_key" in
        "enabled")
            get_component_config "gitflow_info" "enabled" "${default_value:-true}"
            ;;
        "show_icon")
            get_component_config "gitflow_info" "show_icon" "${default_value:-true}"
            ;;
        "show_sync")
            get_component_config "gitflow_info" "show_sync" "${default_value:-true}"
            ;;
        "show_changes")
            get_component_config "gitflow_info" "show_changes" "${default_value:-true}"
            ;;
        "show_target")
            get_component_config "gitflow_info" "show_target" "${default_value:-true}"
            ;;
        *)
            echo "$default_value"
            ;;
    esac
}

# ============================================================================
# COMPONENT REGISTRATION
# ============================================================================

# Register the gitflow_info component
register_component \
    "gitflow_info" \
    "Comprehensive Git Flow information with branch type, sync status, changes, and merge target" \
    "display git" \
    "$(get_gitflow_info_config 'enabled' 'true')"

debug_log "Git Flow info component loaded" "INFO"
