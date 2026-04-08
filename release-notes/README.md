# Release Notes Template

This directory contains version-specific release notes that will be included in automated releases.

## Usage

1. Create a file named after your version (e.g., `v1.2.3.md`)
2. Add detailed release notes in markdown format
3. The automation will include these notes in the GitHub release

## Example: `v1.2.3.md`

```markdown
## New Features
- Added configurable first day of week (Sunday/Monday)
- Smart weekend highlighting adapts to week layout
- User control for weekend highlighting colors

## Improvements
- Redesigned settings UI with radio buttons
- Better visual organization of configuration options
- More compact and intuitive layout

## Bug Fixes
- Fixed font updates when navigating months
- Corrected weekend highlighting for day headers
- Improved property binding consistency

## Breaking Changes
- None - fully backward compatible
```

## Automation Flow

When you push a tag or release branch, the automation:
1. Generates basic changelog from git commits
2. Looks for version-specific notes in this directory
3. Combines them into the final release description
4. Creates GitHub release with complete notes
5. Uploads the built plasmoid package