# Codebase Genius Live Demo

This is the live demo deployment for Codebase Genius - an AI-powered multi-agent system for automated codebase documentation generation.

## Architecture

- **Backend**: Vercel Serverless Functions (FastAPI)
- **Frontend**: Streamlit Cloud
- **Integration**: RESTful API communication

## Deployment

### Backend (Vercel)

1. Install Vercel CLI:
```bash
npm install -g vercel
```

2. Deploy to Vercel:
```bash
cd /workspace/codebase-genius-live-demo
vercel --prod
```

3. Note the deployment URL (e.g., `https://your-app.vercel.app`)

### Frontend (Streamlit Cloud)

1. Push this repository to GitHub
2. Go to https://share.streamlit.io
3. Connect your GitHub repository
4. Set environment variable: `API_BASE_URL=<your-vercel-url>`
5. Deploy

## Configuration

### Environment Variables

**Streamlit Cloud:**
- `API_BASE_URL`: Your Vercel backend URL (e.g., `https://your-app.vercel.app`)

## API Endpoints

- `GET /` - Root health check
- `GET /health` - Detailed health check
- `POST /api/analyze` - Start repository analysis
- `GET /api/status/{workflow_id}` - Get workflow status
- `GET /api/workflows` - List all workflows
- `GET /api/download/{workflow_id}` - Download documentation
- `DELETE /api/workflows/{workflow_id}` - Delete workflow
- `GET /api/config` - Get API configuration

## Features

- Multi-agent AI system (4 specialized agents)
- Repository analysis (GitHub, GitLab, Bitbucket)
- Documentation generation (Markdown, HTML, PDF)
- Real-time progress tracking
- Web interface for easy interaction

## Author

**Cavin Otieno**
- Email: otienocavin@gmail.com
- GitHub: https://github.com/OumaCavin/codebase-genius

## License

MIT License
