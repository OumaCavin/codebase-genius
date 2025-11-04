# Manual Deployment Instructions

## Backend Deployment to Vercel

### Step 1: Deploy to Vercel via Web Interface

1. **Go to Vercel Dashboard:**
   - Visit: https://vercel.com/new
   - Sign in to your Vercel account

2. **Import Repository:**
   - Click "Import Project"
   - Select: `OumaCavin/codebase-genius`
   - Click "Import"

3. **Configure Deployment:**
   - **Project Name:** `codebase-genius-api`
   - **Framework Preset:** Other
   - **Root Directory:** `/` (use root of repository)
   - **Build Command:** Leave blank (using vercel.json)
   - **Output Directory:** Leave blank

4. **Environment Variables (Optional):**
   - If deploying full mode: Add `MODE=full`
   - If deploying quick mode: Add `MODE=quick` (default)

5. **Deploy:**
   - Click "Deploy"
   - Wait for deployment to complete
   - Note your Vercel URL: `https://your-app.vercel.app`

### Step 2: Test Backend API

**Test Health Endpoint:**
```bash
curl https://your-app.vercel.app/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "agents_available": true,
  "mode": "quick"
}
```

## Frontend Deployment to Streamlit Cloud

### Step 1: Deploy to Streamlit Cloud

1. **Go to Streamlit Cloud:**
   - Visit: https://share.streamlit.io
   - Sign in with your GitHub account

2. **New App:**
   - Click "New app"
   - Repository: `OumaCavin/codebase-genius`
   - Main file: `streamlit_app.py`
   - Branch: `main`

3. **Environment Variables:**
   - **API_BASE_URL:** `https://your-vercel-app.vercel.app`
   - (Replace with your actual Vercel URL)

4. **Deploy:**
   - Click "Deploy"
   - Wait for deployment
   - Note your Streamlit URL: `https://your-app.streamlit.app`

### Step 2: Test Frontend

1. **Visit the Streamlit URL**
2. **Test Functionality:**
   - Enter a repository URL (e.g., https://github.com/pallets/flask)
   - Click "Analyze Repository"
   - Verify results appear

## API Endpoints Available

After deployment, these endpoints will be available:

- `GET /health` - Health check
- `GET /api/status` - API status
- `POST /api/analyze` - Analyze repository
- `GET /api/analyze/{task_id}/status` - Get analysis status
- `GET /api/analyze/{task_id}/result` - Get analysis result
- `DELETE /api/analyze/{task_id}` - Cancel analysis
- `POST /api/download/{task_id}` - Download results
- `GET /api/modes` - Available analysis modes

## Testing Commands

### Quick Mode Test
```bash
curl -X POST https://your-app.vercel.app/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "repository_url": "https://github.com/pallets/flask",
    "mode": "quick"
  }'
```

### Full Mode Test (if available)
```bash
curl -X POST https://your-app.vercel.app/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "repository_url": "https://github.com/pallets/flask",
    "mode": "full"
  }'
```

## Troubleshooting

### Backend Issues
- **Timeout:** Switch to quick mode for Vercel free tier
- **Import Errors:** Check requirements.txt and agent paths
- **CORS Errors:** Verify API_BASE_URL in Streamlit environment variables

### Frontend Issues
- **API Connection:** Check API_BASE_URL environment variable
- **Loading Issues:** Verify Vercel deployment is successful
- **Analysis Failures:** Test with smaller repositories first

## Deployment URLs Template

After successful deployment, update these placeholders:

**Backend API:** `https://your-app.vercel.app`
**Frontend App:** `https://your-app.streamlit.app`

## Production Checklist

- [ ] Backend deployed to Vercel
- [ ] Frontend deployed to Streamlit Cloud
- [ ] Health endpoint returns success
- [ ] API endpoints respond correctly
- [ ] Frontend can connect to backend
- [ ] Analysis works with test repository
- [ ] Download functionality works
- [ ] No timeout errors in quick mode
- [ ] CORS properly configured

---

**Status:** Ready for Manual Deployment
**Repository:** https://github.com/OumaCavin/codebase-genius
**Documentation:** See DEPLOY_WITH_AGENTS.md for full details
