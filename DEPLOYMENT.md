# Codebase Genius - Production Deployment

## 🚀 Quick Start

### Prerequisites
- Python 3.9+
- Docker (optional)
- Git

### 1. Installation

```bash
# Clone the repository
git clone <your-repository-url>
cd deployment-package

# Install dependencies
pip install -r requirements.txt
pip install -r api-frontend/requirements.txt
```

### 2. Start Services

```bash
# Start all services
python api-frontend/start.py start

# Or start individually
python api-frontend/start.py api    # API server on port 8000
python api-frontend/start.py ui     # Web UI on port 8501
```

### 3. Access
- **Web Interface**: http://localhost:8501
- **API Documentation**: http://localhost:8000/docs
- **API Base URL**: http://localhost:8000/api/v1

## 📁 Structure

- `agents/`: Multi-agent AI system (4 agents)
- `api-frontend/`: FastAPI + Streamlit frontend
- `deployment/`: Docker, Kubernetes, cloud configs
- `requirements.txt`: Core dependencies

## 🐳 Docker Deployment

```bash
# Single container
docker build -t codebase-genius .
docker run -p 8000:8000 -p 8501:8501 codebase-genius

# Multi-service
docker-compose -f deployment/docker-compose.yml up -d
```

## ☁️ Cloud Deployment

### GitHub
1. Push to repository
2. GitHub Actions will handle CI/CD
3. Deploy to Docker Hub or Heroku

### Netlify
- Configured in `netlify.toml`
- Deploy with: `netlify deploy`

### Vercel
- Configured in `vercel.json`
- Deploy with: `vercel`

## 🔧 Configuration

### Environment Variables
```bash
API_HOST=0.0.0.0
API_PORT=8000
STREAMLIT_PORT=8501
GITHUB_TOKEN=your_token
OPENAI_API_KEY=your_key
```

## 📖 Documentation

- [Deployment Structure](README-STRUCTURE.md): Detailed deployment guide
- [API Documentation](http://localhost:8000/docs): When running locally
- [Project README](README.md): Full project documentation

## 🆘 Support

- Check `TROUBLESHOOTING.md` for common issues
- Review logs in `api-frontend/logs/`
- Create an issue for bug reports

## 🎯 Features

- ✅ Multi-agent AI system
- ✅ GitHub/GitLab/Bitbucket support
- ✅ Markdown, HTML, PDF output
- ✅ RESTful API (8 endpoints)
- ✅ Web interface (Streamlit)
- ✅ Docker containerization
- ✅ Health checks & monitoring
- ✅ Production-ready deployment

---

**Ready for production deployment!** 🚀