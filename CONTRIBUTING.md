# Contributing to Awesome Claude Statusline

We love your input! We want to make contributing to this project as easy and transparent as possible.

## Quick Start for Contributors

1. **Fork** the repository
2. **Clone** your fork: `git clone https://github.com/YOUR_USERNAME/awesome-claude-statusline.git`
3. **Create** a feature branch: `git checkout -b feature/amazing-feature`
4. **Make** your changes
5. **Test** thoroughly
6. **Commit** with clear messages
7. **Push** to your branch: `git push origin feature/amazing-feature`
8. **Open** a Pull Request

## Development Setup

```bash
# Clone and setup
git clone https://github.com/jakreymyers/awesome-claude-statusline.git
cd awesome-claude-statusline

# Test your environment
echo '{"workspace":{"current_dir":"'$(pwd)'"}}' | ./statusline.sh
```

## Types of Contributions

### 🎨 **New Themes**
- Add theme functions to `lib/themes.sh`
- Use consistent `CONFIG_*` variable naming
- Test with all components
- Document color choices

### 🔧 **New Components**
- Create in `lib/components/your_component.sh`
- Implement standard interface (collect/render/config functions)
- Register with `register_component`
- Add configuration options to `Config.toml`

### 🐛 **Bug Fixes**
- Include reproduction steps in your PR
- Test the fix thoroughly
- Update tests if applicable

### 📚 **Documentation**
- Keep README.md current
- Add code comments for complex logic
- Update configuration examples

## Component Development Guide

### Standard Interface
Every component must implement:
```bash
collect_your_component_data() {
    # Collect data into COMPONENT_YOUR_COMPONENT_* variables
}

render_your_component() {
    # Output formatted component display
    echo "${CONFIG_DIM}🔧${CONFIG_RESET} ${data}"
}

get_your_component_config() {
    # Handle configuration queries
    get_component_config "your_component" "$1" "$2"
}
```

### Registration
```bash
register_component \
    "your_component" \
    "Description of what it does" \
    "dependency1 dependency2" \
    "true"  # enabled by default
```

## Code Style

### Shell Script Best Practices
- Use `local` for function variables
- Quote variables: `"$variable"`
- Use `[[ ]]` for conditionals
- Handle errors gracefully with fallbacks
- Add debug logging for complex operations

### Naming Conventions
- **Functions**: `snake_case`
- **Variables**: `UPPERCASE_SNAKE_CASE` for globals, `lowercase` for locals
- **Component variables**: `COMPONENT_NAME_DATA_TYPE`
- **Config variables**: `CONFIG_CATEGORY_ITEM`

### Git Commit Messages
Use conventional commits with emojis:
```
🎨 feat: Add new burn rate component
🐛 fix: Handle missing git repository gracefully
📝 docs: Update component development guide
🚀 perf: Optimize cache lookup performance
```

## Testing Guidelines

### Manual Testing
```bash
# Test basic functionality
echo '{"workspace":{"current_dir":"'$(pwd)'"}}' | ./statusline.sh

# Test with different themes
echo 'theme.name = "classic"' > test_config.toml
# Run statusline...

# Test component isolation
source lib/components/your_component.sh
collect_your_component_data
render_your_component
```

### Error Testing
- Test with missing dependencies
- Test with invalid configurations
- Test with corrupted cache files
- Test with network timeouts (for MCP components)

## Performance Considerations

### Caching
- Use caching for expensive operations
- Set appropriate cache durations
- Consider project isolation needs

### Timeouts
- Set reasonable timeouts for external commands
- Provide fallbacks when timeouts occur

### Resource Usage
- Minimize subprocess creation
- Use efficient string operations
- Cache command existence checks

## Pull Request Process

1. **Update** documentation for any new features
2. **Test** on multiple platforms if possible
3. **Include** examples of new functionality
4. **Link** to any related issues
5. **Be responsive** to review feedback

### PR Title Format
```
🎨 feat: Add context usage component with dynamic thresholds
🐛 fix: Resolve cache corruption on paths with dots
📝 docs: Add comprehensive theming guide
```

### PR Description
Include:
- What changes were made and why
- How to test the changes
- Screenshots for visual changes
- Breaking changes (if any)

## Getting Help

- **Issues**: Use GitHub issues for bugs and feature requests
- **Discussions**: Use GitHub discussions for questions and ideas
- **Documentation**: Check the README.md for comprehensive guidance

## Recognition

Contributors will be recognized in:
- GitHub contributors list
- Release notes for significant contributions
- README acknowledgments section

Thank you for contributing to make Claude Code statuslines awesome! 🎉