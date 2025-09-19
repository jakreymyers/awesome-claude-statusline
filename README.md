# 🎨 Awesome Claude Statusline

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/jakreymyers/awesome-claude-statusline?style=social)](https://github.com/jakreymyers/awesome-claude-statusline/stargazers)

> 🚀 **Transform your Claude Code experience with intelligent cost tracking, real-time context monitoring, and beautiful themes**

A comprehensive, modular statusline system that provides essential workflow information at a glance. Built for developers who want deep insights into their Claude Code usage with visual excellence and complete customization control.

![Awesome Claude Statusline Screenshot](https://github.com/jakreymyers/awesome-claude-statusline/blob/main/assets/statusline-screenshot.png)

```
🗂️  current directory • 🌳 (git branch) • ✅ # of commits (time since commit) • 👾 c/c version
🤖 model • 🧠 context usage % (utilized/total) • ⚙️ MCP: #/# connected/total (status)
💰 M:$ monthly W:$ weekly D:$ daily • 🔥 tokens /min ($/hr) • ⏰ RESET at <reset time>
```

## Table of Contents

**Getting Started**
- [🚀 Quick Start](#-quick-start)
- [✨ Key Features](#-key-features)
- [🎯 What You Get](#-what-you-get)

**Understanding the System**
- [🏗️ How It Works](#️-how-it-works)
- [📊 Component Reference](#-component-reference)
- [🎨 Visual Design](#-visual-design)

**Customization & Advanced Usage**
- [🎛️ Configuration Guide](#️-configuration-guide)
- [🎨 Themes & Personalization](#-themes--personalization)
- [🔧 Building Your Own Components](#-building-your-own-components)
- [⚡ Performance & Caching](#-performance--caching)

**Development & Contribution**
- [💡 Ideas & Enhancement Guide](#-ideas--enhancement-guide)
- [🐛 Troubleshooting](#-troubleshooting)
- [🤝 Contributing](#-contributing)

## 🚀 Quick Start

### Prerequisites
- **Claude Code CLI** installed and configured
- **Bash 4.0+** (auto-detected and upgraded on macOS)
- **jq** for JSON parsing

### Installation & First Run
```bash
# Clone and test
git clone https://github.com/jakreymyers/awesome-claude-statusline.git
cd awesome-claude-statusline
chmod +x statusline.sh

# See it in action
echo '{"workspace":{"current_dir":"'$(pwd)'"}}' | ./statusline.sh
```

You'll immediately see your current directory, git status, version info, and more - all beautifully formatted with the default **Jak'd theme**.

## ✨ Key Features

### 🎯 **Smart Context Management**
Never run out of context unexpectedly. The statusline monitors your Claude conversation in real-time:
- **🟢 Green (0-34%)**: Plenty of space, work freely
- **🟠 Orange (35-59%)**: Getting full, plan ahead
- **🔴 Red (60%+)**: Consider using `/compact` soon

### 💰 **Comprehensive Cost Intelligence**
Track your Claude usage across multiple timeframes:
- **Monthly/Weekly/Daily** cost breakdowns
- **Live burn rate** (tokens/minute, $/hour)
- **Billing block tracking** with reset timers
- **Projection analysis** for current session

### 🔧 **Git Workflow Integration**
Stay connected to your codebase:
- **Branch status** with clean/dirty indicators
- **Commit activity** with time since last commit
- **Submodule tracking** for complex projects
- **Smart path display** (~/project instead of /Users/you/project)

### 🎨 **Beautiful & Themeable**
- **4 Built-in themes**: Jak'd (default), Classic, Garden, Catppuccin
- **Consistent emoji system** with perfect dimming
- **Custom color support** for personal branding
- **Responsive layout** adapting to your terminal

## 🎯 What You Get

Understanding what information is available helps you customize effectively:

**Line 1 - Project Context**
```
🗂️ ~/awesome-claude-statusline • 🌳 (main) • ✅ 15 (2m ago) • 👾 v1.0.117
```

**Line 2 - Active Session**
```
🤖 Claude • 🧠 55% (109k/200k) • ⚙️ MCP: 2 (active)
```

**Line 3 - Cost & Performance**
```
💰 M:$462.43 W:$151.64 D:$36.80 • 🔥 205k/min ($6.66/hr) • ⏰ RESET at 18:00
```

## System Architecture

```
statusline.sh (main entry point)
├── lib/core.sh (core functionality)
├── lib/config.sh (configuration management)
├── lib/display.sh (rendering and formatting)
├── lib/components.sh (component registry)
├── lib/cache.sh (caching system)
├── lib/git.sh (git operations)
├── lib/mcp.sh (MCP server detection)
├── lib/cost.sh (cost tracking)
└── lib/components/ (individual components)
    ├── directory_info.sh
    ├── git_branch.sh
    ├── commits.sh
    ├── version_info.sh
    ├── model_info.sh
    ├── mcp_status.sh
    ├── cost_*.sh
```

## Component System

### Available Components

#### Core Components
- **directory_info** - Current directory path with card index dividers emoji (🗂️)
  - Data: Current working directory path (shortened with ~)
  - Color: Custom #E1BB8B

- **git_branch** - Git branch information with leaf emoji (🌿)
  - Data: Current git branch name in parentheses
  - Dependencies: git.sh

- **commits** - Commit activity with ballot box emoji (☑️)
  - Data: Number of commits in last 24 hours + time since last commit
  - Dependencies: git.sh

- **version_info** - Claude Code version with alien monster emoji (👾)
  - Data: Claude Code version (e.g., v1.0.117)
  - Dependencies: core.sh

#### Model & Cost Components
- **model_info** - Claude model with robot emoji (🤖)
  - Data: Current Claude model name
  - Emoji: Always 🤖 regardless of model type

- **cost_repo** - Repository-specific costs
  - Data: Repository cost tracking

- **cost_monthly/weekly/daily** - Time-period cost tracking
  - Data: Costs over different time periods

- **cost_live** - Live block cost tracking
  - Data: Current session/block costs

- **burn_rate** - Token burn rate analysis
  - Data: Tokens per minute and hourly cost projection

#### Technical Components
- **mcp_status** - MCP server status
  - Data: Connected/total MCP servers
  - Dependencies: mcp.sh

- **token_usage** - Token consumption metrics
  - Data: Total tokens used

- **cache_efficiency** - Cache performance
  - Data: Cache hit ratio percentage

- **block_projection** - Cost projection for current block
  - Data: Projected costs


### Component Interface

Every component must implement:
```bash
collect_${component_name}_data()  # Data collection
render_${component_name}()        # Display rendering
get_${component_name}_config()    # Configuration access
```

Components are registered using:
```bash
register_component "component_name" "Description" "dependencies" "enabled_status"
```

## Configuration

### Main Configuration File: `Config.toml`

The system uses TOML format for configuration with dot notation:

#### Display Lines Configuration
```toml
# Line 1 Components and Separators
display.line1.components = "directory_info git_branch commits version_info"
display.line1.separator = " ･ "

# Enable/disable features
features.show_commits = true
features.show_version = true
features.show_mcp_status = true
```

#### Theme Configuration
```toml
theme.name = "catppuccin"  # "classic", "garden", "catppuccin", "custom"
```

#### Component-Specific Settings
```toml

# Timeouts
timeouts.mcp = "10s"
timeouts.version = "10s"
```

## Visual Design System

### Emoji System
- **Consistent Usage**: Each component has a dedicated emoji that remains constant
- **Opacity Control**: All emojis use 50% opacity (`${CONFIG_DIM}`) while text remains full opacity
- **Component Format**: `(emoji) <data>` pattern throughout

### Current Emoji Mapping
- 🗂️ **Directory Info** - Card index dividers (dim)
- 🌿 **Git Branch** - Leaf (dim)
- ☑️ **Commits** - Ballot box with check (dim)
- 👾 **Version** - Alien monster (dim)
- 🤖 **Model** - Robot (always, regardless of Claude model)
- 🔥 **Live Costs** - Fire

### Color Scheme (Catppuccin Theme)
- **Directory Path**: #E1BB8B (custom warm beige)
- **Git Branch**: Green variations
- **Version**: Purple tones
- **Costs**: Various colors per component
- **Text**: Full opacity for readability
- **Emojis**: 50% opacity for subtle visual hierarchy

### Separators
- **Primary Separator**: ` ･ ` (middle dot with spaces)
- **Configurable**: Can be changed per display line in Config.toml

## File Dependencies

### Core Files
- `statusline.sh` - Main entry point, expects JSON input with `workspace.current_dir`
- `lib/core.sh` - Core functionality, logging, error handling
- `lib/config.sh` - TOML configuration parsing
- `lib/security.sh` - Security validation and sanitization

### Data Processing
- `lib/git.sh` - Git repository operations, branch detection, commit counting
- `lib/mcp.sh` - MCP server discovery and health monitoring
- `lib/cache.sh` - Caching system with project isolation
- `lib/cost.sh` - Cost calculation and tracking

### Display & Rendering
- `lib/display.sh` - Formatting functions, color management
- `lib/components.sh` - Component registry and base functionality
- `lib/themes.sh` - Theme definitions and color schemes

### Component Dependencies
```
directory_info.sh → display.sh
git_branch.sh → git.sh, display.sh
commits.sh → git.sh, display.sh
version_info.sh → core.sh
model_info.sh → display.sh
mcp_status.sh → mcp.sh
cost_*.sh → cost.sh
```

## Development Guide

### Adding New Components

1. **Create Component File**: `lib/components/my_component.sh`
2. **Implement Required Functions**:
   ```bash
   collect_my_component_data() {
       COMPONENT_MY_COMPONENT_DATA="your_data"
   }

   render_my_component() {
       echo "${CONFIG_DIM}🔧${CONFIG_RESET} ${COMPONENT_MY_COMPONENT_DATA}"
   }

   get_my_component_config() {
       get_component_config "my_component" "$1" "$2"
   }
   ```

3. **Register Component**:
   ```bash
   register_component "my_component" "Description" "dependencies" "true"
   ```

4. **Add to Display Line**: Update `Config.toml`
   ```toml
   display.line1.components = "directory_info my_component"
   ```

### Modifying Existing Components

1. **Data Collection**: Modify `collect_${component}_data()` function
2. **Display Format**: Update `render_${component}()` function
3. **Configuration**: Adjust `get_${component}_config()` as needed
4. **Dependencies**: Update file dependencies if required

### Working with Cache System

The cache system provides project-aware isolation:

```bash
# Cache git operations
if [[ "${STATUSLINE_CACHE_LOADED:-}" == "true" ]]; then
    result=$(cache_git_operation "operation_key" "$duration" git command)
fi
```

**Cache Key Sanitization**: Paths with dots are automatically sanitized to prevent arithmetic errors.

### Testing Changes

1. **Run Statusline**:
   ```bash
   echo '{"workspace": {"current_dir": "/your/path"}}' | ./statusline.sh
   ```

2. **Debug Mode**: Set environment variables for debugging:
   ```bash
   export STATUSLINE_DEBUG=true
   ```

3. **Component Testing**: Test individual components by sourcing them and calling functions

### Git Workflow

1. **Feature Branches**: Create feature branches for major changes
   ```bash
   git checkout -b feature/new-component
   ```

2. **Commit Messages**: Follow conventional commit format:
   ```
   ✨ feat: Add new component
   🐛 fix: Fix cache issue
   📝 docs: Update README
   ```

3. **Testing**: Test thoroughly before merging to main

### Configuration Best Practices

1. **Default Values**: Always provide sensible defaults in component functions
2. **Validation**: Validate configuration values before use
3. **Backwards Compatibility**: Maintain compatibility when changing config structure
4. **Documentation**: Document new configuration options in Config.toml

### Performance Considerations

1. **Caching**: Use caching for expensive operations (git, network calls)
2. **Timeouts**: Set appropriate timeouts for external commands
3. **Conditional Loading**: Only load components when enabled
4. **Efficient Rendering**: Minimize string operations in render functions

## Troubleshooting

### Common Issues

1. **Missing Commit Count**:
   - Check cache key sanitization for paths with dots
   - Verify git repository status
   - Check `get_commits_today()` function

2. **MCP Status Unknown**:
   - Verify MCP servers are configured in project directory
   - Check MCP detection is running from correct directory
   - Validate timeout settings

3. **Color/Formatting Issues**:
   - Check ANSI escape code syntax
   - Verify theme configuration
   - Test color support in terminal

4. **Component Not Showing**:
   - Verify component is registered
   - Check component is enabled in config
   - Validate display line configuration

### Debug Commands

```bash
# Test individual components
source lib/components/component_name.sh
collect_component_data
render_component

# Check git operations
source lib/git.sh
get_commits_today
get_git_branch

# Verify cache operations
source lib/cache.sh
show_cache_stats
```

### Cache Management

```bash
# Clear cache if issues persist
rm -rf ~/.cache/statusline/

# Check cache stats
echo '{"workspace": {"current_dir": "/path"}}' | STATUSLINE_DEBUG=true ./statusline.sh
```

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following the development guide
4. Test thoroughly
5. Submit a pull request with clear description

## License

This project is part of the Claude Code ecosystem. See main Claude Code documentation for licensing information.