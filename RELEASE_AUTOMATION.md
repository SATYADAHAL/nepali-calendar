# Automated Release Workflow

Complete automation setup for releasing Nepali Calendar Plasmoid with minimal manual intervention.

## What Gets Automated

### Fully Automated
- **Building**: Plasmoid package compilation
- **GitHub Releases**: Creation with changelog
- **Binary Upload**: Automatic artifact attachment  
- **Versioning**: metadata.json updates
- **Changelog**: Generated from git commits + custom notes
- **KDE Store Prep**: Description and package preparation

### Manual Steps Required
- **KDE Store Upload**: Final binary upload (KDE store doesn't have API)
- **Release Notes**: Optional custom notes per version

## Release Process Options

### Option 1: Release Script (Recommended)
```bash
# Simple one-command release
./release.sh v1.2.3
```

**What happens:**
1. Updates `package/metadata.json` version
2. Commits version change
3. Creates and pushes release branch
4. GitHub Actions triggers automatically
5. Complete release created within minutes

### Option 2: Manual Branch Creation
```bash
# Create release branch manually
git checkout main
git checkout -b release/v1.2.3
git push origin release/v1.2.3
```

### Option 3: Manual Trigger
- Go to GitHub Actions → Release Automation → Run workflow
- Enter version number manually

## Project Structure

```
nepali-calendar/
├── .github/workflows/
│   └── release.yml           # Main automation workflow
├── release-notes/
│   ├── README.md            # Release notes guide
│   └── v1.2.3.md           # Optional version-specific notes
├── package/
│   └── metadata.json        # Auto-updated version
├── build.sh                 # Build script (used by automation)
├── release.sh              # Local release helper script
└── README.md
```

## Setup Instructions

### 1. Repository Setup
```bash
# Ensure these files are committed to your repo
git add .github/workflows/release.yml
git add release-notes/README.md  
git add release.sh
git commit -m "feat: add automated release workflow"
git push origin main
```

### 2. GitHub Permissions
- **GitHub Actions** should be enabled (default)
- **GITHUB_TOKEN** is automatically available (no setup needed)
- Ensure repository has **Write** permissions for Actions

### 3. First Release Test
```bash
# Test the workflow
./release.sh v1.0.0
```

## Release Notes System

### Basic (Automatic)
- Changelog generated from git commit messages
- Covers all changes since last tag
- No manual work required

### Enhanced (Optional)
Create `release-notes/v1.2.3.md`:
```markdown
## 🎉 Major Features
- New configurable first day of week
- Smart weekend highlighting

## 🐛 Bug Fixes  
- Fixed font update delays
- Corrected weekend colors

## 💔 Breaking Changes
- None - fully backward compatible
```

## Monitoring Releases

### GitHub Actions Dashboard
- Go to repository → Actions tab
- Monitor "Release Automation" workflow
- View logs, artifacts, and status

### Release Artifacts
Each release creates:
- **Main Package**: `nepali-calendar-1.2.3.plasmoid`
- **KDE Store Description**: `kde-store-description-1.2.3.md`
- **Release Notes**: Embedded in GitHub release

## KDE Store Integration

### Semi-Automated Process
1. Automated: Package built and prepared
2. Automated: Description generated with changelog
3. Manual: Download artifacts from GitHub release
4. Manual: Upload to KDE store website
5. Manual: Copy description from generated markdown

### Future Full Automation
KDE Store doesn't provide API, but you could potentially:
- Use browser automation (Selenium/Playwright)
- Create browser extension for one-click upload
- Wait for KDE to provide official API

## Workflow Configuration

### Trigger Events
```yaml
on:
  push:
    branches: ['release/**']     # release/v1.2.3 branches
  workflow_dispatch:            # Manual trigger
```

### Version Detection
- **Branch**: `release/v1.2.3` → version `v1.2.3` 
- **Manual**: User input version

### Build Process
1. Checkout code with full history
2. Update metadata.json version
3. Execute build.sh script
4. Generate changelog from commits
5. Create GitHub release
6. Upload plasmoid package
7. Prepare KDE store materials

## Customization

### Modify Workflow
Edit `.github/workflows/release.yml` to:
- Change trigger conditions
- Add additional build steps
- Modify artifact names
- Add notification integrations

### Add Notifications
```yaml
- name: Notify Discord/Slack
  if: success()
  run: |
    curl -X POST -H 'Content-type: application/json' \
    --data '{"text":"Released ${{ steps.version.outputs.version }}!"}' \
    ${{ secrets.DISCORD_WEBHOOK_URL }}
```

## Benefits

### Time Savings
- **Before**: 15-20 minutes of manual work per release
- **After**: 2 minutes + automated background processing

### Consistency  
- **Before**: Risk of forgetting steps, version mismatches
- **After**: Identical process every time, automated versioning

### Quality
- **Before**: Manual changelog writing, potential errors
- **After**: Automatic changelog from commits, structured format

### Scalability
- **Before**: Releases become more painful as project grows
- **After**: Same effort regardless of project complexity

## Troubleshooting

### Build Fails
- Check `build.sh` script works locally
- Verify all dependencies available in Ubuntu runner
- Check file permissions and paths

### Release Creation Fails
- Ensure tag doesn't already exist
- Check GITHUB_TOKEN permissions
- Verify repository settings allow Actions

### Version Update Fails
- Confirm `package/metadata.json` exists
- Check file format and JSON validity
- Verify sed command compatibility

This automation setup transforms releases from a tedious manual process into a simple one-command operation, while maintaining full control and customization options.