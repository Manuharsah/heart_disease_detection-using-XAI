# How to Get GitHub Personal Access Token

## Step-by-Step Guide

### Step 1: Go to GitHub Token Settings
**Direct Link:** https://github.com/settings/tokens

Or navigate manually:
1. Go to https://github.com
2. Click your profile picture (top right)
3. Click **Settings**
4. Scroll down to **Developer settings** (left sidebar)
5. Click **Personal access tokens**
6. Click **Tokens (classic)**

### Step 2: Generate New Token
1. Click **"Generate new token"** button
2. Select **"Generate new token (classic)"**
3. Give it a name: `Heart Disease Project` (or any name you prefer)
4. Set expiration: Choose how long you want it to last (30 days, 90 days, or no expiration)
5. **Select scopes:** Check the box for **`repo`** (this gives full control of repositories)
   - This includes: repo:status, repo_deployment, public_repo, repo:invite, security_events
6. Scroll down and click **"Generate token"** (green button)

### Step 3: Copy the Token
⚠️ **IMPORTANT:** Copy the token immediately! It looks like: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

You will **NOT** be able to see it again after you leave this page!

### Step 4: Use the Token
When you run `git push -u origin main`, you'll be prompted:
- **Username:** Enter `Manuharsah`
- **Password:** Paste the token you just copied (NOT your GitHub password!)

---

## Quick Links

- **Token Settings:** https://github.com/settings/tokens
- **Generate Token:** https://github.com/settings/tokens/new

---

## Alternative: Use GitHub CLI (Easier)

If you prefer, you can use GitHub CLI instead:

```powershell
gh auth login
```

This will open a browser and handle authentication automatically!

