# GitHub Actions Build Guide for MyLifePair Matrimony

This guide explains how to build your Flutter APK using GitHub Actions without needing Android SDK locally.

## 🚀 Quick Start

### 1. Push Project to GitHub

```bash
# Initialize git repository
git init

# Add all files
git add .

# Commit changes
git commit -m "Initial commit - MyLifePair Matrimony Flutter App"

# Create GitHub repository and push
git remote add origin https://github.com/yourusername/MyLifeApp.git
git branch -M main
git push -u origin main
```

### 2. Automatic Build Triggers

Once you push to GitHub, the build will automatically start for:
- **Push to main/develop branches** - Builds debug and release APKs
- **Pull requests to main** - Builds for testing
- **Manual trigger** - Click "Run workflow" in GitHub Actions tab

## 📦 Build Workflows

### Workflow 1: Standard Build (build-apk.yml)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual trigger from GitHub UI

**Builds:**
- Debug APK (unsigned)
- Release APK (unsigned)
- App Bundle AAB (unsigned)

**Output:**
- `debug-apk` artifact
- `release-apk` artifact  
- `release-aab` artifact

### Workflow 2: Signed Release Build (build-signed-release.yml)

**Triggers:**
- Push tags like `v1.0.0`, `v1.0.1`, etc.
- Manual trigger from GitHub UI

**Builds:**
- Signed Release APK
- Signed App Bundle AAB

**Output:**
- `signed-release-apk` artifact
- `signed-release-aab` artifact

## 🔐 Setting Up Signed Builds

### 1. Generate Keystore Locally

You'll need to generate a keystore file once (requires Android SDK or use online tools):

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Encode Keystore to Base64

```bash
# On Linux/Mac
base64 -i upload-keystore.jks | pbcopy

# On Windows
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Set-Clipboard
```

### 3. Add Secrets to GitHub

Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret

Add these secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `KEYSTORE_FILE` | Base64 encoded keystore file | (paste base64 string) |
| `STORE_PASSWORD` | Keystore store password | your_store_password |
| `KEY_PASSWORD` | Keystore key password | your_key_password |

### 4. Trigger Signed Build

**Option A: Tag-based trigger**
```bash
git tag v1.0.0
git push origin v1.0.0
```

**Option B: Manual trigger**
1. Go to Actions tab in GitHub
2. Select "Build Signed Release APK"
3. Click "Run workflow"
4. Select branch and click "Run workflow"

## 📥 Downloading Build Artifacts

### From GitHub UI:

1. Go to your repository
2. Click "Actions" tab
3. Select the workflow run
4. Scroll to "Artifacts" section
5. Download the desired artifact

### Using GitHub CLI:

```bash
# Install GitHub CLI
# Download from: https://cli.github.com/

# List artifacts
gh run list

# Download specific artifact
gh run download <run-id> -n debug-apk
```

## 🔄 Workflow Details

### Standard Build Workflow

```yaml
- Checkout code
- Setup Java 17
- Setup Flutter 3.32.0
- Get dependencies
- Build debug APK
- Build release APK
- Build app bundle
- Upload artifacts
```

### Signed Build Workflow

```yaml
- Checkout code
- Setup Java 17
- Setup Flutter 3.32.0
- Decode keystore from secrets
- Create key.properties
- Get dependencies
- Build signed release APK
- Build signed app bundle
- Upload artifacts
```

## 🎯 Build Scenarios

### Development Builds
```bash
# Push to develop branch
git checkout develop
git add .
git commit -m "Feature: Add new functionality"
git push origin develop
```
→ Automatically builds debug APK

### Release Candidates
```bash
# Push to main branch
git checkout main
git merge develop
git push origin main
```
→ Automatically builds release APK

### Production Release
```bash
# Tag for signed release
git tag v1.0.0
git push origin v1.0.0
```
→ Builds signed APK and AAB

### Manual Build
1. Go to Actions tab
2. Select workflow
3. Click "Run workflow"
4. Choose branch
5. Click "Run workflow"

## 📊 Monitoring Builds

### View Build Status:
- GitHub Actions tab in repository
- Green checkmark = success
- Red X = failure

### View Build Logs:
- Click on workflow run
- Click on specific job
- Expand steps to see logs

### Build Time:
- Standard build: ~5-10 minutes
- Signed build: ~5-10 minutes

## 🐛 Troubleshooting

### Build Fails:

**Common Issues:**
1. **Flutter version mismatch**
   - Check workflow uses Flutter 3.32.0
   - Update if needed

2. **Dependency conflicts**
   - Check `flutter pub get` output
   - Update dependencies in pubspec.yaml

3. **Gradle build fails**
   - Check Android build configuration
   - Verify build.gradle files

4. **Keystore issues (signed builds)**
   - Verify secrets are set correctly
   - Check keystore password is correct
   - Ensure base64 encoding is proper

### Debug Failed Builds:

1. Go to Actions tab
2. Click on failed workflow run
3. Click on failed job
4. Expand failed step
5. Review error logs
6. Fix issue locally
7. Push fix to trigger new build

## 🔧 Customization

### Change Flutter Version:

Edit `.github/workflows/build-apk.yml`:
```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.32.0'  # Change this
    channel: 'stable'
```

### Add More Build Variants:

Add to workflow:
```yaml
- name: Build Profile APK
  run: flutter build apk --profile
```

### Change Artifact Retention:

Edit workflow:
```yaml
- name: Upload Debug APK
  uses: actions/upload-artifact@v4
  with:
    name: debug-apk
    path: build/app/outputs/flutter-apk/app-debug.apk
    retention-days: 30  # Change this
```

## 🚀 Advanced Features

### Automatic Release Creation:

Add to workflow:
```yaml
- name: Create Release
  uses: softprops/action-gh-release@v1
  with:
    files: |
      build/app/outputs/flutter-apk/app-release.apk
      build/app/outputs/bundle/release/app-release.aab
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Deploy to Firebase App Distribution:

Add to workflow:
```yaml
- name: Upload to Firebase App Distribution
  uses: wzieba/Firebase-Distribution-Github-Action@v1
  with:
    appId: ${{ secrets.FIREBASE_APP_ID }}
    serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_CREDENTIALS }}
    groups: testers
    file: build/app/outputs/flutter-apk/app-release.apk
```

### Send Notifications:

Add to workflow:
```yaml
- name: Send Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Build completed'
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

## 📋 Best Practices

### 1. Branch Strategy
- `main` - Production-ready code
- `develop` - Development branch
- `feature/*` - Feature branches
- `hotfix/*` - Emergency fixes

### 2. Commit Messages
- Use conventional commits
- Be descriptive
- Reference issues if applicable

### 3. Tagging
- Use semantic versioning: `v1.0.0`
- Tag only release-ready code
- Annotate tags with release notes

### 4. Secrets Management
- Never commit secrets
- Rotate passwords regularly
- Use environment-specific secrets
- Limit secret access

### 5. Build Optimization
- Use caching (already configured)
- Parallelize when possible
- Only build what's needed
- Clean up old artifacts

## 🎉 Benefits of GitHub Actions Build

### No Local Android SDK Needed
- Build in the cloud
- No local setup required
- Consistent build environment

### Automated Builds
- Build on every push
- Automatic testing
- Continuous integration

### Easy Distribution
- Download artifacts from GitHub
- Share with team
- Deploy to stores

### Free for Public Repositories
- Unlimited minutes
- Free artifact storage
- No cost for open source

### Version Control Integration
- Build history per commit
- Easy rollback
- Traceability

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter Action](https://github.com/marketplace/actions/setup-flutter)
- [GitHub Actions for Flutter](https://flutter.dev/docs/deployment/cd#github-actions)
- [Artifact Management](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts)

## ✅ Checklist

Before using GitHub Actions builds:

- [ ] Repository created on GitHub
- [ ] Code pushed to GitHub
- [ ] Workflow files committed
- [ ] Secrets configured (for signed builds)
- [ ] Test build triggered successfully
- [ ] Artifacts downloadable
- [ ] Build process understood

## 🎯 Next Steps

1. **Push code to GitHub**
2. **Verify automatic build triggers**
3. **Download and test debug APK**
4. **Set up secrets for signed builds**
5. **Create release tag for signed APK**
6. **Download signed APK for Play Store**

---

**Generated with [Devin](https://devin.ai)**

**Co-Authored-By: Devin <158243242+devin-ai-integration[bot]@users.noreply.github.com>**