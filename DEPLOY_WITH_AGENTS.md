# FINAL DEPLOYMENT GUIDE - With Real AI Agents

## Integration Complete ✅

The actual 4 AI agents have been successfully integrated into the deployment package.

### What Changed

1. **Real AI Agents Integrated**
   - All 4 agents copied from original codebase
   - Supervisor Agent, Repository Mapper, Code Analyzer, DocGenie
   - Total: 3,312 lines of actual agent code

2. **Hybrid Architecture Implemented**
   - Quick Mode: Fits in Vercel's 10-second timeout
   - Full Mode: Uses real agents (requires longer timeout or external deployment)
   - Auto Mode: Intelligently selects based on repository size

3. **Enhanced API Routes**
   - `api/routes.py` now includes agent integration
   - Automatic mode selection
   - Background task processing
   - Proper error handling

### Deployment Options

#### Option 1: Quick Demo on Vercel Free Tier (Recommended)

This uses simplified processing that fits in 10-second timeout:

**Steps:**
1. Push to GitHub (use `requirements.txt` - minimal dependencies)
2. Deploy to Vercel
3. Deploy frontend to Streamlit Cloud
4. Test with small repositories

**Pros:**
- Zero cost
- Fast deployment
- Works immediately

**Cons:**
- Simplified analysis
- No full AI agent features

#### Option 2: Full AI Agents on Vercel Pro

Uses real AI agents with extended timeout:

**Steps:**
1. Upgrade to Vercel Pro ($20/month)
2. Use `requirements-full.txt`
3. Deploy with extended timeout (60 seconds)
4. Test with medium repositories

**Pros:**
- Real AI agents
- All features enabled
- Still serverless

**Cons:**
- Costs $20/month
- May still timeout on large repos

#### Option 3: Hybrid Deployment (Best for Production)

API on Vercel (quick mode) + Agents on separate service:

**Steps:**
1. Deploy API to Vercel (quick mode, free)
2. Deploy agents to Railway/Fly.io/Render
3. Configure API to call external agent service
4. No timeout limits

**Pros:**
- Free API tier
- Full agent features
- No timeout issues
- Scalable

**Cons:**
- More complex setup
- Agent service may have costs

### Quick Start: Deploy Now

#### Step 1: Choose Your Mode

```bash
cd /workspace/codebase-genius-live-demo

# For quick mode (Vercel free tier)
cp requirements.txt requirements-deploy.txt

# For full mode (Vercel Pro or external service)
cp requirements-full.txt requirements-deploy.txt
```

#### Step 2: Initialize Git and Push

```bash
git init
git add .
git commit -m "Codebase Genius live demo with real AI agents"
git remote add origin https://github.com/OumaCavin/codebase-genius.git
git push -u origin main
```

#### Step 3: Deploy Backend

**Vercel Dashboard:**
1. Go to https://vercel.com/new
2. Import repository
3. Environment variables (if using full mode):
   - `MODE=full` (for agent mode)
4. Deploy

**CLI:**
```bash
npm install -g vercel
vercel login
vercel --prod
```

Copy your Vercel URL: `https://your-app.vercel.app`

#### Step 4: Deploy Frontend

1. Go to https://share.streamlit.io
2. New app → Select repository
3. Main file: `streamlit_app.py`
4. Environment variable:
   - Key: `API_BASE_URL`
   - Value: `https://your-vercel-app.vercel.app`
5. Deploy

#### Step 5: Test

**Test Quick Mode:**
```bash
curl -X POST https://your-app.vercel.app/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "repository_url": "https://github.com/pallets/flask",
    "mode": "quick"
  }'
```

**Test Full Mode** (if agents available):
```bash
curl -X POST https://your-app.vercel.app/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "repository_url": "https://github.com/pallets/flask",
    "mode": "full"
  }'
```

### Local Testing

Test everything locally before deploying:

```bash
cd /workspace/codebase-genius-live-demo

# Install dependencies
pip install -r requirements-full.txt

# Start API server
python -m uvicorn api.routes:app --reload --port 8000

# In another terminal, test
curl http://localhost:8000/health

# Should show: "agents_available": true

# Test analysis
curl -X POST http://localhost:8000/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "repository_url": "https://github.com/pallets/flask",
    "mode": "full"
  }'
```

### Verifying Agent Integration

Check if agents are properly integrated:

```bash
# Check health endpoint
curl https://your-app.vercel.app/health

# Look for:
{
  "status": "healthy",
  "agents_available": true,  // Should be true if agents loaded
  "mode": "full"             // Or "quick" depending on deployment
}
```

### Agent Requirements

**System Requirements for Full Mode:**
- Python 3.9+
- Git installed
- 512MB+ RAM
- Tree-sitter support
- Graphviz (for diagrams)

**Vercel Limitations:**
- Free tier: 10s timeout (use quick mode)
- Pro tier: 60s timeout (full mode for small/medium repos)
- Package size: 50MB free, 250MB Pro

### Troubleshooting

#### Problem: "agents_available": false

**Solution 1:** Check if dependencies are installed
```bash
pip install -r requirements-full.txt
```

**Solution 2:** Verify agents directory exists
```bash
ls -la agents/
# Should show all 4 agent directories
```

#### Problem: Timeout on Vercel

**Solution:** Use quick mode or upgrade to Vercel Pro
```json
{
  "repository_url": "https://github.com/user/repo",
  "mode": "quick"  // Forces quick mode
}
```

#### Problem: Import errors

**Solution:** Check Python path
```python
# In api/routes.py, verify:
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'agents'))
```

### Performance Comparison

| Mode | Time | Memory | Features | Vercel Tier |
|------|------|--------|----------|-------------|
| Quick | 5-10s | <512MB | Basic analysis | Free |
| Full | 30-300s | 512MB-2GB | All AI agents | Pro/External |

### Production Checklist

- [ ] Agents integrated (check `agents/` directory)
- [ ] Requirements updated (use `requirements-full.txt` for full mode)
- [ ] API routes using hybrid architecture
- [ ] Mode selection implemented
- [ ] Local testing passed
- [ ] Pushed to GitHub
- [ ] Deployed to Vercel
- [ ] Deployed to Streamlit Cloud
- [ ] End-to-end test passed
- [ ] Health check shows agents_available: true (if full mode)
- [ ] Documentation updated with live demo URL

### What Users Get

**Quick Mode (Free):**
- Repository validation
- File structure analysis
- Basic documentation
- Download package
- Fast response (<10s)

**Full Mode (Pro/External):**
- All quick mode features PLUS:
- Deep code analysis (Tree-sitter)
- CCG (Code Context Graph)
- Comprehensive documentation
- Code relationship diagrams
- Quality metrics
- Multi-language support
- API documentation

### Next Steps

1. **Deploy Now:** Follow steps above
2. **Test Thoroughly:** Try multiple repositories
3. **Monitor Performance:** Check Vercel logs
4. **Gather Feedback:** Share with users
5. **Iterate:** Improve based on usage

### Support

- **Documentation:** See AGENTS_STATUS.md for detailed agent info
- **Issues:** https://github.com/OumaCavin/codebase-genius/issues
- **Email:** otienocavin@gmail.com

---

**Status:** Ready for Deployment with Real AI Agents ✅  
**Version:** 2.0.0  
**Date:** 2025-11-04
