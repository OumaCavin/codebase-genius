# Deployment Package Structure

## 📦 Overview

This directory contains a clean, deployment-ready structure for the **Codebase Genius** multi-agent AI system. It includes only the essential files needed for production deployment while excluding development artifacts, logs, and temporary files.

## 🏗️ Directory Structure

```
deployment-package/
├── agents/                          # Multi-agent system implementation
│   ├── code-analyzer/              # Code parsing and analysis agent
│   ├── docgenie-agent/             # Documentation generation agent
│   ├── repository-mapper/          # Repository mapping agent
│   └── supervisor-agent/           # Workflow orchestration agent
├── api-frontend/                    # API and frontend layer
│   ├── api/                        # FastAPI REST endpoints
│   ├── config/                     # Configuration management
│   ├── frontend/                   # Streamlit web interface
│   ├── utils/                      # Utility functions
│   ├── start.py                    # Unified startup script
│   ├── Dockerfile                  # Container configuration
│   ├── requirements.txt            # Frontend dependencies
│   └── docker-compose.yml          # Multi-service orchestration
├── deployment/                      # Deployment configurations
│   ├── Dockerfile                  # Main container image
│   ├── docker-compose.yml          # Production compose
│   ├── nginx/                      # Nginx reverse proxy
│   ├── heroku/                     # Heroku deployment
│   ├── kubernetes/                 # K8s manifests
│   ├── railway/                    # Railway deployment
│   └── serverless/                 # Serverless configs
├── requirements.txt                # Core dependencies
├── README.md                       # Project documentation
└── README-STRUCTURE.md            # This file
```

## 🎯 What's Included

### 1. **Core Application (agents/)**
- **Multi-agent system**: 4 specialized AI agents working cooperatively
- **Repository analysis**: Advanced code parsing and relationship extraction
- **Documentation generation**: Automated multi-format output (Markdown, HTML, PDF)
- **Workflow orchestration**: Intelligent task distribution and coordination

### 2. **API & Frontend (api-frontend/)**
- **FastAPI backend**: RESTful API with 8 comprehensive endpoints
- **Streamlit frontend**: Modern web interface with real-time progress tracking
- **Configuration system**: Environment-based configuration management
- **Container support**: Docker configuration for easy deployment

### 3. **Deployment Infrastructure (deployment/)**
- **Docker support**: Complete containerization for any environment
- **Cloud platforms**: Ready-to-deploy configurations for major platforms
- **Load balancing**: Nginx configuration for production scaling
- **Health monitoring**: Built-in health checks and monitoring

### 4. **Configuration Files**
- **requirements.txt**: Core Python dependencies
- **Dockerfiles**: Multi-stage builds for production
- **docker-compose.yml**: Service orchestration
- **Environment configs**: Platform-specific deployment settings

## 🚀 Deployment Options

### 1. **GitHub Deployment**

#### Repository Setup
```bash
# Clone to your repository
git clone [your-repo-url]
cd codebase-genius

# Create .gitignore
echo "logs/
temp/
*.log
__pycache__/
*.pyc
.pytest_cache/
.vscode/
.idea/
*.swp
*.swo" > .gitignore

# Push to GitHub
git add .
git commit -m "Initial deployment-ready structure"
git push origin main
```

#### GitHub Actions Workflow
Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy Codebase Genius
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Production
        run: |
          docker build -t codebase-genius .
          docker-compose up -d
```

### 2. **Netlify Deployment**

#### Netlify Configuration
Create `netlify.toml`:
```toml
[build]
  command = "echo 'Static build completed'"
  publish = "."

[build.environment]
  PYTHON_VERSION = "3.11"

# For serverless functions (optional)
[[redirects]]
  from = "/api/*"
  to = "/.netlify/functions/api/:splat"
  status = 200

# SPA routing
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

#### Static Site Generation
```bash
# Build static frontend
cd api-frontend/frontend
streamlit run main.py --server.headless true --server.port 8501
# Deploy the static output to Netlify
```

### 3. **Vercel Deployment**

#### Vercel Configuration
Create `vercel.json`:
```json
{
  "version": 2,
  "builds": [
    {
      "src": "api-frontend/start.py",
      "use": "@vercel/python"
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "api-frontend/api/$1"
    },
    {
      "src": "/(.*)",
      "dest": "api-frontend/frontend/$1"
    }
  ],
  "env": {
    "PYTHON_VERSION": "3.11"
  }
}
```

#### Serverless Functions
Deploy API endpoints as serverless functions:
```bash
# Create serverless functions
mkdir -p api-frontend/api/functions
# Move API logic to individual serverless functions
```

## 🐳 Docker Deployment

### Single Container
```bash
cd deployment-package
docker build -t codebase-genius .
docker run -p 8000:8000 -p 8501:8501 codebase-genius
```

### Multi-Service (Recommended)
```bash
# Start all services
docker-compose -f deployment/docker-compose.yml up -d

# Scale services
docker-compose -f deployment/docker-compose.yml up -d --scale api=3

# Monitor logs
docker-compose -f deployment/docker-compose.yml logs -f
```

### Production Deployment
```bash
# Production with SSL and load balancing
docker-compose -f deployment/docker-compose.yml -f deployment/nginx/docker-compose.prod.yml up -d
```

## ☁️ Cloud Platform Deployment

### Railway Deployment
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and deploy
railway login
railway init
railway up
```

### Heroku Deployment
```bash
# Install Heroku CLI and login
heroku create codebase-genius-app

# Set environment variables
heroku config:set PYTHON_VERSION=3.11

# Deploy
git push heroku main
```

### Kubernetes Deployment
```bash
# Apply manifests
kubectl apply -f deployment/kubernetes/

# Check status
kubectl get pods
kubectl get services
```

## 🔧 Environment Configuration

### Required Environment Variables
```bash
# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
STREAMLIT_PORT=8501
STREAMLIT_HOST=0.0.0.0

# GitHub Token (for private repositories)
GITHUB_TOKEN=your_github_token

# OpenAI API Key (for enhanced analysis)
OPENAI_API_KEY=your_openai_key

# Database (if using persistent storage)
DATABASE_URL=postgresql://user:pass@host:port/db

# Redis (for caching and session management)
REDIS_URL=redis://localhost:6379
```

### Optional Configurations
```bash
# Performance tuning
MAX_WORKFLOWS=5
MAX_REPO_SIZE=100MB
CACHE_TTL=3600
TIMEOUT=300

# Security
ALLOWED_HOSTS=*
CORS_ORIGINS=http://localhost:8501
SECRET_KEY=your_secret_key
```

## 📊 Monitoring & Health Checks

### Health Endpoints
- **API Health**: `GET /health`
- **System Metrics**: `GET /api/v1/metrics`
- **Agent Status**: `GET /api/v1/agents/status`

### Monitoring Setup
```bash
# Add monitoring to docker-compose
services:
  monitoring:
    image: prom/prometheus
    ports:
      - "9090:9090"
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
```

## 🗂️ Excluded Files & Directories

The following are **intentionally excluded** to keep the deployment package clean:

### Development Artifacts
- `.git/`
- `__pycache__/`
- `*.pyc`
- `.pytest_cache/`
- `node_modules/`
- `.vscode/`
- `.idea/`
- `*.swp`, `*.swo`

### Logs & Temporary Files
- `logs/`
- `temp/`
- `*.log`
- `tmp/`
- `.tmp/`

### Test Results & Coverage
- `integration-testing/results/`
- `integration-testing/benchmarks/`
- `htmlcov/`
- `.coverage`
- `*.cover`

### Documentation Development
- `docs/`
- `final-docs/guides/`
- Development documentation files

### Build Artifacts
- `dist/`
- `build/`
- `*.egg-info/`
- `.wheel/`

## 🎯 Quick Start Commands

### Development Setup
```bash
# Clone and setup
git clone [repository-url]
cd deployment-package

# Install dependencies
pip install -r requirements.txt

# Start services
python api-frontend/start.py start

# Access interfaces
# Web UI: http://localhost:8501
# API Docs: http://localhost:8000/docs
```

### Production Deployment
```bash
# Using Docker
docker-compose -f deployment/docker-compose.yml up -d

# Using cloud platform
railway up  # or heroku, vercel, etc.

# Verify deployment
curl http://localhost:8000/health
```

## 📋 Pre-Deployment Checklist

- [ ] Environment variables configured
- [ ] GitHub token set (for private repos)
- [ ] Database connection tested (if using)
- [ ] SSL certificates configured (production)
- [ ] Health checks working
- [ ] Load balancing configured (if scaling)
- [ ] Monitoring setup completed
- [ ] Backup strategy implemented

## 🆘 Troubleshooting

### Common Issues
1. **Port conflicts**: Change ports in environment variables
2. **Permission errors**: Ensure Docker has proper permissions
3. **Memory issues**: Increase container memory limits
4. **Network timeouts**: Adjust timeout settings

### Debug Commands
```bash
# Check logs
docker-compose logs -f api

# Test API
curl http://localhost:8000/health

# Check agent status
curl http://localhost:8000/api/v1/agents/status

# Monitor resources
docker stats
```

## 📞 Support

For deployment issues:
- Check the main `README.md` for detailed setup instructions
- Review `TROUBLESHOOTING.md` for common solutions
- Create an issue in the repository for specific problems

## 🔄 Maintenance

### Regular Updates
```bash
# Update dependencies
pip install -r requirements.txt --upgrade

# Update Docker images
docker-compose pull
docker-compose up -d

# Security updates
pip-audit
```

### Backup Strategy
- Database backups (if using persistent storage)
- Configuration files backup
- Documentation export

---

**Ready for Production Deployment** 🚀

This structure is optimized for quick deployment to any major platform while maintaining the full functionality of the Codebase Genius system.