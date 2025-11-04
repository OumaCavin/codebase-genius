# Complete Deployment Guide for Codebase Genius Live Demo

## Overview

This guide provides step-by-step instructions to deploy the Codebase Genius multi-agent AI system with:
- **Backend**: Vercel Serverless Functions
- **Frontend**: Streamlit Cloud

## Prerequisites

- GitHub account
- Vercel account (free tier available at https://vercel.com)
- Streamlit Cloud account (free tier available at https://share.streamlit.io)
- Git installed locally
- Node.js and npm installed (for Vercel CLI)

## Part 1: Backend Deployment (Vercel)

### Step 1: Prepare Repository

1. Push the `codebase-genius-live-demo` directory to a GitHub repository:

```bash
cd /workspace/codebase-genius-live-demo
git init
git add .
git commit -m "Initial commit - Codebase Genius live demo"
git remote add origin https://github.com/OumaCavin/codebase-genius.git
git push -u origin main
```

### Step 2: Deploy to Vercel

**Option A: Using Vercel Dashboard (Recommended)**

1. Go to https://vercel.com and sign in
2. Click "New Project"
3. Import your GitHub repository
4. Configure project:
   - **Framework Preset**: Other
   - **Root Directory**: `./` (keep as is)
   - **Build Command**: Leave empty
   - **Output Directory**: Leave empty
5. Click "Deploy"
6. Wait for deployment to complete
7. Note your deployment URL (e.g., `https://codebase-genius.vercel.app`)

**Option B: Using Vercel CLI**

```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy
cd /workspace/codebase-genius-live-demo
vercel --prod

# Note the deployment URL
```

### Step 3: Verify Backend

Test your API endpoints:

```bash
# Health check
curl https://your-app.vercel.app/health

# Expected response:
# {
#   "status": "healthy",
#   "timestamp": "...",
#   "active_workflows": 0,
#   "completed_workflows": 0
# }

# Config check
curl https://your-app.vercel.app/api/config
```

## Part 2: Frontend Deployment (Streamlit Cloud)

### Step 1: Update API Configuration

Before deploying, update the `streamlit_app.py` file with your Vercel URL:

```python
# Line 61 in streamlit_app.py
API_BASE_URL = os.getenv("API_BASE_URL", "https://your-vercel-app.vercel.app")
```

Or set it as an environment variable in Streamlit Cloud (preferred method).

### Step 2: Deploy to Streamlit Cloud

1. Go to https://share.streamlit.io
2. Sign in with GitHub
3. Click "New app"
4. Configure deployment:
   - **Repository**: Your GitHub repository
   - **Branch**: main (or your default branch)
   - **Main file path**: `streamlit_app.py`
5. Click "Advanced settings"
6. Add environment variable:
   - **Key**: `API_BASE_URL`
   - **Value**: `https://your-vercel-app.vercel.app`
7. Click "Deploy"
8. Wait for deployment to complete

### Step 3: Verify Frontend

1. Open your Streamlit app URL (e.g., `https://your-app.streamlit.app`)
2. Check that "API Server: Online" shows in the System Status
3. Test with a sample repository:
   - Enter: `https://github.com/OumaCavin/codebase-genius`
   - Click "Start Analysis"
   - Monitor progress

## Part 3: Testing End-to-End

### Test Workflow 1: GitHub Repository Analysis

1. Open your Streamlit app
2. Navigate to "New Analysis"
3. Enter repository URL: `https://github.com/pallets/flask`
4. Select:
   - Branch: main
   - Analysis Depth: full
   - Output Format: markdown
   - Include Diagrams: Yes
5. Click "Start Analysis"
6. Navigate to "Status" to monitor progress
7. Once completed, go to "Results" to view documentation
8. Download the generated documentation

### Test Workflow 2: API Direct Testing

```bash
# Start analysis
curl -X POST https://your-app.vercel.app/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "repository_url": "https://github.com/tornadoweb/tornado",
    "branch": "main",
    "analysis_depth": "full",
    "include_diagrams": true,
    "format": "markdown"
  }'

# Response will include workflow_id
# {"workflow_id": "abc-123-xyz", "status": "started", ...}

# Check status
curl https://your-app.vercel.app/api/status/abc-123-xyz

# Download documentation (after completion)
curl https://your-app.vercel.app/api/download/abc-123-xyz --output documentation.zip
```

## Part 4: Troubleshooting

### Common Issues

#### 1. "API Server: Offline" in Streamlit

**Solution:**
- Verify Vercel deployment is successful
- Check `API_BASE_URL` environment variable in Streamlit Cloud
- Test backend directly: `curl https://your-app.vercel.app/health`

#### 2. CORS Errors

**Solution:**
- Backend already configured with CORS allowing all origins
- If issues persist, check browser console for specific CORS errors

#### 3. Timeout Errors

**Solution:**
- Vercel free tier has 10-second execution limit for serverless functions
- For large repositories, may need Vercel Pro or implement async processing
- Current implementation uses background tasks to handle longer processing

#### 4. Git Clone Failures

**Solution:**
- Ensure repository URL is correct and public
- Check if repository requires authentication (not supported in demo)
- Verify Vercel has network access to clone repositories

### Monitoring and Logs

#### Vercel Logs

1. Go to Vercel dashboard
2. Select your project
3. Click "Functions" tab
4. View real-time logs for each API call

#### Streamlit Logs

1. Go to Streamlit Cloud dashboard
2. Select your app
3. Click "Manage app"
4. View logs in real-time

## Part 5: Updating Deployment

### Update Backend (Vercel)

```bash
# Make changes to code
git add .
git commit -m "Update: description"
git push origin main

# Vercel will automatically redeploy
```

### Update Frontend (Streamlit)

```bash
# Make changes to streamlit_app.py
git add .
git commit -m "Update: description"
git push origin main

# Streamlit Cloud will automatically redeploy
```

## Part 6: Environment Variables Reference

### Vercel Environment Variables (Optional)

- `PYTHON_VERSION`: Set to "3.9" (already configured in vercel.json)

### Streamlit Cloud Environment Variables (Required)

- `API_BASE_URL`: Your Vercel backend URL
  - Example: `https://codebase-genius-abc123.vercel.app`

## Part 7: Performance Optimization

### Backend Optimization

1. **Serverless Function Settings**:
   - Default timeout: 10 seconds
   - Max timeout (Pro): 60 seconds
   - Consider upgrading for large repositories

2. **Caching**:
   - Implement Redis for workflow state (optional)
   - Use Vercel KV for session storage (optional)

### Frontend Optimization

1. **Session State**:
   - Already implemented for workflow tracking
   - Persists across page reloads

2. **Auto-refresh**:
   - Status page auto-refreshes every 5 seconds
   - Adjustable in code if needed

## Part 8: Security Considerations

### Current Security Features

1. **Input Validation**: Repository URL format checking
2. **HTTPS**: Both platforms use HTTPS by default
3. **Rate Limiting**: Consider adding for production use
4. **Authentication**: Not implemented (public demo)

### Production Enhancements (Optional)

1. Add API key authentication
2. Implement rate limiting (e.g., using Upstash Rate Limit)
3. Add user authentication (e.g., OAuth)
4. Restrict CORS to specific domains

## Part 9: Cost Estimation

### Free Tier Limits

**Vercel Free Tier:**
- 100 GB-hours of serverless function execution
- 100 GB bandwidth per month
- Unlimited API requests

**Streamlit Cloud Free Tier:**
- 1 app with unlimited viewers
- 1 GB RAM per app
- Community support

**Estimated Usage:**
- Small repository analysis: ~5-10 seconds
- Medium repository: ~20-40 seconds
- Large repository: May exceed free tier limits

## Part 10: Documentation Updates

### Update Main Repository README

Update the following sections in the main repository:

1. **Live Demo Link**:
```markdown
🚀 **[View Live Demo](https://your-app.streamlit.app)** | 📚 **[API Documentation](https://your-app.vercel.app/docs)**
```

2. **Quick Links Section**:
```markdown
## Quick Links

- **Live Demo**: https://your-app.streamlit.app
- **API Backend**: https://your-app.vercel.app
- **API Docs**: https://your-app.vercel.app/docs
- **GitHub**: https://github.com/OumaCavin/codebase-genius
```

## Success Checklist

- [ ] Backend deployed to Vercel successfully
- [ ] Backend health endpoint returns 200 OK
- [ ] All 8 API endpoints accessible
- [ ] Frontend deployed to Streamlit Cloud
- [ ] Frontend can connect to backend
- [ ] Test repository analysis completes successfully
- [ ] Documentation download works
- [ ] README updated with correct URLs
- [ ] All 4 AI agents responding correctly (when implemented)
- [ ] Real-time progress tracking functional

## Support

For issues or questions:
- **Email**: otienocavin@gmail.com
- **GitHub Issues**: https://github.com/OumaCavin/codebase-genius/issues

## License

MIT License - Cavin Otieno

---

**Deployment Date**: 2025-11-04  
**Version**: 1.0.0  
**Author**: Cavin Otieno
