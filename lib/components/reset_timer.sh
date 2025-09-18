#!/bin/bash

# ============================================================================
# Claude Code Statusline - Reset Timer Component
# ============================================================================
# 
# This component handles block reset timer display.
#
# Dependencies: cost.sh, display.sh
# ============================================================================

# Component data storage
COMPONENT_RESET_TIMER_INFO=""

# ============================================================================
# COMPONENT DATA COLLECTION
# ============================================================================

# Collect reset timer data
collect_reset_timer_data() {
    debug_log "Collecting reset_timer component data" "INFO"
    
    COMPONENT_RESET_TIMER_INFO="$CONFIG_NO_ACTIVE_BLOCK_MESSAGE"
    
    if is_module_loaded "cost" && is_ccusage_available; then
        # Get usage info and extract reset timer
        local usage_info
        usage_info=$(get_claude_usage_info)
        
        if [[ -n "$usage_info" ]]; then
            # Parse usage info (format: session:month:week:today:block:reset)
            local remaining="$usage_info"
            
            # Skip to reset info (6th field)
            for i in {1..5}; do
                remaining="${remaining#*:}"
            done
            
            # Extract reset info
            COMPONENT_RESET_TIMER_INFO="${remaining%%:*}"
        fi
    fi
    
    debug_log "reset_timer data: info=$COMPONENT_RESET_TIMER_INFO" "INFO"
    return 0
}

# ============================================================================
# COMPONENT RENDERING
# ============================================================================

# Render reset timer display
render_reset_timer() {
    # Only render if there's an active timer
    if [[ -n "$COMPONENT_RESET_TIMER_INFO" && "$COMPONENT_RESET_TIMER_INFO" != "$CONFIG_NO_ACTIVE_BLOCK_MESSAGE" ]]; then
        echo "${CONFIG_LIGHT_GRAY}${CONFIG_ITALIC}${COMPONENT_RESET_TIMER_INFO}${CONFIG_RESET}"
        return 0
    else
        return 1  # No content to render
    fi
}

# ============================================================================
# COMPONENT CONFIGURATION
# ============================================================================

# Get component configuration
get_reset_timer_config() {
    local config_key="$1"
    local default_value="$2"
    
    case "$config_key" in
        "enabled")
            get_component_config "reset_timer" "enabled" "${default_value:-true}"
            ;;
        "hide_when_inactive")
            get_component_config "reset_timer" "hide_when_inactive" "${default_value:-true}"
            ;;
        *)
            echo "$default_value"
            ;;
    esac
}

# ============================================================================
# COMPONENT REGISTRATION
# ============================================================================

# Register the reset_timer component
register_component \
    "reset_timer" \
    "Block reset timer (when active)" \
    "cost display" \
    "$(get_reset_timer_config 'enabled' 'true')"

debug_log "Reset timer component loaded" "INFO"