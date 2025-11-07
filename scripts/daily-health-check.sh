#!/bin/bash
###############################################################################
# Daily Code Health Check Script
#
# This script performs automated daily health checks on your codebase using
# Crush CLI + LM Studio for analysis.
#
# Usage: ./daily-health-check.sh [project-directory]
###############################################################################

set -e

# Configuration
PROJECT_DIR="${1:-.}"
REPORT_DIR="health-reports"
REPORT_FILE="$REPORT_DIR/health-report-$(date +%Y%m%d-%H%M%S).md"
SESSION_NAME="daily-health-check-$(date +%Y%m%d)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create report directory
mkdir -p "$REPORT_DIR"

echo -e "${GREEN}Starting Daily Code Health Check...${NC}"
echo "Project: $PROJECT_DIR"
echo "Report: $REPORT_FILE"
echo ""

# Change to project directory
cd "$PROJECT_DIR"

# Check if git repository
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}Warning: Not a git repository. Some checks will be skipped.${NC}"
fi

# Create health check prompt
cat > /tmp/health-check-prompt.txt << 'EOF'
Perform a comprehensive daily code health check on this project:

## 1. CODE METRICS (Last 24 Hours)
Analyze recent changes and provide:
- Lines of code added/removed
- Number of commits
- Files changed
- Contributors active

## 2. CODE QUALITY ASSESSMENT
Check for:
- New linting errors or warnings
- Type errors (if TypeScript/typed language)
- Unused variables and imports
- Code complexity issues (cyclomatic complexity)
- Duplicate code blocks

## 3. DEPENDENCY HEALTH
Review:
- Outdated packages
- Security vulnerabilities (npm audit, pip check, etc.)
- Deprecated dependencies
- License compliance issues

## 4. TEST COVERAGE
Evaluate:
- Current test coverage percentage
- Recently added code without tests
- Failing tests
- Flaky tests

## 5. TECHNICAL DEBT
Identify:
- TODO/FIXME comments count
- Code smells
- Areas needing refactoring
- Estimated debt hours

## 6. GIT REPOSITORY HEALTH
Check:
- Long-lived feature branches (>7 days)
- Large uncommitted changes
- Potential merge conflicts
- Branch protection status

## 7. DOCUMENTATION
Review:
- Outdated documentation
- Missing README sections
- Undocumented APIs
- Changelog updates needed

## 8. SECURITY SCAN
Quick security check for:
- Hardcoded secrets (API keys, passwords)
- Insecure dependencies
- Common vulnerabilities (SQL injection, XSS)
- Exposed sensitive data

## OUTPUT FORMAT
Provide a summary report with:
- 🟢 GREEN: Everything looks good
- 🟡 YELLOW: Minor issues, should be addressed soon
- 🔴 RED: Critical issues requiring immediate attention

For each issue, provide:
- Severity level
- Description
- File/location (if applicable)
- Recommended action
- Estimated time to fix

End with a prioritized action plan for the top 5 issues.
EOF

echo -e "${YELLOW}Gathering project information...${NC}"

# Gather git statistics (if git repo)
if [ -d ".git" ]; then
    GIT_STATS=$(cat << 'GIT_EOF'

## Recent Git Activity

GIT_EOF
)

    GIT_STATS="$GIT_STATS
### Commits (Last 24 Hours)
\`\`\`
$(git log --since="24 hours ago" --oneline --no-decorate || echo "No commits in last 24 hours")
\`\`\`

### Changed Files
\`\`\`
$(git log --since="24 hours ago" --name-only --pretty=format: | sort -u | grep -v '^$' || echo "No changes")
\`\`\`

### Statistics
\`\`\`
$(git log --since="24 hours ago" --stat | tail -1 || echo "No changes")
\`\`\`

### Active Branches
\`\`\`
$(git branch -v | head -20)
\`\`\`
"
else
    GIT_STATS=""
fi

# Count TODOs/FIXMEs
echo -e "${YELLOW}Counting TODOs and FIXMEs...${NC}"
TODO_COUNT=$(grep -r "TODO\|FIXME" --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" . 2>/dev/null | wc -l || echo "0")

# Build full prompt
FULL_PROMPT="$(cat /tmp/health-check-prompt.txt)

## Current Project State

### TODO/FIXME Count: $TODO_COUNT

$GIT_STATS

## Analysis Request

Please analyze the project at: $PROJECT_DIR

Perform all checks listed above and generate a comprehensive health report."

echo -e "${YELLOW}Running AI analysis with Crush CLI...${NC}"
echo "This may take a few minutes..."

# Run Crush analysis
if command -v crush &> /dev/null; then
    crush chat --session "$SESSION_NAME" "$FULL_PROMPT" > "$REPORT_FILE" 2>&1

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Health check complete!${NC}"
        echo ""
        echo "Report saved to: $REPORT_FILE"
        echo ""

        # Display summary (first 50 lines)
        echo -e "${YELLOW}Report Summary:${NC}"
        echo "----------------------------------------"
        head -50 "$REPORT_FILE"
        echo "..."
        echo "----------------------------------------"
        echo ""
        echo "View full report: cat $REPORT_FILE"

        # Count issues by severity
        RED_COUNT=$(grep -c "🔴" "$REPORT_FILE" || echo "0")
        YELLOW_COUNT=$(grep -c "🟡" "$REPORT_FILE" || echo "0")
        GREEN_COUNT=$(grep -c "🟢" "$REPORT_FILE" || echo "0")

        echo ""
        echo "Issue Summary:"
        echo -e "  🔴 Critical: $RED_COUNT"
        echo -e "  🟡 Warning:  $YELLOW_COUNT"
        echo -e "  🟢 Good:     $GREEN_COUNT"

    else
        echo -e "${RED}✗ Health check failed!${NC}"
        echo "Check the report file for details: $REPORT_FILE"
        exit 1
    fi
else
    echo -e "${RED}Error: Crush CLI not found. Please install it first.${NC}"
    echo "Installation: npm install -g @charmland/crush"
    exit 1
fi

# Optional: Generate trend data
if [ -d "$REPORT_DIR" ] && [ $(ls -1 "$REPORT_DIR"/*.md 2>/dev/null | wc -l) -gt 5 ]; then
    echo ""
    echo -e "${YELLOW}Generating trend analysis...${NC}"

    TREND_PROMPT="Analyze these historical health reports and identify trends:

$(ls -t "$REPORT_DIR"/*.md | head -5 | while read f; do
    echo "## Report: $(basename $f)"
    head -100 "$f"
    echo ""
done)

Provide:
1. Trend analysis (improving/declining/stable)
2. Recurring issues
3. Areas showing improvement
4. Concerning patterns
5. Recommendations for next sprint

Focus on actionable insights."

    crush chat --session "$SESSION_NAME-trend" "$TREND_PROMPT" > "$REPORT_DIR/trend-analysis-$(date +%Y%m%d).md"

    echo -e "${GREEN}✓ Trend analysis complete!${NC}"
    echo "Saved to: $REPORT_DIR/trend-analysis-$(date +%Y%m%d).md"
fi

echo ""
echo -e "${GREEN}Daily health check complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review the full report: cat $REPORT_FILE"
echo "  2. Address critical (🔴) issues first"
echo "  3. Schedule time for warnings (🟡)"
echo "  4. Share report with team if needed"
echo ""

# Optional: Send notification (uncomment and configure)
# if [ -n "$SLACK_WEBHOOK_URL" ]; then
#     curl -X POST -H 'Content-type: application/json' \
#         --data "{\"text\":\"Daily health check complete. Critical: $RED_COUNT, Warnings: $YELLOW_COUNT\"}" \
#         "$SLACK_WEBHOOK_URL"
# fi

exit 0
