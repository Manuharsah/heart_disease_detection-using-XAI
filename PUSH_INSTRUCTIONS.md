# Push Instructions

## Summary of Fixes

All errors have been fixed:

1. ✅ **Updated .gitignore** - Properly excludes large files (CSV, PKL) while keeping necessary ones
2. ✅ **Removed hardcoded API key** - Now uses environment variables for security
3. ✅ **Fixed hardcoded paths** - Uses relative paths with `os.path.join()` for cross-platform compatibility
4. ✅ **Cleaned up main.dart** - Removed extra text at end of file
5. ✅ **Created requirements.txt** - Added all backend dependencies
6. ✅ **Updated README.md** - Comprehensive documentation with setup instructions
7. ✅ **Removed large files from git history** - Used git filter-branch to remove files exceeding GitHub's 100MB limit

## Large Files Removed from History

- `heart_2022_with_nans.csv` (132.97 MB)
- `backend/models/final_best_model.pkl` (1117.60 MB)

These files are now properly ignored by `.gitignore` and won't be tracked.

## To Push to GitHub

The push failed due to authentication. You need to:

### Option 1: Use GitHub CLI (Recommended)
```bash
gh auth login
git push origin main --force
```

### Option 2: Use Personal Access Token
1. Go to GitHub Settings > Developer settings > Personal access tokens
2. Generate a new token with `repo` permissions
3. Use the token as password when pushing:
```bash
git push origin main --force
```

### Option 3: Use SSH
```bash
git remote set-url origin git@github.com:Manuharsah/heart_disease_detection-using-XAI.git
git push origin main --force
```

## Important Notes

⚠️ **Force Push Required**: Since we rewrote git history to remove large files, a force push is necessary.

⚠️ **Large Model File**: The `final_best_model.pkl` file (1.1GB) cannot be stored in GitHub. Users will need to:
- Download it separately, or
- Train the model using the provided Jupyter notebook

⚠️ **Environment Variables**: Create a `.env` file in the `backend` directory with:
```
CLAUDE_API_KEY=your_api_key_here
```

## Current Status

All code errors are fixed. The repository is ready to push once authentication is configured.

