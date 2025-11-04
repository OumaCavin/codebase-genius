#!/bin/bash

# Test Codebase Genius API

VERCEL_URL="${1:-https://your-app.vercel.app}"

echo "=========================================="
echo "Testing Codebase Genius API"
echo "API URL: $VERCEL_URL"
echo "=========================================="
echo ""

# Test 1: Health Check
echo "Test 1: Health Check"
echo "Endpoint: GET /health"
echo "---"
curl -s "$VERCEL_URL/health" | python -m json.tool
echo ""
echo ""

# Test 2: Root Endpoint
echo "Test 2: Root Endpoint"
echo "Endpoint: GET /"
echo "---"
curl -s "$VERCEL_URL/" | python -m json.tool
echo ""
echo ""

# Test 3: API Config
echo "Test 3: API Configuration"
echo "Endpoint: GET /api/config"
echo "---"
curl -s "$VERCEL_URL/api/config" | python -m json.tool
echo ""
echo ""

# Test 4: List Workflows
echo "Test 4: List Workflows"
echo "Endpoint: GET /api/workflows"
echo "---"
curl -s "$VERCEL_URL/api/workflows" | python -m json.tool
echo ""
echo ""

# Test 5: Start Analysis (Example)
echo "Test 5: Start Analysis"
echo "Endpoint: POST /api/analyze"
echo "---"
echo "Starting analysis for: https://github.com/pallets/flask"
RESPONSE=$(curl -s -X POST "$VERCEL_URL/api/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "repository_url": "https://github.com/pallets/flask",
    "branch": "main",
    "analysis_depth": "full",
    "include_diagrams": true,
    "format": "markdown"
  }')

echo "$RESPONSE" | python -m json.tool

# Extract workflow_id
WORKFLOW_ID=$(echo "$RESPONSE" | python -c "import sys, json; print(json.load(sys.stdin).get('workflow_id', ''))")

if [ -n "$WORKFLOW_ID" ]; then
    echo ""
    echo "Workflow created: $WORKFLOW_ID"
    echo ""
    
    # Test 6: Check Status
    echo "Test 6: Check Status"
    echo "Endpoint: GET /api/status/$WORKFLOW_ID"
    echo "---"
    sleep 2
    curl -s "$VERCEL_URL/api/status/$WORKFLOW_ID" | python -m json.tool
    echo ""
else
    echo ""
    echo "Warning: Could not create workflow"
fi

echo ""
echo "=========================================="
echo "API Testing Complete"
echo "=========================================="
