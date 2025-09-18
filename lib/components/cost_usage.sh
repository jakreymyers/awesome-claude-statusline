#!/bin/bash

# ============================================================================
# Claude Code Statusline - Unified Cost Usage Component
# ============================================================================
#
# This component combines monthly, weekly, and daily cost tracking into a
# unified, condensed display format: 💰 USAGE M:$X.XX W:$Y.YY D:$Z.ZZ
#
# Dependencies: cost.sh, display.sh
# ============================================================================

# Component data storage
COMPONENT_COST_USAGE_MONTHLY=""
COMPONENT_COST_USAGE_WEEKLY=""
COMPONENT_COST_USAGE_DAILY=""

# ============================================================================
# COMPONENT DATA COLLECTION
# ============================================================================

# Collect unified cost usage data
collect_cost_usage_data() {
    debug_log "Collecting cost_usage component data" "INFO"

    # Initialize defaults
    COMPONENT_COST_USAGE_MONTHLY="-.--"
    COMPONENT_COST_USAGE_WEEKLY="-.--"
    COMPONENT_COST_USAGE_DAILY="-.--"

    if is_module_loaded "cost" && is_ccusage_available; then
        # Get usage info and parse all cost data
        local usage_info
        usage_info=$(get_claude_usage_info)

        if [[ -n "$usage_info" ]]; then
            # Parse usage info (format: session:month:week:today:block:reset)
            local remaining="$usage_info"

            # Skip session cost
            remaining="${remaining#*:}"

            # Extract month cost
            COMPONENT_COST_USAGE_MONTHLY="${remaining%%:*}"
            remaining="${remaining#*:}"

            # Extract week cost
            COMPONENT_COST_USAGE_WEEKLY="${remaining%%:*}"
            remaining="${remaining#*:}"

            # Extract today cost
            COMPONENT_COST_USAGE_DAILY="${remaining%%:*}"
        fi
    fi

    debug_log "cost_usage data: monthly=$COMPONENT_COST_USAGE_MONTHLY, weekly=$COMPONENT_COST_USAGE_WEEKLY, daily=$COMPONENT_COST_USAGE_DAILY" "INFO"
    return 0
}

# ============================================================================
# COMPONENT RENDERING
# ============================================================================

# Render unified cost usage display
render_cost_usage() {
    local show_usage
    show_usage=$(get_cost_usage_config "enabled" "true")

    # Return empty if disabled
    if [[ "$show_usage" != "true" ]]; then
        debug_log "Cost usage component disabled" "INFO"
        return 0
    fi

    # Use display.sh formatting function
    if type format_cost_usage &>/dev/null; then
        format_cost_usage "$COMPONENT_COST_USAGE_MONTHLY" "$COMPONENT_COST_USAGE_WEEKLY" "$COMPONENT_COST_USAGE_DAILY"
    else
        # Fallback formatting
        echo "💰 USAGE M:\$${COMPONENT_COST_USAGE_MONTHLY} W:\$${COMPONENT_COST_USAGE_WEEKLY} D:\$${COMPONENT_COST_USAGE_DAILY}"
    fi

    return 0
}

# ============================================================================
# COMPONENT CONFIGURATION
# ============================================================================

# Get cost usage-specific configuration
get_cost_usage_config() {
    local key="$1"
    local default="$2"
    get_component_config "cost_usage" "$key" "$default"
}

# ============================================================================
# COMPONENT REGISTRATION
# ============================================================================

# Register the unified cost usage component
register_component \
    "cost_usage" \
    "Unified monthly/weekly/daily cost tracking" \
    "cost display" \
    "$(get_cost_usage_config 'enabled' 'true')"

debug_log "Cost usage component (unified) loaded successfully" "INFO"