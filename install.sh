#!/bin/bash

# ============================================================================
# Awesome Claude Statusline - Installer
# ============================================================================
# One-command installation for the awesome statusline with Git Flow support
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/jakreymyers/awesome-claude-statusline/main/install.sh | bash
#
# Or clone first:
#   git clone https://github.com/jakreymyers/awesome-claude-statusline.git
#   cd awesome-claude-statusline
#   ./install.sh
# ============================================================================

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Configuration
INSTALL_DIR="$HOME/.claude/statusline"
CONFIG_FILE="$HOME/.claude/config.json"
REPO_URL="https://github.com/jakreymyers/awesome-claude-statusline.git"
TEMP_DIR="/tmp/awesome-claude-statusline-install"

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}======================================================================${RESET}"
    echo -e "${BOLD}  Awesome Claude Statusline Installer${RESET}"
    echo -e "${CYAN}  Version 2.11.0 with Git Flow Support${RESET}"
    echo -e "${CYAN}======================================================================${RESET}"
    echo ""
}

print_step() {
    echo -e "${BOLD}${BLUE}▸ $1${RESET}"
}

print_success() {
    echo -e "${GREEN}✓ $1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${RESET}"
}

print_error() {
    echo -e "${RED}✗ $1${RESET}"
}

print_info() {
    echo -e "${DIM}  $1${RESET}"
}

# ============================================================================
# Preflight Checks
# ============================================================================

check_prerequisites() {
    print_step "Checking prerequisites..."

    # Check for bash
    if [ -z "$BASH_VERSION" ]; then
        print_error "Bash is required but not found"
        exit 1
    fi
    print_info "Bash: $BASH_VERSION ✓"

    # Check for git (if we need to clone)
    if ! command -v git &> /dev/null; then
        print_warning "Git not found - will try direct download"
    else
        print_info "Git: $(git --version | cut -d' ' -f3) ✓"
    fi

    # Check for jq (optional but recommended)
    if ! command -v jq &> /dev/null; then
        print_warning "jq not found - config update may be limited"
        print_info "Install jq for full functionality: brew install jq (macOS) or apt-get install jq (Linux)"
    else
        print_info "jq: $(jq --version) ✓"
    fi

    echo ""
}

# ============================================================================
# Installation
# ============================================================================

create_directories() {
    print_step "Creating installation directories..."

    if [ -d "$INSTALL_DIR" ]; then
        print_warning "Installation directory already exists: $INSTALL_DIR"
        read -p "  Do you want to overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Installation cancelled"
            exit 1
        fi
        rm -rf "$INSTALL_DIR"
    fi

    mkdir -p "$INSTALL_DIR"
    print_success "Created: $INSTALL_DIR"

    mkdir -p "$HOME/.claude"
    print_success "Ensured: $HOME/.claude"

    echo ""
}

download_files() {
    print_step "Downloading statusline files..."

    # Check if we're in the repo already
    if [ -f "$(dirname "$0")/statusline.sh" ]; then
        print_info "Installing from local repository"
        SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

        # Copy all files
        cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR/"

        # Remove git-related files
        rm -rf "$INSTALL_DIR/.git" "$INSTALL_DIR/.github" 2>/dev/null || true

        print_success "Files copied from local repository"
    else
        print_info "Cloning from GitHub..."

        # Clone to temp directory
        rm -rf "$TEMP_DIR"
        if ! git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>&1 | grep -v "Cloning into"; then
            print_error "Failed to clone repository"
            exit 1
        fi

        # Copy files
        cp -r "$TEMP_DIR"/* "$INSTALL_DIR/"

        # Cleanup
        rm -rf "$TEMP_DIR"
        rm -rf "$INSTALL_DIR/.git" "$INSTALL_DIR/.github" 2>/dev/null || true

        print_success "Files downloaded from GitHub"
    fi

    echo ""
}

set_permissions() {
    print_step "Setting permissions..."

    chmod +x "$INSTALL_DIR/statusline.sh"
    print_success "Made statusline.sh executable"

    # Make install.sh executable too for future use
    if [ -f "$INSTALL_DIR/install.sh" ]; then
        chmod +x "$INSTALL_DIR/install.sh"
    fi

    echo ""
}

update_config() {
    print_step "Updating Claude Code configuration..."

    if ! command -v jq &> /dev/null; then
        print_warning "jq not installed - manual config update required"
        print_info "Add this to $CONFIG_FILE:"
        echo ""
        echo -e "${CYAN}  \"statusLine\": {${RESET}"
        echo -e "${CYAN}    \"type\": \"command\",${RESET}"
        echo -e "${CYAN}    \"command\": \"bash $INSTALL_DIR/statusline.sh\"${RESET}"
        echo -e "${CYAN}  }${RESET}"
        echo ""
        return
    fi

    # Create config if it doesn't exist
    if [ ! -f "$CONFIG_FILE" ]; then
        echo '{}' > "$CONFIG_FILE"
        print_info "Created new config file"
    fi

    # Backup existing config
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
    print_info "Backed up existing config"

    # Update config with jq
    jq --arg cmd "bash $INSTALL_DIR/statusline.sh" \
        '.statusLine = {type: "command", command: $cmd}' \
        "$CONFIG_FILE" > "$CONFIG_FILE.tmp"

    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    print_success "Updated Claude Code configuration"
    print_info "Backup saved: $CONFIG_FILE.backup"

    echo ""
}

# ============================================================================
# Post-Installation
# ============================================================================

print_success_message() {
    echo -e "${GREEN}======================================================================${RESET}"
    echo -e "${BOLD}${GREEN}  Installation Complete! 🎉${RESET}"
    echo -e "${GREEN}======================================================================${RESET}"
    echo ""
    echo -e "${CYAN}Your awesome statusline is now installed with:${RESET}"
    echo -e "${CYAN}  🌿 Dynamic Git Flow branch icons${RESET}"
    echo -e "${CYAN}  📊 Colored file change indicators (●✚✖)${RESET}"
    echo -e "${CYAN}  💰 Comprehensive cost tracking${RESET}"
    echo -e "${CYAN}  🧠 Real-time context monitoring${RESET}"
    echo ""
    echo -e "${YELLOW}Next steps:${RESET}"
    echo -e "  ${BOLD}1.${RESET} Restart Claude Code to activate the statusline"
    echo -e "  ${BOLD}2.${RESET} Customize: ${CYAN}$INSTALL_DIR/Config.toml${RESET}"
    echo -e "  ${BOLD}3.${RESET} Read docs: ${CYAN}$INSTALL_DIR/README.md${RESET}"
    echo ""
    echo -e "${BLUE}Documentation:${RESET} https://github.com/jakreymyers/awesome-claude-statusline"
    echo -e "${BLUE}Issues:${RESET} https://github.com/jakreymyers/awesome-claude-statusline/issues"
    echo ""
}

# ============================================================================
# Main Installation Flow
# ============================================================================

main() {
    print_header
    check_prerequisites
    create_directories
    download_files
    set_permissions
    update_config
    print_success_message
}

# Run installer
main
