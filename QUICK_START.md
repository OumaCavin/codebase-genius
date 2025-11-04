# Quick Start Guide

## For Users: Try the Live Demo

1. **Open the Live Demo**:
   - Visit: [Streamlit App URL]
   
2. **Analyze a Repository**:
   - Click "New Analysis" in the sidebar
   - Enter a GitHub repository URL (e.g., `https://github.com/pallets/flask`)
   - Select options:
     - Branch: `main` (or any branch)
     - Analysis Depth: `full`
     - Output Format: `markdown`
     - Include Diagrams: ✓ Yes
   - Click "Start Analysis"

3. **Monitor Progress**:
   - Click "Status" in the sidebar
   - Watch real-time progress updates
   - See current step and completion percentage

4. **View Results**:
   - Click "Results" when analysis completes
   - Explore tabs:
     - **Overview**: Repository statistics and charts
     - **File Analysis**: Detailed file breakdown
     - **Documentation**: Generated documentation preview
     - **Downloads**: Download complete package

5. **Download Documentation**:
   - Click "Download Documentation" button
   - Receive ZIP file containing:
     - Main documentation (selected format)
     - Metadata JSON
     - Analysis results

## For Developers: Deploy Your Own Instance

### Prerequisites

- GitHub account
- Vercel account (free): https://vercel.com
- Streamlit Cloud account (free): https://share.streamlit.io

### Step 1: Fork Repository

```bash
# Fork on GitHub: https://github.com/OumaCavin/codebase-genius
# Clone your fork
git clone https://github.com/YOUR_USERNAME/codebase-genius.git
cd codebase-genius
```

### Step 2: Deploy Backend to Vercel

**Using Vercel Dashboard:**
1. Go to https://vercel.com/new
2. Import your GitHub repository
3. Set root directory to project folder
4. Click "Deploy"
5. Copy deployment URL

**Using CLI:**
```bash
npm install -g vercel
vercel login
vercel --prod
```

### Step 3: Deploy Frontend to Streamlit Cloud

1. Go to https://share.streamlit.io
2. Sign in with GitHub
3. Click "New app"
4. Select repository and branch
5. Main file: `streamlit_app.py`
6. Advanced settings → Environment variables:
   - Key: `API_BASE_URL`
   - Value: `https://your-vercel-app.vercel.app`
7. Click "Deploy"

### Step 4: Test Your Deployment

```bash
# Test backend
curl https://your-vercel-app.vercel.app/health

# Test full workflow
./test-api.sh https://your-vercel-app.vercel.app
```

### Step 5: Update Repository README

Update the live demo links in your README:

```markdown
🚀 **[View Live Demo](https://your-app.streamlit.app)**
📚 **[API Documentation](https://your-app.vercel.app/docs)**
```

## Troubleshooting

### "API Server: Offline" Error

**Fix:**
- Check Vercel deployment status
- Verify `API_BASE_URL` environment variable
- Test: `curl https://your-app.vercel.app/health`

### Repository Clone Fails

**Fix:**
- Ensure repository is public
- Check URL format
- Try different repository

### Timeout Errors

**Fix:**
- Vercel free tier: 10-second limit
- Use smaller repositories for testing
- Consider upgrading to Vercel Pro

## API Usage Examples

### Python

```python
import requests

# Start analysis
response = requests.post(
    "https://your-app.vercel.app/api/analyze",
    json={
        "repository_url": "https://github.com/username/repo",
        "branch": "main",
        "analysis_depth": "full",
        "format": "markdown"
    }
)

workflow_id = response.json()["workflow_id"]

# Check status
status = requests.get(
    f"https://your-app.vercel.app/api/status/{workflow_id}"
)
print(status.json())
```

### JavaScript

```javascript
const axios = require('axios');

async function analyzeRepository() {
    const response = await axios.post(
        'https://your-app.vercel.app/api/analyze',
        {
            repository_url: 'https://github.com/username/repo',
            branch: 'main',
            analysis_depth: 'full',
            format: 'markdown'
        }
    );
    
    const workflowId = response.data.workflow_id;
    
    // Poll for status
    const status = await axios.get(
        `https://your-app.vercel.app/api/status/${workflowId}`
    );
    
    console.log(status.data);
}
```

### cURL

```bash
# Start analysis
curl -X POST https://your-app.vercel.app/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "repository_url": "https://github.com/username/repo",
    "branch": "main",
    "analysis_depth": "full",
    "format": "markdown"
  }'

# Check status
curl https://your-app.vercel.app/api/status/WORKFLOW_ID

# Download result
curl https://your-app.vercel.app/api/download/WORKFLOW_ID \
  --output documentation.zip
```

## Features

- **4 AI Agents**: Repository Mapper, Code Analyzer, DocGenie, Supervisor
- **Multi-Platform**: GitHub, GitLab, Bitbucket
- **Multiple Formats**: Markdown, HTML, PDF
- **Real-time Progress**: Live status updates
- **Web Interface**: Easy-to-use Streamlit UI
- **REST API**: Full programmatic access

## Support

- **Documentation**: See DEPLOYMENT_GUIDE.md
- **Issues**: https://github.com/OumaCavin/codebase-genius/issues
- **Email**: otienocavin@gmail.com

## License

MIT License - Cavin Otieno

---

**Made with ❤️ by Cavin Otieno**
