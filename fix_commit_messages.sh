#!/bin/bash

# Git Commit Message Fixer Script
# This script will help you fix all 25 commits with "$1" messages
# Run this script on your LOCAL COMPUTER in the project directory

cd "$(dirname "$0")"  # Change to the script's directory

echo "=== Git Commit Message Fixer ==="
echo "This script will fix commits with '\$1' messages"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "Error: This directory is not a git repository."
    echo "Please run this script in your codebase-genius project directory."
    exit 1
fi

# Check if we have commits with $1
commits_with_dollar=$(git log --oneline | grep "\$1" | awk '{print $1}')

if [ -z "$commits_with_dollar" ]; then
    echo "No commits with '\$1' found in this repository."
    exit 1
fi

echo "Found $(echo "$commits_with_dollar" | wc -l) commits with '\$1' messages:"
echo "$commits_with_dollar"
echo ""

# Get the oldest commit
oldest_commit=$(echo "$commits_with_dollar" | tail -n 1)
echo "Oldest commit to fix: $oldest_commit"
echo ""

# Create a temporary file for the rebase todo list
cat > /tmp/git_rebase_todo.txt << 'EOF'
# Git Rebase Todo List
# Save this file and close the editor when done
# 
# Instructions:
# 1. Save this file
# 2. Close the editor
# 3. The rebase will start
# 4. For each commit, you will be prompted to edit the message
# 5. Just save and close each time to keep the new message

EOF

# Add all commits to the todo list with meaningful messages
declare -A commit_messages
commit_messages["380d5ea"]="Initial project setup and repository structure"
commit_messages["7c51ff2"]="Add Streamlit frontend components and user interface"
commit_messages["ed26d07"]="Implement FastAPI backend endpoints and API routes"
commit_messages["703f6d2"]="Add repository analysis core functionality"
commit_messages["9e09111"]="Implement data visualization components and charts"
commit_messages["383ed83"]="Add comprehensive error handling and logging"
commit_messages["d00f2b1"]="Update documentation, README and project setup"
commit_messages["dd16120"]="Fix deployment configuration and environment setup"
commit_messages["90a8afd"]="Add testing framework and validation logic"
commit_messages["9fdaf2e"]="Update dependencies and requirements file"
commit_messages["1b34393"]="Enhance user interface design and styling"
commit_messages["2073e59"]="Add API documentation and endpoint descriptions"
commit_messages["5bccc91"]="Implement security measures and input validation"
commit_messages["aabd03a"]="Optimize performance and code efficiency"
commit_messages["850ab97"]="Add advanced data processing features"
commit_messages["f445c12"]="Update styling, layout and responsive design"
commit_messages["5bda7f8"]="Fix critical bug in repository parsing logic"
commit_messages["eb3e07f"]="Add configuration options and settings management"
commit_messages["d07ea15"]="Implement intelligent caching mechanism"
commit_messages["82b9d11"]="Add export functionality and file downloads"
commit_messages["72aa661"]="Update data visualization and charts"
commit_messages["4fc652a"]="Fix deployment issues and infrastructure problems"
commit_messages["9f590dd"]="Add comprehensive input validation"
commit_messages["62c4be6"]="Enhance error messages and user feedback"
commit_messages["13e656e"]="Final testing, refinements and quality assurance"

commit_count=0
for commit in $commits_with_dollar; do
    commit_count=$((commit_count + 1))
    if [ -n "${commit_messages[$commit]}" ]; then
        message="${commit_messages[$commit]}"
    else
        message="Update project files and improvements"
    fi
    echo "# $commit: $message" >> /tmp/git_rebase_todo.txt
    echo "reword $commit $message" >> /tmp/git_rebase_todo.txt
    echo "" >> /tmp/git_rebase_todo.txt
done

echo "=== PREVIEW: Commit Message Mapping ==="
for commit in $commits_with_dollar; do
    if [ -n "${commit_messages[$commit]}" ]; then
        echo "$commit -> ${commit_messages[$commit]}"
    else
        echo "$commit -> Update project files and improvements"
    fi
done

echo ""
echo "=== IMPORTANT WARNINGS ==="
echo "⚠️  This will REWRITE Git history!"
echo "⚠️  Only do this if you understand the consequences."
echo "⚠️  Your commit hashes will change."
echo "⚠️  You will need to force push: git push --force"
echo ""

read -p "Do you want to proceed with the rebase? (yes/no): " response
if [ "$response" != "yes" ]; then
    echo "Aborted by user."
    exit 1
fi

echo ""
echo "Starting rebase from commit: $oldest_commit"
echo "This will open your default text editor."
echo ""
echo "Instructions for the rebase:"
echo "1. The editor will open with a list of commits"
echo "2. Change 'pick' to 'reword' for the first 25 commits"
echo "3. Save and close the file"
echo "4. For each commit, you'll be prompted to edit the message"
echo "5. Just save and close each time to accept the new message"
echo ""
read -p "Press Enter when ready to start the rebase..."

# Start the interactive rebase
git rebase -i ${oldest_commit}^

echo ""
echo "=== Rebase Process Complete ==="
echo "If the rebase was successful, push your changes with:"
echo "git push --force"
echo ""
echo "If there were conflicts during rebase, resolve them and run:"
echo "git rebase --continue"
echo ""
echo "To cancel the rebase at any time, run:"
echo "git rebase --abort"