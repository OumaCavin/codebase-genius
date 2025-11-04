# Codebase Genius - Live Demo Deployment Package

![Status](https://img.shields.io/badge/Status-Ready_for_Deployment-green)
![Backend](https://img.shields.io/badge/Backend-Vercel-black)
![Frontend](https://img.shields.io/badge/Frontend-Streamlit_Cloud-red)
![License](https://img.shields.io/badge/License-MIT-blue)

Complete deployment package for Codebase Genius multi-agent AI system with working frontend and backend integration.

## Live Demo Architecture

```
┌─────────────────────────────────────────────────┐
│                   User Browser                  │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│          Streamlit Cloud (Frontend)             │
│  • Interactive web interface                    │
│  • Real-time progress tracking                  │
│  • Results visualization                        │
│  • File analysis dashboard                      │
└────────────────────┬────────────────────────────┘
                     │ HTTPS API Calls
                     ▼
┌─────────────────────────────────────────────────┐
│      Vercel Serverless Functions (Backend)      │
│  • 8 API endpoints                              │
│  • Repository validation                        │
│  • Documentation generation                     │
│  • Workflow management                          │
└─────────────────────────────────────────────────┘
```

## Features

- **Multi-Agent AI System**: 4 specialized agents working cooperatively
- **8 API Endpoints**: Complete RESTful API for all operations
- **Real-time Progress**: Live workflow status tracking
- **Multiple Formats**: Markdown, HTML, PDF documentation output
- **Multi-Platform**: GitHub, GitLab, Bitbucket support
- **Responsive UI**: Modern, user-friendly interface
- **Production Ready**: Deployed on enterprise platforms

## Quick Links

- **Documentation**: See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **Quick Start**: See [QUICK_START.md](QUICK_START.md)
- **AI Integration**: See [AI_AGENTS_INTEGRATION.md](AI_AGENTS_INTEGRATION.md)
- **API Reference**: See [API_ENDPOINTS.md](API_ENDPOINTS.md)

## File Structure

```
codebase-genius-live-demo/
├── api/                          # Vercel Serverless Backend
│   ├── index.py                  # Entry point with CORS config
│   └── routes.py                 # FastAPI routes (8 endpoints)
│
├── streamlit_app.py              # Streamlit Cloud Frontend
│
├── .streamlit/                   # Streamlit Configuration
│   └── config.toml               # Theme and server settings
│
├── requirements.txt              # Backend dependencies (Vercel)
├── requirements-streamlit.txt    # Frontend dependencies (Streamlit)
├── vercel.json                   # Vercel deployment config
│
├── DEPLOYMENT_GUIDE.md           # Complete deployment instructions
├── QUICK_START.md                # Quick start for users
├── AI_AGENTS_INTEGRATION.md      # Guide to integrate actual AI agents
├── API_ENDPOINTS.md              # API documentation
├── README.md                     # This file
│
├── deploy-backend.sh             # Backend deployment script
├── test-api.sh                   # API testing script
│
├── .gitignore                    # Git ignore rules
└── LICENSE                       # MIT License
```

## API Endpoints (8 Total)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Root health check |
| `/health` | GET | Detailed health status |
| `/api/analyze` | POST | Start repository analysis |
| `/api/status/{workflow_id}` | GET | Get workflow status |
| `/api/workflows` | GET | List all workflows |
| `/api/download/{workflow_id}` | GET | Download documentation |
| `/api/workflows/{workflow_id}` | DELETE | Delete workflow |
| `/api/config` | GET | Get API configuration |

## Deployment Instructions

### Prerequisites

- GitHub account
- Vercel account: https://vercel.com (free tier)
- Streamlit Cloud account: https://share.streamlit.io (free tier)

### Step 1: Prepare Repository

```bash
# Navigate to deployment directory
cd /workspace/codebase-genius-live-demo

# Initialize git
git init
git add .
git commit -m "Initial commit: Codebase Genius live demo"

# Push to GitHub
git remote add origin https://github.com/OumaCavin/codebase-genius.git
git push -u origin main
```

### Step 2: Deploy Backend (Vercel)

**Option A: Vercel Dashboard**
1. Visit https://vercel.com/new
2. Import your GitHub repository
3. Click "Deploy"
4. Copy deployment URL

**Option B: Vercel CLI**
```bash
npm install -g vercel
vercel login
vercel --prod
```

### Step 3: Deploy Frontend (Streamlit Cloud)

1. Visit https://share.streamlit.io
2. Sign in with GitHub
3. Click "New app"
4. Select repository: `codebase-genius`
5. Main file: `streamlit_app.py`
6. Advanced settings → Add environment variable:
   - Key: `API_BASE_URL`
   - Value: `https://your-vercel-app.vercel.app`
7. Click "Deploy"

### Step 4: Test Deployment

```bash
# Test backend
curl https://your-vercel-app.vercel.app/health

# Run comprehensive tests
./test-api.sh https://your-vercel-app.vercel.app

# Open frontend
# Visit: https://your-app.streamlit.app
```

## Testing Guide

### 1. Health Check

```bash
curl https://your-vercel-app.vercel.app/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "...",
  "active_workflows": 0,
  "completed_workflows": 0
}
```

### 2. Start Analysis

```bash
curl -X POST https://your-vercel-app.vercel.app/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "repository_url": "https://github.com/pallets/flask",
    "branch": "main",
    "analysis_depth": "full",
    "format": "markdown"
  }'
```

### 3. Check Status

```bash
curl https://your-vercel-app.vercel.app/api/status/{workflow_id}
```

### 4. Download Results

```bash
curl https://your-vercel-app.vercel.app/api/download/{workflow_id} \
  --output documentation.zip
```

## Frontend Features

### Pages

1. **New Analysis**: Start repository documentation generation
2. **Status**: Real-time workflow progress tracking
3. **Results**: View and download generated documentation
4. **About**: System information and agent details

### Visualizations

- File type distribution (pie chart)
- Progress tracking (progress bar + polar chart)
- File analysis table (sortable, filterable)
- Documentation preview (markdown rendering)

## Configuration

### Environment Variables

**Vercel (Backend)**
- None required (configured in vercel.json)

**Streamlit Cloud (Frontend)**
- `API_BASE_URL`: Your Vercel backend URL (required)

### Customization

**Theme Colors** (`.streamlit/config.toml`):
```toml
[theme]
primaryColor="#667eea"
backgroundColor="#FFFFFF"
secondaryBackgroundColor="#F0F2F6"
textColor="#262730"
```

**API Configuration** (`api/routes.py`):
```python
# Adjust timeouts, limits, etc.
estimated_completion=300  # 5 minutes
max_concurrent_workflows=5
```

## Troubleshooting

### Issue: "API Server: Offline"

**Solution:**
1. Check Vercel deployment status
2. Verify `API_BASE_URL` in Streamlit Cloud settings
3. Test: `curl https://your-vercel-app.vercel.app/health`

### Issue: CORS Errors

**Solution:**
- CORS already configured for all origins
- Check browser console for specific error
- Verify API_BASE_URL is correct

### Issue: Timeout Errors

**Solution:**
- Vercel free tier: 10-second limit
- Use smaller repositories
- Consider Vercel Pro for longer timeouts

### Issue: Git Clone Fails

**Solution:**
- Ensure repository is public
- Check repository URL format
- Test locally: `git clone <url>`

## Performance Notes

### Free Tier Limits

**Vercel:**
- Execution time: 10 seconds
- Memory: 1024 MB
- Bandwidth: 100 GB/month

**Streamlit Cloud:**
- 1 app free
- 1 GB RAM per app
- Unlimited viewers

### Optimization Tips

1. Use depth="basic" for faster analysis
2. Limit repository size for demo
3. Implement caching for repeated analyses
4. Consider upgrade for production use

## AI Agents Integration

The current implementation includes a **simplified simulation**. To integrate the actual 4 AI agents:

1. See [AI_AGENTS_INTEGRATION.md](AI_AGENTS_INTEGRATION.md)
2. Copy agent files from `/workspace/deployment-package/agents/`
3. Update `api/routes.py` with agent imports
4. Update `requirements.txt` with agent dependencies
5. Redeploy to Vercel

## Success Checklist

- [ ] Repository pushed to GitHub
- [ ] Backend deployed to Vercel
- [ ] Backend health endpoint returns 200 OK
- [ ] All 8 API endpoints accessible
- [ ] Frontend deployed to Streamlit Cloud
- [ ] Frontend connects to backend successfully
- [ ] Test analysis completes end-to-end
- [ ] Documentation download works
- [ ] Main README updated with demo links

## Support

- **Author**: Cavin Otieno
- **Email**: otienocavin@gmail.com
- **GitHub**: https://github.com/OumaCavin/codebase-genius
- **Issues**: https://github.com/OumaCavin/codebase-genius/issues

## License

MIT License - Copyright (c) 2025 Cavin Otieno

See [LICENSE](LICENSE) file for details.

## Acknowledgments

- FastAPI for the excellent web framework
- Streamlit for the amazing frontend platform
- Vercel for serverless hosting
- Multi-agent AI architecture patterns

---

**Ready for Deployment!** Follow the guides above to launch your live demo.

For detailed instructions, see [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
