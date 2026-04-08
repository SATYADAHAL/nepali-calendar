# Release Guide

This project uses branch-based automated releases. Here are the different ways to trigger a release:

## 1. Release Script (Recommended)
```bash
# Simple one-command release
./release.sh v1.2.3
```
This script will:
- Update version in metadata.json
- Commit the change
- Create and push a release branch
- GitHub Actions automatically triggers and creates the release

## 2. Manual Branch Creation
```bash
# Create and push release branch manually
git checkout main
git pull origin main
git checkout -b release/v1.2.3
git push origin release/v1.2.3
```
GitHub Actions triggers automatically when you push to `release/*` branches.

## 3. Manual Release
Go to GitHub Actions → Release Automation → Run workflow and enter version manually.

## What Gets Automated
- Building the plasmoid package
- Creating GitHub release with changelog
- Uploading binary artifacts
- Generating KDE store materials

## Manual Steps Still Needed
- Upload to KDE Store website (they don't have an API)

## Files Explained

### release.sh
Local helper script to create release branches and trigger automation.

### release-notes.sh  
Helper to create/edit release notes for specific versions.

### .github/workflows/release.yml
The actual automation that runs when release branches are pushed.

## Current Setup
Your workflow triggers on:
- Branches matching `release/**` (like release/v1.2.3)
- Manual dispatch from GitHub Actions UI

## Cleanup After Release
After a successful release, you can clean up the release branch:
```bash
git checkout main
git branch -D release/v1.2.3
git push origin --delete release/v1.2.3
```

This gives you a clean branch-based release workflow.