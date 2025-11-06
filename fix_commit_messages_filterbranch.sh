#!/bin/bash

# Alternative: Git Filter-Branch Commit Message Fixer
# This script uses git filter-branch for a non-interactive approach
# Use this if the interactive rebase doesn't work well for you

cd "$(dirname "$0")"

echo "=== Git Filter-Branch Commit Message Fixer ==="
echo "This uses git filter-branch to fix commit messages"
echo "WARNING: This will rewrite git history!"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "Error: This directory is not a git repository."
    exit 1
fi

# Check if we have commits with $1
commits_with_dollar=$(git log --oneline | grep "\$1" | awk '{print $1}')

if [ -z "$commits_with_dollar" ]; then
    echo "No commits with '\$1' found."
    exit 1
fi

echo "Found $(echo "$commits_with_dollar" | wc -l) commits with '\$1' messages"
echo "Creating backup before rewriting history..."
echo ""

# Create a backup branch
git branch backup_before_fix

echo "Creating commit message mapping..."

# Use git filter-branch to rewrite commit messages
git filter-branch --env-filter '
    OLD_MSG="$GIT_COMMIT_MSG"
    NEW_MSG="$OLD_MSG"
    
    case "$OLD_MSG" in
        *"\$1"*)
            case "$GIT_COMMIT" in
                380d5ea) NEW_MSG="Initial project setup and repository structure" ;;
                7c51ff2) NEW_MSG="Add Streamlit frontend components and user interface" ;;
                ed26d07) NEW_MSG="Implement FastAPI backend endpoints and API routes" ;;
                703f6d2) NEW_MSG="Add repository analysis core functionality" ;;
                9e09111) NEW_MSG="Implement data visualization components and charts" ;;
                383ed83) NEW_MSG="Add comprehensive error handling and logging" ;;
                d00f2b1) NEW_MSG="Update documentation, README and project setup" ;;
                dd16120) NEW_MSG="Fix deployment configuration and environment setup" ;;
                90a8afd) NEW_MSG="Add testing framework and validation logic" ;;
                9fdaf2e) NEW_MSG="Update dependencies and requirements file" ;;
                1b34393) NEW_MSG="Enhance user interface design and styling" ;;
                2073e59) NEW_MSG="Add API documentation and endpoint descriptions" ;;
                5bccc91) NEW_MSG="Implement security measures and input validation" ;;
                aabd03a) NEW_MSG="Optimize performance and code efficiency" ;;
                850ab97) NEW_MSG="Add advanced data processing features" ;;
                f445c12) NEW_MSG="Update styling, layout and responsive design" ;;
                5bda7f8) NEW_MSG="Fix critical bug in repository parsing logic" ;;
                eb3e07f) NEW_MSG="Add configuration options and settings management" ;;
                d07ea15) NEW_MSG="Implement intelligent caching mechanism" ;;
                82b9d11) NEW_MSG="Add export functionality and file downloads" ;;
                72aa661) NEW_MSG="Update data visualization and charts" ;;
                4fc652a) NEW_MSG="Fix deployment issues and infrastructure problems" ;;
                9f590dd) NEW_MSG="Add comprehensive input validation" ;;
                62c4be6) NEW_MSG="Enhance error messages and user feedback" ;;
                13e656e) NEW_MSG="Final testing, refinements and quality assurance" ;;
            esac
            ;;
    esac
    
    export GIT_COMMIT_MSG="$NEW_MSG"
' --tag-name-filter cat -- --branches --tags

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Commit message rewrite completed successfully!"
    echo ""
    echo "To push your changes to GitHub, run:"
    echo "git push --force"
    echo ""
    echo "Note: Your backup branch 'backup_before_fix' contains the original state"
else
    echo ""
    echo "❌ There was an error during the rewrite process."
    echo "To restore from backup, run:"
    echo "git reset --hard backup_before_fix"
fi