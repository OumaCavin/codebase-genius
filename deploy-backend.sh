#!/bin/bash

# Deploy Backend to Vercel

echo "=========================================="
echo "Deploying Codebase Genius Backend to Vercel"
echo "=========================================="
echo ""

# Check if vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "Error: Vercel CLI is not installed"
    echo "Install it with: npm install -g vercel"
    exit 1
fi

# Login to Vercel
echo "Step 1: Logging in to Vercel..."
vercel login

# Deploy to production
echo ""
echo "Step 2: Deploying to production..."
vercel --prod

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Next Steps:"
echo "1. Note your deployment URL from above"
echo "2. Update streamlit_app.py with your Vercel URL"
echo "3. Or set API_BASE_URL environment variable in Streamlit Cloud"
echo ""
echo "Test your deployment:"
echo "curl https://your-app.vercel.app/health"
echo ""
