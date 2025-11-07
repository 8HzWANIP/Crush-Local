#!/bin/bash
###############################################################################
# Batch Code Analysis Script
#
# Analyze multiple files or directories in batch using Crush CLI + LM Studio.
# Generates individual analysis reports for each target.
#
# Usage: ./batch-analyze.sh <file1> <file2> <dir1> ...
#        ./batch-analyze.sh --glob "src/**/*.js"
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
RESULTS_DIR="./batch-analysis-$(date +%Y%m%d-%H%M%S)"
SESSION_PREFIX="batch-analyze"
ANALYSIS_TYPE="comprehensive"  # comprehensive, security, quality, performance

# Parse arguments
TARGETS=()
USE_GLOB=false
GLOB_PATTERN=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --glob)
            USE_GLOB=true
            GLOB_PATTERN="$2"
            shift 2
            ;;
        --type)
            ANALYSIS_TYPE="$2"
            shift 2
            ;;
        -h|--help)
            cat << 'HELP'
Batch Code Analysis Script

Usage:
  ./batch-analyze.sh [options] <file1> <file2> <dir1> ...
  ./batch-analyze.sh --glob "pattern"

Options:
  --glob <pattern>   Use glob pattern (e.g., "src/**/*.js")
  --type <type>      Analysis type: comprehensive, security, quality, performance
  -h, --help         Show this help

Examples:
  # Analyze specific files
  ./batch-analyze.sh src/auth.js src/api.js

  # Analyze with glob pattern
  ./batch-analyze.sh --glob "src/**/*.{js,ts}"

  # Security-focused analysis
  ./batch-analyze.sh --type security --glob "src/**/*.js"

Analysis Types:
  comprehensive  - Full analysis (default)
  security       - Security vulnerabilities only
  quality        - Code quality and best practices
  performance    - Performance optimization opportunities
HELP
            exit 0
            ;;
        *)
            TARGETS+=("$1")
            shift
            ;;
    esac
done

# Validate inputs
if [ "$USE_GLOB" = true ]; then
    if [ -z "$GLOB_PATTERN" ]; then
        echo -e "${RED}Error: --glob requires a pattern${NC}"
        exit 1
    fi

    # Expand glob pattern
    shopt -s globstar nullglob
    eval "TARGETS=($GLOB_PATTERN)"
    shopt -u globstar nullglob
fi

if [ ${#TARGETS[@]} -eq 0 ]; then
    echo -e "${RED}Error: No targets specified${NC}"
    echo "Usage: $0 <file1> <file2> ..."
    echo "   or: $0 --glob \"pattern\""
    exit 1
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Batch Code Analysis with Crush CLI              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Analysis Type: $ANALYSIS_TYPE"
echo "  Targets: ${#TARGETS[@]} files/directories"
echo "  Results: $RESULTS_DIR"
echo ""

# Create results directory
mkdir -p "$RESULTS_DIR"

# Generate analysis prompt based on type
get_analysis_prompt() {
    local file_path="$1"
    local analysis_type="$2"
    local file_content="$3"

    case $analysis_type in
        security)
            cat << EOF
Perform a security analysis on this file:

FILE: $file_path

\`\`\`
$file_content
\`\`\`

Analyze for:
1. Security vulnerabilities (SQL injection, XSS, CSRF, etc.)
2. Insecure dependencies
3. Hardcoded secrets (API keys, passwords, tokens)
4. Insecure cryptographic operations
5. Authentication/authorization issues
6. Input validation gaps
7. Output encoding problems

For each issue found, provide:
- Severity: CRITICAL / HIGH / MEDIUM / LOW
- Description
- Line number(s)
- Remediation steps
- Code example of secure alternative

Rate overall security: SECURE / NEEDS ATTENTION / VULNERABLE
EOF
            ;;
        quality)
            cat << EOF
Perform a code quality analysis on this file:

FILE: $file_path

\`\`\`
$file_content
\`\`\`

Analyze for:
1. Code complexity (cyclomatic complexity)
2. Code duplication
3. Naming conventions adherence
4. Code organization and structure
5. Best practices compliance
6. Maintainability issues
7. Readability concerns
8. Documentation completeness

Provide:
- Quality Score: 0-100
- Issues by category with line numbers
- Refactoring recommendations
- Priority of improvements (High/Medium/Low)

Rate overall quality: EXCELLENT / GOOD / NEEDS IMPROVEMENT / POOR
EOF
            ;;
        performance)
            cat << EOF
Perform a performance analysis on this file:

FILE: $file_path

\`\`\`
$file_content
\`\`\`

Analyze for:
1. Algorithmic complexity (O(n²) or worse)
2. Inefficient loops and iterations
3. Memory leaks or excessive allocations
4. Database query optimization opportunities
5. Missing caching strategies
6. Blocking I/O operations
7. Unnecessary computations
8. Resource management issues

For each issue, provide:
- Performance Impact: HIGH / MEDIUM / LOW
- Description with line numbers
- Current complexity
- Optimization suggestion
- Expected improvement

Rate overall performance: OPTIMIZED / ACCEPTABLE / NEEDS OPTIMIZATION / CRITICAL
EOF
            ;;
        *)  # comprehensive
            cat << EOF
Perform a comprehensive code analysis on this file:

FILE: $file_path

\`\`\`
$file_content
\`\`\`

Analyze across all dimensions:

## 1. CODE QUALITY (Weight: 30%)
- Complexity and maintainability
- Best practices adherence
- Code organization

## 2. SECURITY (Weight: 30%)
- Vulnerabilities and risks
- Security best practices
- Sensitive data handling

## 3. PERFORMANCE (Weight: 20%)
- Algorithmic efficiency
- Resource usage
- Optimization opportunities

## 4. TESTING (Weight: 10%)
- Testability
- Test coverage adequacy
- Edge cases

## 5. DOCUMENTATION (Weight: 10%)
- Code comments
- Function documentation
- Clarity

Provide:
- Overall Score: 0-100
- Scores by dimension
- Top 5 issues with severity and line numbers
- 3 key recommendations
- Estimated time to address all issues

Summary rating: EXCELLENT / GOOD / FAIR / NEEDS WORK / CRITICAL
EOF
            ;;
    esac
}

# Process each target
SUCCESS_COUNT=0
FAILED_COUNT=0
TOTAL=${#TARGETS[@]}
CURRENT=0

echo -e "${GREEN}Starting batch analysis...${NC}"
echo ""

for target in "${TARGETS[@]}"; do
    CURRENT=$((CURRENT + 1))

    echo -e "${YELLOW}[$CURRENT/$TOTAL] Analyzing: $target${NC}"

    # Check if file exists and is readable
    if [ ! -r "$target" ]; then
        echo -e "${RED}  ✗ Cannot read file, skipping${NC}"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        continue
    fi

    # Check file size (skip if >1MB to avoid overwhelming the model)
    FILE_SIZE=$(wc -c < "$target")
    if [ $FILE_SIZE -gt 1048576 ]; then
        echo -e "${YELLOW}  ! File too large (>1MB), creating summary analysis${NC}"
        ANALYSIS="# Analysis Skipped\n\nFile: $target\nReason: File too large ($FILE_SIZE bytes)\n\nRecommendation: Analyze manually or split into smaller files."
        echo -e "$ANALYSIS" > "$RESULTS_DIR/$(basename "$target").analysis.txt"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        continue
    fi

    # Read file content
    FILE_CONTENT=$(cat "$target")

    # Generate prompt
    PROMPT=$(get_analysis_prompt "$target" "$ANALYSIS_TYPE" "$FILE_CONTENT")

    # Run analysis
    SESSION_NAME="$SESSION_PREFIX-$(date +%s)-$CURRENT"
    OUTPUT_FILE="$RESULTS_DIR/$(basename "$target").analysis.md"

    if crush chat --session "$SESSION_NAME" "$PROMPT" > "$OUTPUT_FILE" 2>&1; then
        echo -e "${GREEN}  ✓ Analysis complete${NC}"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))

        # Extract summary (first 10 lines)
        echo -e "${BLUE}  Summary:${NC}"
        head -10 "$OUTPUT_FILE" | sed 's/^/    /'

        # Clean up session
        crush session delete "$SESSION_NAME" 2>/dev/null || true
    else
        echo -e "${RED}  ✗ Analysis failed${NC}"
        FAILED_COUNT=$((FAILED_COUNT + 1))
    fi

    echo ""
done

# Generate consolidated report
echo -e "${YELLOW}Generating consolidated report...${NC}"

CONSOLIDATED_REPORT="$RESULTS_DIR/CONSOLIDATED_REPORT.md"

cat > "$CONSOLIDATED_REPORT" << EOF
# Batch Code Analysis Report

**Generated:** $(date)
**Analysis Type:** $ANALYSIS_TYPE
**Total Files:** $TOTAL
**Successful:** $SUCCESS_COUNT
**Failed:** $FAILED_COUNT

---

## Summary

EOF

# Add summaries from individual reports
for report in "$RESULTS_DIR"/*.analysis.md; do
    if [ -f "$report" ]; then
        filename=$(basename "$report" .analysis.md)
        echo "### $filename" >> "$CONSOLIDATED_REPORT"
        echo "" >> "$CONSOLIDATED_REPORT"
        echo '```' >> "$CONSOLIDATED_REPORT"
        head -20 "$report" >> "$CONSOLIDATED_REPORT"
        echo '```' >> "$CONSOLIDATED_REPORT"
        echo "" >> "$CONSOLIDATED_REPORT"
        echo "[View full analysis](./$filename.analysis.md)" >> "$CONSOLIDATED_REPORT"
        echo "" >> "$CONSOLIDATED_REPORT"
        echo "---" >> "$CONSOLIDATED_REPORT"
        echo "" >> "$CONSOLIDATED_REPORT"
    fi
done

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  Analysis Complete!                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Results Summary:${NC}"
echo "  ✓ Successful: $SUCCESS_COUNT"
echo "  ✗ Failed:     $FAILED_COUNT"
echo "  Total:       $TOTAL"
echo ""
echo -e "${YELLOW}Output:${NC}"
echo "  Directory: $RESULTS_DIR"
echo "  Consolidated: $CONSOLIDATED_REPORT"
echo ""
echo "View consolidated report:"
echo "  cat $CONSOLIDATED_REPORT"
echo ""
echo "Open in browser:"
echo "  # Install markdown viewer first (e.g., grip, markdown-preview)"
echo "  grip $CONSOLIDATED_REPORT"
echo ""

exit 0
