#!/bin/bash

# Validate Codebase Genius Deployment Package
# Ensures all required files are present and properly configured

echo "=========================================="
echo "Codebase Genius Deployment Package Validation"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $1 (MISSING)"
        ((FAILED++))
        return 1
    fi
}

# Function to check directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $1/ (MISSING)"
        ((FAILED++))
        return 1
    fi
}

# Function to check file contains text
check_contains() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $1 contains '$2'"
        ((PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $1 may need review (searching for '$2')"
        ((WARNINGS++))
        return 1
    fi
}

echo "=== Core Files ==="
check_file "api/index.py"
check_file "api/routes.py"
check_file "streamlit_app.py"
echo ""

echo "=== Configuration Files ==="
check_file "vercel.json"
check_file ".streamlit/config.toml"
check_file "requirements.txt"
check_file "requirements-streamlit.txt"
check_file ".gitignore"
echo ""

echo "=== Documentation ==="
check_file "README.md"
check_file "DEPLOYMENT_GUIDE.md"
check_file "QUICK_START.md"
check_file "AI_AGENTS_INTEGRATION.md"
check_file "DEPLOYMENT_SUMMARY.md"
check_file "NEXT_STEPS.md"
check_file "API_ENDPOINTS.md"
check_file "LICENSE"
echo ""

echo "=== Scripts ==="
check_file "deploy-backend.sh"
check_file "test-api.sh"
echo ""

echo "=== Directory Structure ==="
check_dir "api"
check_dir ".streamlit"
echo ""

echo "=== Code Validation ==="

# Check API routes has all endpoints
if [ -f "api/routes.py" ]; then
    echo "Checking API endpoints..."
    check_contains "api/routes.py" "@app.get(\"/\")"
    check_contains "api/routes.py" "@app.get(\"/health\")"
    check_contains "api/routes.py" "@app.post(\"/api/analyze\")"
    check_contains "api/routes.py" "@app.get(\"/api/status"
    check_contains "api/routes.py" "@app.get(\"/api/workflows\")"
    check_contains "api/routes.py" "@app.get(\"/api/download"
    check_contains "api/routes.py" "@app.delete(\"/api/workflows"
    check_contains "api/routes.py" "@app.get(\"/api/config\")"
fi
echo ""

# Check CORS configuration
if [ -f "api/routes.py" ]; then
    echo "Checking CORS configuration..."
    check_contains "api/routes.py" "CORSMiddleware"
fi
echo ""

# Check Streamlit configuration
if [ -f "streamlit_app.py" ]; then
    echo "Checking Streamlit configuration..."
    check_contains "streamlit_app.py" "API_BASE_URL"
    check_contains "streamlit_app.py" "st.set_page_config"
fi
echo ""

# Check Vercel configuration
if [ -f "vercel.json" ]; then
    echo "Checking Vercel configuration..."
    check_contains "vercel.json" "\"builds\""
    check_contains "vercel.json" "\"routes\""
fi
echo ""

echo "=== File Size Check ==="
if [ -f "api/routes.py" ]; then
    SIZE=$(wc -c < "api/routes.py")
    if [ $SIZE -gt 10000 ]; then
        echo -e "${GREEN}✓${NC} api/routes.py: ${SIZE} bytes (substantial)"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠${NC} api/routes.py: ${SIZE} bytes (may be incomplete)"
        ((WARNINGS++))
    fi
fi

if [ -f "streamlit_app.py" ]; then
    SIZE=$(wc -c < "streamlit_app.py")
    if [ $SIZE -gt 10000 ]; then
        echo -e "${GREEN}✓${NC} streamlit_app.py: ${SIZE} bytes (substantial)"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠${NC} streamlit_app.py: ${SIZE} bytes (may be incomplete)"
        ((WARNINGS++))
    fi
fi
echo ""

echo "=== Python Syntax Check ==="
for file in api/index.py api/routes.py streamlit_app.py; do
    if [ -f "$file" ]; then
        if python3 -m py_compile "$file" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $file (valid Python syntax)"
            ((PASSED++))
        else
            echo -e "${RED}✗${NC} $file (syntax errors)"
            ((FAILED++))
        fi
    fi
done
echo ""

echo "=========================================="
echo "Validation Summary"
echo "=========================================="
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Failed:${NC} $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Package is ready for deployment!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review NEXT_STEPS.md"
    echo "2. Push to GitHub: git init && git add . && git commit -m 'Initial commit'"
    echo "3. Deploy backend to Vercel"
    echo "4. Deploy frontend to Streamlit Cloud"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Package has issues that need to be resolved${NC}"
    echo "Please fix the failed checks above before deployment"
    echo ""
    exit 1
fi
