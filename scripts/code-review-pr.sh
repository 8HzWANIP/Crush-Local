#!/bin/bash
###############################################################################
# PR Code Review Script
#
# Automated code review for pull requests using Crush CLI + LM Studio.
# Can review current branch against main/master or a specific PR.
#
# Usage: ./code-review-pr.sh [base-branch] [--post-comment]
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BASE_BRANCH="${1:-main}"
POST_COMMENT=false
REVIEW_FILE="code-review-$(date +%Y%m%d-%H%M%S).md"
SESSION_NAME="pr-review-$(date +%s)"

# Parse options
for arg in "$@"; do
    case $arg in
        --post-comment)
            POST_COMMENT=true
            shift
            ;;
    esac
done

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              Pull Request Code Review                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if in git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not a git repository${NC}"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" = "$BASE_BRANCH" ]; then
    echo -e "${RED}Error: Already on $BASE_BRANCH. Please switch to your feature branch.${NC}"
    exit 1
fi

echo -e "${YELLOW}Configuration:${NC}"
echo "  Base Branch:    $BASE_BRANCH"
echo "  Current Branch: $CURRENT_BRANCH"
echo "  Review File:    $REVIEW_FILE"
echo ""

# Check if base branch exists
if ! git show-ref --verify --quiet "refs/heads/$BASE_BRANCH"; then
    echo -e "${RED}Error: Base branch '$BASE_BRANCH' does not exist${NC}"
    exit 1
fi

# Get diff statistics
echo -e "${YELLOW}Gathering changes...${NC}"

DIFF_STATS=$(git diff "$BASE_BRANCH"...HEAD --stat)
CHANGED_FILES=$(git diff "$BASE_BRANCH"...HEAD --name-only)
FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l)
FULL_DIFF=$(git diff "$BASE_BRANCH"...HEAD)

echo ""
echo -e "${GREEN}Changes Summary:${NC}"
echo "$DIFF_STATS"
echo ""
echo -e "${YELLOW}Files changed: $FILE_COUNT${NC}"
echo ""

# Check if diff is too large
DIFF_SIZE=$(echo "$FULL_DIFF" | wc -c)
if [ $DIFF_SIZE -gt 100000 ]; then
    echo -e "${YELLOW}Warning: Large diff ($DIFF_SIZE bytes). Review may take longer.${NC}"
    echo ""
fi

# Get commit messages
COMMITS=$(git log "$BASE_BRANCH"..HEAD --pretty=format:"%h - %s (%an)")
COMMIT_COUNT=$(echo "$COMMITS" | wc -l)

echo -e "${GREEN}Commits ($COMMIT_COUNT):${NC}"
echo "$COMMITS" | sed 's/^/  /'
echo ""

# Build review prompt
REVIEW_PROMPT="# Pull Request Code Review

You are an experienced code reviewer. Perform a comprehensive review of this pull request.

## PR Information

**Base Branch:** $BASE_BRANCH
**Feature Branch:** $CURRENT_BRANCH
**Commits:** $COMMIT_COUNT
**Files Changed:** $FILE_COUNT

## Commits

\`\`\`
$COMMITS
\`\`\`

## Changed Files

\`\`\`
$CHANGED_FILES
\`\`\`

## Full Diff

\`\`\`diff
$FULL_DIFF
\`\`\`

## Review Requirements

Provide a detailed code review covering:

### 1. Code Quality (⭐ Weight: 25%)
- Code structure and organization
- Naming conventions
- Code complexity
- DRY principles
- SOLID principles adherence
- Best practices for the language/framework

### 2. Security (⭐ Weight: 30%)
- Security vulnerabilities (OWASP Top 10)
- Input validation
- Authentication/authorization
- Sensitive data handling
- SQL injection, XSS, CSRF risks
- Dependency vulnerabilities

### 3. Performance (⭐ Weight: 15%)
- Algorithmic efficiency
- Database query optimization
- Caching opportunities
- Resource management
- Scalability concerns

### 4. Testing (⭐ Weight: 15%)
- Test coverage adequacy
- Test quality
- Missing edge cases
- Integration test needs
- E2E test requirements

### 5. Documentation (⭐ Weight: 10%)
- Code comments quality
- Function/API documentation
- README updates
- Changelog entries
- Architecture documentation

### 6. Maintainability (⭐ Weight: 5%)
- Code readability
- Error handling
- Logging and monitoring
- Backward compatibility
- Technical debt

## Output Format

### Overall Assessment

**Recommendation:** [APPROVE | REQUEST CHANGES | NEEDS DISCUSSION]
**Confidence:** [High | Medium | Low]
**Overall Score:** X/100

**Summary:** [2-3 sentence summary]

---

### Critical Issues 🔴

[Issues that MUST be fixed before merging]

1. **[Issue Title]** (Severity: Critical)
   - **File:** \`path/to/file.js:123\`
   - **Description:** [What's wrong]
   - **Impact:** [Why it matters]
   - **Fix:** [How to fix it]
   - **Example:**
   \`\`\`javascript
   // Good:
   [code]
   \`\`\`

---

### Important Issues 🟡

[Issues that should be addressed]

---

### Minor Issues 🟢

[Nice-to-have improvements]

---

### Positive Highlights ✨

[Good practices, clever solutions, etc.]

---

### Detailed Review by File

[File-by-file analysis for each changed file]

#### \`path/to/file.js\`

**Quality Score:** X/100

**Changes:**
- [Summary of changes in this file]

**Comments:**
- Line 45: [Comment]
- Line 67: [Comment]

---

### Testing Recommendations

[Specific tests that should be added]

---

### Questions for Author

[Things that need clarification]

---

### Estimated Time to Address Issues

- Critical: X hours
- Important: Y hours
- Minor: Z hours
- **Total:** W hours

---

**Final Recommendation:**
[Detailed reasoning for APPROVE/REQUEST CHANGES/NEEDS DISCUSSION]
"

echo -e "${YELLOW}Running AI code review...${NC}"
echo "This may take several minutes for large diffs..."
echo ""

# Run Crush analysis
if crush chat --session "$SESSION_NAME" "$REVIEW_PROMPT" > "$REVIEW_FILE" 2>&1; then
    echo -e "${GREEN}✓ Code review complete!${NC}"
    echo ""

    # Extract and display summary
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    Review Summary                         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Display first 50 lines (summary section)
    head -50 "$REVIEW_FILE"
    echo ""
    echo "..."
    echo ""

    # Count issues
    CRITICAL_COUNT=$(grep -c "🔴" "$REVIEW_FILE" 2>/dev/null || echo "0")
    IMPORTANT_COUNT=$(grep -c "🟡" "$REVIEW_FILE" 2>/dev/null || echo "0")
    MINOR_COUNT=$(grep -c "🟢" "$REVIEW_FILE" 2>/dev/null || echo "0")

    echo -e "${YELLOW}Issue Breakdown:${NC}"
    echo "  🔴 Critical:  $CRITICAL_COUNT"
    echo "  🟡 Important: $IMPORTANT_COUNT"
    echo "  🟢 Minor:     $MINOR_COUNT"
    echo ""

    # Determine recommendation
    if grep -q "APPROVE" "$REVIEW_FILE"; then
        echo -e "${GREEN}✓ Recommendation: APPROVE${NC}"
    elif grep -q "REQUEST CHANGES" "$REVIEW_FILE"; then
        echo -e "${YELLOW}⚠ Recommendation: REQUEST CHANGES${NC}"
    else
        echo -e "${BLUE}ℹ Recommendation: NEEDS DISCUSSION${NC}"
    fi

    echo ""
    echo -e "${GREEN}Full review saved to: $REVIEW_FILE${NC}"
    echo ""
    echo "View full review:"
    echo "  cat $REVIEW_FILE"
    echo ""
    echo "Or open in your browser:"
    echo "  # Install grip: pip install grip"
    echo "  grip $REVIEW_FILE"
    echo ""

    # Offer to post as PR comment (if gh CLI available and --post-comment flag set)
    if [ "$POST_COMMENT" = true ] && command -v gh &> /dev/null; then
        echo -e "${YELLOW}Posting review as PR comment...${NC}"

        # Get PR number for current branch
        PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null || echo "")

        if [ -n "$PR_NUMBER" ]; then
            gh pr comment "$PR_NUMBER" --body-file "$REVIEW_FILE"
            echo -e "${GREEN}✓ Review posted to PR #$PR_NUMBER${NC}"
        else
            echo -e "${YELLOW}No PR found for branch $CURRENT_BRANCH${NC}"
            echo "Create PR first: gh pr create"
        fi
    fi

    # Clean up session
    crush session delete "$SESSION_NAME" 2>/dev/null || true

    # Exit code based on recommendation
    if [ $CRITICAL_COUNT -gt 0 ]; then
        exit 1  # Fail CI if critical issues found
    else
        exit 0
    fi

else
    echo -e "${RED}✗ Code review failed${NC}"
    echo "Check error log: $REVIEW_FILE"
    exit 1
fi
