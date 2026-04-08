#!/bin/bash

# Release Notes Helper Script
# Usage: ./release-notes.sh v1.2.3

VERSION="$1"

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v1.2.3"
    exit 1
fi

NOTES_FILE="release-notes/${VERSION}.md"

if [[ -f "$NOTES_FILE" ]]; then
    echo "Release notes for $VERSION already exist at $NOTES_FILE"
    read -p "Edit existing notes? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} "$NOTES_FILE"
    fi
else
    echo "Creating new release notes for $VERSION..."
    
    cat > "$NOTES_FILE" << 'EOF'
## New Features

### Major Features
- Feature 1: Description
- Feature 2: Description

### Improvements
- Improvement 1: Description
- Improvement 2: Description

## Bug Fixes

- Bug fix 1: Description
- Bug fix 2: Description

## UI/UX Changes

- UI change 1: Description
- UI change 2: Description

## Technical Changes

- Technical change 1: Description
- Technical change 2: Description

## Breaking Changes

- None - fully backward compatible

## For Users

Summary of what this release means for end users and why they should update.
EOF

    echo "Created template at $NOTES_FILE"
    echo "Opening editor..."
    ${EDITOR:-nano} "$NOTES_FILE"
fi

echo ""
echo "Release notes ready for $VERSION"
echo "File: $NOTES_FILE"
echo ""
echo "Next steps:"
echo "1. Review and customize the release notes"
echo "2. Run: ./release.sh $VERSION"
echo "3. Automation will include these notes in the GitHub release"