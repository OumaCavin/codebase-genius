# Multi-stage production-ready Dockerfile for Codebase Genius
# Stage 1: Build dependencies
FROM python:3.11-slim as builder

# Set build arguments
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# Labels
LABEL maintainer="codebase-genius@github.com" \
      org.opencontainers.image.title="Codebase Genius" \
      org.opencontainers.image.description="Multi-agent AI system for code documentation generation" \
      org.opencontainers.image.url="https://github.com/OumaCavin/Generative-AI-Builds/jac-projects/codebase-genius" \
      org.opencontainers.image.source="https://github.com/OumaCavin/Generative-AI-Builds/jac-projects/codebase-genius" \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.created=$BUILD_DATE

# Install system dependencies for building
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libpq-dev \
    libssl-dev \
    libffi-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements files
COPY requirements.txt requirements-dev.txt* ./
COPY api-frontend/requirements.txt ./api-frontend/

# Install Python dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir -r api-frontend/requirements.txt || true

# Stage 2: Runtime image
FROM python:3.11-slim as runtime

# Set runtime labels
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.version=$VERSION

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    postgresql-client \
    libpq5 \
    libssl3 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && apt-get clean

# Create app user and group
RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /bin/bash -c "App User" appuser

# Copy virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Set work directory
WORKDIR /app

# Copy application code
COPY --chown=appuser:appuser . .

# Create necessary directories with proper permissions
RUN mkdir -p \
    logs \
    agents/agent_data \
    api-frontend/outputs \
    api-frontend/temp \
    tmp/cache \
    tmp/workspace \
    && chown -R appuser:appuser /app

# Create log file
RUN touch /app/logs/app.log && \
    chown appuser:appuser /app/logs/app.log

# Health check script
COPY --chown=appuser:appuser <<EOF /usr/local/bin/healthcheck.sh
#!/bin/bash
# Health check script for container monitoring
set -e

echo "[$(date)] Health check started"

# Check if API is responding
if curl -f -s http://localhost:8000/api/v1/health > /dev/null; then
    echo "[$(date)] Health check: API is healthy"
    exit 0
else
    echo "[$(date)] Health check: API is not responding"
    exit 1
fi
EOF

# Make health check script executable
RUN chmod +x /usr/local/bin/healthcheck.sh

# Switch to non-root user
USER appuser

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    ENVIRONMENT=production \
    API_HOST=0.0.0.0 \
    API_PORT=8000 \
    LOG_LEVEL=INFO \
    MAX_CONCURRENT_WORKFLOWS=5 \
    DEFAULT_TIMEOUT=300 \
    CACHE_DIR=/app/tmp/cache \
    WORKSPACE_DIR=/app/tmp/workspace

# Expose port
EXPOSE 8000 8501

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Start application
CMD ["python", "api-frontend/start.py", "start"]