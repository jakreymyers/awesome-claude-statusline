#!/bin/bash

# ============================================================================
# Claude Code Statusline - Directory Info Component
# ============================================================================
#
# This component handles directory path display with card index dividers emoji.
# Separated from repo_info for better modularity.
#
# Dependencies: display.sh
# ============================================================================

# Component data storage
COMPONENT_DIRECTORY_INFO_PATH=""

# ============================================================================
# COMPONENT DATA COLLECTION
# ============================================================================

# Collect directory information data
collect_directory_info_data() {
    debug_log "Collecting directory_info component data" "INFO"

    # Get current directory (already set in main script)
    COMPONENT_DIRECTORY_INFO_PATH="${current_dir:-$(pwd)}"

    debug_log "directory_info data: path=$COMPONENT_DIRECTORY_INFO_PATH" "INFO"
    return 0
}

# ============================================================================
# COMPONENT RENDERING
# ============================================================================

# Render directory information display
render_directory_info() {
    local formatted_path
    formatted_path=$(format_directory_info_path "$COMPONENT_DIRECTORY_INFO_PATH")
    echo "$formatted_path"
    return 0
}

# Format directory path with card index dividers emoji and custom color
format_directory_info_path() {
    local current_dir="$1"
    local home_dir="${2:-$HOME}"

    local formatted_path
    if [[ "$current_dir" == "$home_dir"/* ]]; then
        formatted_path="~${current_dir#$home_dir}"
    else
        formatted_path="$current_dir"
    fi

    # Add card index dividers emoji with dim effect and custom color text
    echo "${CONFIG_DIM}🗂️${CONFIG_RESET}  \033[38;2;225;187;139m${formatted_path}\033[0m"
}

# ============================================================================
# COMPONENT CONFIGURATION
# ============================================================================

# Get component configuration
get_directory_info_config() {
    local config_key="$1"
    local default_value="$2"

    case "$config_key" in
        "enabled")
            get_component_config "directory_info" "enabled" "${default_value:-true}"
            ;;
        *)
            echo "$default_value"
            ;;
    esac
}

# ============================================================================
# COMPONENT REGISTRATION
# ============================================================================

# Register the directory_info component
register_component \
    "directory_info" \
    "Current directory path information" \
    "display" \
    "$(get_directory_info_config 'enabled' 'true')"

debug_log "Directory info component loaded" "INFO"