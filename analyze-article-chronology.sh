#!/bin/bash

echo "=== Article Development Chronology Analysis ==="
echo "Analyzing markdown files in the repository..."
echo ""

# Get all markdown files
echo "## All Markdown Files Found:"
find . -name "*.md" -type f | grep -v ".git" | sort
echo ""

# Analyze creation dates for each markdown file
echo "## Creation and Modification Timeline:"
echo ""

# Get all markdown files and analyze their git history
find . -name "*.md" -type f | grep -v ".git" | while read -r file; do
    echo "### $file"
    
    # Get first commit that added this file
    first_commit=$(git log --reverse --format="%H" -- "$file" | head -1)
    if [ -n "$first_commit" ]; then
        first_date=$(git log --format="%ad" --date=short "$first_commit" -1)
        first_msg=$(git log --format="%s" "$first_commit" -1)
        echo "  **Created:** $first_date - $first_msg"
        echo "  **Commit:** $first_commit"
    fi
    
    # Get last modification
    last_commit=$(git log --format="%H" -- "$file" | head -1)
    if [ -n "$last_commit" ] && [ "$last_commit" != "$first_commit" ]; then
        last_date=$(git log --format="%ad" --date=short "$last_commit" -1)
        last_msg=$(git log --format="%s" "$last_commit" -1)
        echo "  **Last Modified:** $last_date - $last_msg"
        echo "  **Commit:** $last_commit"
    fi
    
    # Get total number of commits
    commit_count=$(git log --oneline -- "$file" | wc -l)
    echo "  **Total Commits:** $commit_count"
    echo ""
done

echo "## Key Relationships Analysis:"
echo ""

# Analyze the specific relationship mentioned by the user
echo "### openwebui_quickstart_upd.md vs openwui-no-caddy-version.md + 1-2-4-https-caddy-keycloak.md"
echo ""

# Check if these files exist in the same commits
echo "**Commits containing openwebui_quickstart_upd.md:**"
git log --oneline -- openwebui_quickstart_upd.md | head -5

echo ""
echo "**Commits containing openwui-no-caddy-version.md:**"
git log --oneline -- openwui-no-caddy-version.md | head -5

echo ""
echo "**Commits containing 1-2-4-https-caddy-keycloak.md:**"
git log --oneline -- 1-2-4-https-caddy-keycloak.md | head -5

echo ""
echo "## Content Analysis:"
echo ""

# Check file sizes and line counts
echo "**File Statistics:**"
for file in openwebui_quickstart_upd.md openwui-no-caddy-version.md 1-2-4-https-caddy-keycloak.md; do
    if [ -f "$file" ]; then
        lines=$(wc -l < "$file")
        size=$(wc -c < "$file")
        echo "  $file: $lines lines, $size bytes"
    fi
done

echo ""
echo "## Recommendations for Chronology Restoration:"
echo "1. Use 'git log --follow --oneline -- <filename>' to see complete file history"
echo "2. Use 'git show <commit>:<filename>' to see file content at specific commits"
echo "3. Use 'git diff <commit1> <commit2> -- <filename>' to see changes between commits"
echo "4. Consider creating a timeline document showing file evolution"
