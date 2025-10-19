# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.12.0] - 2025-10-19

### Changed
- **Sync Status Always Visible**: Git sync status indicators (↑N ↓N) now remain visible at all times, providing consistent feedback about branch sync state
  - Previously: Sync status would disappear when synced or when no upstream tracking existed
  - Now: Always displays sync indicators, dimmed for visual consistency with file change indicators
  - Improved user experience with persistent sync state visibility

### Added
- **N/A Display for No-Remote Branches**: Branches without remote tracking now display "N/A" instead of "↑0 ↓0"
  - Clear differentiation between "synced with remote" (↑0 ↓0) and "no remote tracking" (N/A)
  - Helps developers quickly identify local-only branches
  - Consistent with Git Flow workflow patterns

### Fixed
- **Sync Status Display Logic**: Resolved issue where sync status would not appear for branches with no upstream tracking
  - Fixed conditional logic to always show sync status regardless of remote state
  - Ensures sync indicators match the visual consistency of file change indicators

### Documentation
- **Updated README**: Comprehensive documentation updates for sync status behavior
  - Line 1 example updated to show always-visible dimmed sync status
  - gitflow_info component documentation clarified
  - Added explanations for N/A vs ↑0 ↓0 display states

## [2.11.0] - 2025-10-19

### Added
- **Git Flow Enhanced Display**: New `gitflow_info` component with comprehensive Git Flow support
  - Branch type detection with dynamic icons (🌿 feature, 🚀 release, 🔥 hotfix, 🏠 main, 🔀 develop)
  - Sync status indicators (↑ ahead, ↓ behind of remote)
  - File change counts (● modified, ✚ added, ✖ deleted, ? untracked)
  - Merge target display (🎯 → shows where branch will merge)
- New Git Flow helper functions in `lib/git.sh`:
  - `get_git_flow_branch_type()` - Detects branch type and returns appropriate icon
  - `get_git_flow_merge_target()` - Determines merge destination based on Git Flow conventions
  - `get_git_sync_status()` - Compact ahead/behind sync status
  - `get_git_file_changes()` - File change counts in statusline format

### Changed
- Replaced `git_branch` component with enhanced `gitflow_info` component in default layout
- All Git Flow icons are properly dimmed for visual consistency
- Branch names maintain brown color (#7F5632) for consistency
- Git Flow information properly separated with ･ delimiters

## [2.10.1] - 2025-10-19

### Added
- Git Flow workflow structure with develop branch
- CHANGELOG.md for version tracking following Keep a Changelog format
- Conventional commit message enforcement via git hooks
- Semantic versioning compliance

### Changed
- Remove .DS_Store from git tracking (already in .gitignore)

## [2.10.0] - 2025-09-19

### Changed
- Remove backup file and clean up README formatting
- Update README to match actual statusline implementation
- Remove emojis from section headers for cleaner navigation
- Update statusline example to show data format
- Add visual screenshot to README

### Added
- Add comprehensive repository metadata and enhanced README

## [2.9.0] - 2025-09-18

### Added
- Remove 15k system overhead from context usage calculation
- Reorder line 2 components for better workflow priority

### Fixed
- Update display.sh context usage thresholds to match component logic

### Changed
- Adjust context usage color thresholds to 35%/60% boundaries

## Earlier Versions

For changes prior to 2.9.0, please refer to the git commit history.

[Unreleased]: https://github.com/jakreymyers/awesome-claude-statusline/compare/v2.12.0...HEAD
[2.12.0]: https://github.com/jakreymyers/awesome-claude-statusline/compare/v2.11.0...v2.12.0
[2.11.0]: https://github.com/jakreymyers/awesome-claude-statusline/compare/v2.10.1...v2.11.0
[2.10.1]: https://github.com/jakreymyers/awesome-claude-statusline/compare/v2.10.0...v2.10.1
[2.10.0]: https://github.com/jakreymyers/awesome-claude-statusline/compare/v2.9.0...v2.10.0
[2.9.0]: https://github.com/jakreymyers/awesome-claude-statusline/releases/tag/v2.9.0
