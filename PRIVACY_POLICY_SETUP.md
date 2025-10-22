# Privacy Policy URL Setup Guide

## Recommended: GitHub Pages (FREE)

Your privacy policy is ready at `docs/index.html`. Follow these steps:

### 1. Create a GitHub Repository

```bash
cd /Users/daneweickert/code/personal/fitness/OfflineWorkout
git add docs/
git commit -m "Add privacy policy for App Store submission"
```

### 2. Push to GitHub

Create a new repository on GitHub (https://github.com/new):
- Repository name: `offlineworkout` (or any name you prefer)
- Make it **Public** (required for free GitHub Pages)
- Don't initialize with README (you already have files)

Then push:
```bash
git remote add origin https://github.com/YOUR_USERNAME/offlineworkout.git
git branch -M main
git push -u origin main
```

### 3. Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** → **Pages**
3. Under "Source", select:
   - Branch: `main`
   - Folder: `/docs`
4. Click **Save**

### 4. Get Your URL

After a few minutes, your privacy policy will be live at:
```
https://YOUR_USERNAME.github.io/offlineworkout/
```

**Use this URL in your App Store Connect submission.**

---

## Alternative: Firebase Hosting (FREE)

If you prefer Google Cloud:

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Login and Initialize
```bash
firebase login
cd /Users/daneweickert/code/personal/fitness/OfflineWorkout
firebase init hosting
```

Select:
- Create new project or use existing
- Public directory: `docs`
- Single-page app: No
- GitHub integration: Optional

### 3. Deploy
```bash
firebase deploy --only hosting
```

Your URL will be: `https://YOUR_PROJECT_ID.web.app/`

---

## Cost Comparison

- **GitHub Pages**: FREE (public repos)
- **Firebase Hosting**: FREE (10GB storage, 360MB/day transfer)
- **Cloud Storage**: ~$0.026/month (storage) + minimal bandwidth costs

## Recommendation

Use **GitHub Pages** - it's completely free, reliable, and won't be shut down as long as your GitHub account exists.

