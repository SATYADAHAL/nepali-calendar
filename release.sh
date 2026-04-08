#!/bin/bash

# Automated Release Script for Nepali Calendar Plasmoid
# Usage: ./release.sh v1.2.3

set -e  # Exit on error

VERSION="$1"

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v1.2.3"
    exit 1
fi

# Validate version format
if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format v1.2.3"
    exit 1
fi

echo "Starting release process for $VERSION"

# Check if we're in a clean git state
if [[ -n "$(git status --porcelain)" ]]; then
    echo "Warning: You have uncommitted changes."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Make sure we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
    echo "Switching to main branch..."
    git checkout main
    git pull origin main
fi

# Update version in metadata.json if it exists
VERSION_NO_V="${VERSION#v}"
if [[ -f "package/metadata.json" ]]; then
    echo "Updating metadata.json version to $VERSION_NO_V"
    sed -i "s/\"Version\": \".*\"/\"Version\": \"$VERSION_NO_V\"/" package/metadata.json
    git add package/metadata.json
fi

# Build the package
echo "Building plasmoid package..."
./build.sh

# Commit version update if metadata was changed
if [[ -f "package/metadata.json" ]] && git diff --cached --quiet; then
    echo "No version changes to commit"
elif [[ -f "package/metadata.json" ]]; then
    echo "Committing version update..."
    git commit -m "chore: bump version to $VERSION"
fi

# Create and push release branch
RELEASE_BRANCH="release/$VERSION"
echo "Creating release branch $RELEASE_BRANCH"
git checkout -b "$RELEASE_BRANCH"

echo "Pushing release branch..."
git push origin "$RELEASE_BRANCH"

echo ""
echo "Release $VERSION initiated!"
echo ""
echo "GitHub Actions will now:"
echo "   1. Build the plasmoid package"
echo "   2. Create GitHub release with changelog"  
echo "   3. Upload binary artifacts"
echo "   4. Prepare KDE store materials"
echo ""
echo "Manual steps remaining:"
echo "   1. Wait for GitHub Actions to complete"
echo "   2. Go to GitHub releases and verify"
echo "   3. Download KDE store description and binary"
echo "   4. Upload to KDE store manually"
echo ""
echo "Monitor progress at:"
echo "   https://github.com/$(git config --get remote.origin.url | sed 's/.*github\.com[:/]\(.*\)\.git/\1/')/actions"
echo ""
echo "Note: You can delete the release branch after the release is complete:"
echo "   git checkout main && git branch -D $RELEASE_BRANCH && git push origin --delete $RELEASE_BRANCH"