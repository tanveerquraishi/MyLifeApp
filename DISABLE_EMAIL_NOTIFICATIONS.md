# How to Disable Email Notifications for Failed GitHub Actions Builds

To disable email notifications for failed GitHub Actions builds, you need to configure your GitHub repository settings.

## Method 1: Repository Settings (Recommended)

1. **Go to your GitHub repository**
2. **Click Settings** (top right)
3. **Click Notifications** (left sidebar)
4. **Under "Actions" section:**
   - Uncheck "Send email notifications for failed workflows"
   - Or select "None" for workflow notifications

## Method 2: Personal Notification Settings

1. **Go to GitHub Settings** (click your profile picture → Settings)
2. **Click Notifications** (left sidebar)
3. **Under "Actions" section:**
   - Choose "None" or customize your preferences
   - You can also disable notifications for specific repositories

## Method 3: Using GitHub CLI

```bash
# Install GitHub CLI if not already installed
# Then run:

gh api repos/YOUR_USERNAME/MyLifeApp/notifications \
  --method PUT \
  -f '{"notifications": {"workflow_failures": false}}'
```

## Method 4: Workflow-Level Control (Limited)

Unfortunately, GitHub doesn't provide workflow-level control for email notifications through YAML configuration. The closest you can do is:

- Use `if: success()` conditions (but this prevents the workflow from running on failures)
- Use repository-level settings as shown in Method 1

## Quick Fix for Now

The most reliable method is **Method 1** - go to your repository settings and disable workflow failure notifications there.

## Alternative: Use Slack/Discord Notifications

Instead of email, you can set up Slack or Discord notifications for build status:

```yaml
# Add to your workflow
- name: Send Slack notification
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Build failed'
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

This way you get notifications in a chat app instead of email.

---

**For immediate relief from email spam, use Method 1 (Repository Settings).**