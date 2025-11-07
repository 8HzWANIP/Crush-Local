#!/bin/bash
###############################################################################
# Smart Git Commit Message Generator
#
# This script uses Crush CLI + LM Studio to generate intelligent,
# conventional commit messages based on your staged changes.
#
# Usage: ./smart-commit.sh [--auto-commit]
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
AUTO_COMMIT=false
SESSION_NAME="smart-commit-$(date +%s)"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto-commit)
            AUTO_COMMIT=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--auto-commit]"
            echo ""
            echo "Options:"
            echo "  --auto-commit  Automatically commit without confirmation"
            echo "  -h, --help     Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}Smart Commit Message Generator${NC}"
echo ""

# Check if in git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not a git repository${NC}"
    exit 1
fi

# Check if there are staged changes
STAGED_DIFF=$(git diff --cached)

if [ -z "$STAGED_DIFF" ]; then
    echo -e "${YELLOW}No staged changes found.${NC}"
    echo ""
    echo "Stage your changes first:"
    echo "  git add <files>"
    echo ""
    echo "Or stage all changes:"
    echo "  git add -A"
    exit 1
fi

echo -e "${YELLOW}Analyzing staged changes...${NC}"

# Get list of staged files
STAGED_FILES=$(git diff --cached --name-only)
FILE_COUNT=$(echo "$STAGED_FILES" | wc -l)

echo "Staged files ($FILE_COUNT):"
echo "$STAGED_FILES" | sed 's/^/  - /'
echo ""

# Get recent commit messages for style reference
RECENT_COMMITS=$(git log -10 --pretty=format:"%s" 2>/dev/null || echo "")

# Build prompt for AI
PROMPT="Generate a high-quality commit message for these staged changes.

## Staged Changes

\`\`\`diff
$STAGED_DIFF
\`\`\`

## Files Changed
$STAGED_FILES

## Recent Commit Messages (for style reference)
\`\`\`
$RECENT_COMMITS
\`\`\`

## Requirements

Follow the **Conventional Commits** specification:

**Format:**
\`\`\`
<type>(<scope>): <subject>

<body>

<footer>
\`\`\`

**Types:**
- feat: New feature
- fix: Bug fix
- docs: Documentation changes
- style: Code style/formatting (no logic change)
- refactor: Code refactoring
- perf: Performance improvement
- test: Adding or updating tests
- chore: Maintenance tasks
- ci: CI/CD changes
- build: Build system changes

**Guidelines:**
1. Subject line: imperative mood, no period, max 50 characters
2. Body: Explain WHAT and WHY (not HOW), wrap at 72 characters
3. Footer: Breaking changes (BREAKING CHANGE:), issue references (#123)
4. Scope: optional, indicates affected area (e.g., api, ui, auth)

**Examples:**
\`\`\`
feat(auth): add JWT token refresh mechanism

Implement automatic token refresh to improve user experience
by reducing forced logouts. Refresh occurs 5 minutes before
token expiration.

Closes #234
\`\`\`

\`\`\`
fix(api): resolve race condition in user registration

Add mutex lock to prevent duplicate user creation when
multiple simultaneous registration requests occur.

Fixes #456
\`\`\`

## Your Task

Analyze the changes and generate ONE commit message that:
- Accurately describes the changes
- Follows Conventional Commits format
- Has clear, concise subject line
- Includes helpful body text if changes are non-trivial
- References any obvious issue numbers if mentioned in code

Output ONLY the commit message (no explanations, no markdown code blocks)."

echo -e "${YELLOW}Generating commit message with AI...${NC}"

# Generate commit message using Crush
COMMIT_MSG=$(crush chat --session "$SESSION_NAME" "$PROMPT" 2>/dev/null | sed '/^$/d' | head -20)

if [ -z "$COMMIT_MSG" ]; then
    echo -e "${RED}Error: Failed to generate commit message${NC}"
    exit 1
fi

# Display generated message
echo ""
echo -e "${GREEN}Generated Commit Message:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$COMMIT_MSG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Auto-commit or ask for confirmation
if [ "$AUTO_COMMIT" = true ]; then
    echo -e "${YELLOW}Auto-committing...${NC}"
    git commit -m "$COMMIT_MSG"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Commit successful!${NC}"
        git log -1 --oneline
    else
        echo -e "${RED}✗ Commit failed${NC}"
        exit 1
    fi
else
    # Ask user for confirmation
    echo -e "${YELLOW}Use this commit message?${NC}"
    echo "  [y] Yes, commit with this message"
    echo "  [e] Edit the message"
    echo "  [r] Regenerate message"
    echo "  [n] Cancel"
    echo ""
    read -p "Choice [y/e/r/n]: " -n 1 -r
    echo ""

    case $REPLY in
        y|Y)
            git commit -m "$COMMIT_MSG"

            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ Commit successful!${NC}"
                git log -1 --oneline
            else
                echo -e "${RED}✗ Commit failed${NC}"
                exit 1
            fi
            ;;
        e|E)
            # Save to temp file and open in editor
            TEMP_FILE=$(mktemp)
            echo "$COMMIT_MSG" > "$TEMP_FILE"

            ${EDITOR:-nano} "$TEMP_FILE"

            EDITED_MSG=$(cat "$TEMP_FILE")
            rm "$TEMP_FILE"

            if [ -n "$EDITED_MSG" ]; then
                git commit -m "$EDITED_MSG"
                echo -e "${GREEN}✓ Commit successful with edited message!${NC}"
            else
                echo -e "${RED}✗ Empty commit message, aborting${NC}"
                exit 1
            fi
            ;;
        r|R)
            echo -e "${YELLOW}Regenerating...${NC}"
            exec "$0" "$@"
            ;;
        *)
            echo -e "${YELLOW}Commit cancelled${NC}"
            exit 0
            ;;
    esac
fi

# Clean up
crush session delete "$SESSION_NAME" 2>/dev/null || true

echo ""
echo -e "${GREEN}Done!${NC}"
exit 0
