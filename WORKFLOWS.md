# Crush CLI + LM Studio: Sample Workflows and Prompts

## Overview

This document provides practical workflows, prompts, and examples for using Crush CLI with LM Studio for code analysis, agent orchestration, and automated development tasks.

---

## Table of Contents

1. [Codebase Scanning & Analysis](#codebase-scanning--analysis)
2. [Agent Orchestration Patterns](#agent-orchestration-patterns)
3. [Code Review Workflows](#code-review-workflows)
4. [Batch Processing](#batch-processing)
5. [Planning & Architecture](#planning--architecture)
6. [Automation Scripts](#automation-scripts)

---

## Codebase Scanning & Analysis

### Workflow 1: Initial Codebase Analysis

**Objective:** Understand a new codebase structure and identify key components.

**Prompt:**
```
I need you to analyze this codebase and provide:
1. Project structure overview
2. Main entry points and critical files
3. Technology stack and dependencies
4. Code quality assessment (complexity, maintainability)
5. Potential security concerns
6. Suggested improvements

Please scan the entire project and organize your findings by priority.
```

**Usage:**
```bash
cd /path/to/project
crush chat "$(cat << 'EOF'
I need you to analyze this codebase and provide:
1. Project structure overview
2. Main entry points and critical files
3. Technology stack and dependencies
4. Code quality assessment
5. Potential security concerns
6. Suggested improvements
EOF
)"
```

### Workflow 2: Dependency Analysis

**Prompt:**
```
Analyze the project dependencies and identify:
- Outdated packages with security vulnerabilities
- Unused dependencies
- Conflicting version requirements
- Recommended updates with breaking change warnings
- Alternative packages for better performance

Provide a prioritized action plan.
```

### Workflow 3: Dead Code Detection

**Prompt:**
```
Scan the codebase to identify:
1. Unused functions and methods
2. Unreachable code
3. Deprecated API usage
4. Unused imports and variables
5. Duplicate code blocks

For each finding, provide:
- File location and line numbers
- Reason for flagging
- Safe removal recommendations
```

### Workflow 4: Performance Bottleneck Analysis

**Prompt:**
```
Review the codebase for performance issues:
1. Inefficient algorithms (O(n²) or worse)
2. Unnecessary loops or iterations
3. Memory leaks or excessive allocations
4. Database query optimization opportunities
5. Missing caching strategies
6. Blocking I/O operations

Prioritize by potential performance impact.
```

---

## Agent Orchestration Patterns

### Pattern 1: Multi-Agent Code Review

**Architecture:** Lead Agent → [Scanner, Analyzer, Reviewer] → Consolidator

**Lead Agent Prompt:**
```
Act as a lead code review orchestrator. Delegate the following tasks:

1. SCANNER AGENT: Identify all changed files and categorize by type
2. ANALYZER AGENT: For each file, analyze:
   - Code complexity
   - Test coverage
   - Security implications
3. REVIEWER AGENT: Provide detailed feedback on:
   - Code quality
   - Best practices adherence
   - Potential bugs

Consolidate all findings into a prioritized review report.
```

**Implementation Example:**
```bash
# Create a session for the review
crush session create code-review-$(date +%s)

# Start the orchestration
crush chat --session code-review-latest "$(cat review-prompt.txt)"
```

### Pattern 2: Iterative Refactoring Agent

**Prompt:**
```
You are a refactoring agent. Follow this process:

PHASE 1: ANALYSIS
- Identify code smells in [TARGET_FILE]
- Rank issues by severity (critical, high, medium, low)
- Estimate refactoring effort for each

PHASE 2: PLANNING
- Create a step-by-step refactoring plan
- Identify dependencies and breaking changes
- Suggest test updates needed

PHASE 3: EXECUTION
- Apply refactoring in small, testable increments
- Run tests after each change
- Document changes made

PHASE 4: VALIDATION
- Verify functionality preservation
- Check performance impact
- Update documentation

Start with Phase 1 for: [TARGET_FILE]
```

### Pattern 3: Test Generation Agent Swarm

**Architecture:** Multiple specialized agents working in parallel

**Coordinator Prompt:**
```
Orchestrate test generation across the codebase:

AGENT 1 (Unit Tests):
- Generate unit tests for all public functions
- Aim for 80%+ code coverage
- Include edge cases and error conditions

AGENT 2 (Integration Tests):
- Identify integration points
- Create integration test scenarios
- Mock external dependencies

AGENT 3 (E2E Tests):
- Design end-to-end user workflows
- Create comprehensive E2E test suite
- Include happy path and error scenarios

Run all agents in parallel and consolidate results.
```

### Pattern 4: Documentation Agent Pipeline

**Prompt:**
```
Create comprehensive documentation through a pipeline:

STAGE 1: CODE DOCUMENTATION
- Add JSDoc/DocString comments to all functions
- Include parameter descriptions, return types, examples
- Document complex algorithms

STAGE 2: API DOCUMENTATION
- Generate API reference from code
- Create usage examples for each endpoint
- Document authentication and error codes

STAGE 3: README & GUIDES
- Update README.md with current setup instructions
- Create getting-started guide
- Add architecture overview

STAGE 4: CHANGELOG
- Review git history
- Generate CHANGELOG.md
- Categorize changes (features, fixes, breaking)

Process the entire project through this pipeline.
```

---

## Code Review Workflows

### Workflow 5: PR Review Automation

**Pre-Commit Review Prompt:**
```
Review the following changes before committing:

FILES CHANGED: [List of changed files]

For each file, check:
1. Code style and formatting
2. Potential bugs or logic errors
3. Security vulnerabilities
4. Performance implications
5. Test coverage adequacy
6. Documentation updates needed

Provide:
- Severity rating (🔴 Critical, 🟡 Warning, 🟢 Minor)
- Specific line-by-line feedback
- Actionable recommendations
- Approval status (Approve / Request Changes)
```

**Usage Script:**
```bash
#!/bin/bash
# pre-commit-review.sh

# Get staged files
CHANGED_FILES=$(git diff --cached --name-only)

# Create review prompt
REVIEW_PROMPT="Review the following changes:

FILES CHANGED:
$CHANGED_FILES

$(git diff --cached)

Provide detailed feedback on code quality, security, and best practices."

# Run Crush review
crush chat "$REVIEW_PROMPT" --session pre-commit-review

echo "Review complete. Check output for recommendations."
```

### Workflow 6: Security Audit

**Prompt:**
```
Conduct a comprehensive security audit:

VULNERABILITY SCANNING:
- SQL injection risks
- XSS vulnerabilities
- CSRF weaknesses
- Authentication/authorization flaws
- Sensitive data exposure
- Insecure dependencies

CODE SECURITY:
- Input validation gaps
- Output encoding issues
- Cryptographic weaknesses
- Secrets in code (API keys, passwords)
- Insecure file operations

CONFIGURATION:
- Secure defaults
- Environment variable handling
- HTTPS enforcement
- CORS configuration

Provide findings with OWASP severity ratings and remediation steps.
```

---

## Batch Processing

### Workflow 7: Batch Code Analysis

**Script:** `batch-analyze.sh`
```bash
#!/bin/bash
# Analyze multiple files in batch

FILES=(
  "src/auth/login.js"
  "src/auth/register.js"
  "src/api/users.js"
  "src/api/posts.js"
)

RESULTS_DIR="./analysis-results-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RESULTS_DIR"

for FILE in "${FILES[@]}"; do
  echo "Analyzing: $FILE"

  PROMPT="Analyze this file for:
- Code quality (1-10 rating)
- Complexity metrics
- Potential bugs
- Security issues
- Improvement suggestions

FILE: $FILE

$(cat "$FILE")"

  crush chat "$PROMPT" > "$RESULTS_DIR/$(basename "$FILE").analysis.txt"

  echo "✓ Completed: $FILE"
done

echo "All analyses complete. Results in: $RESULTS_DIR"
```

### Workflow 8: Bulk Refactoring

**Prompt Template:**
```
BULK REFACTORING TASK:

TARGET PATTERN: [Pattern to find]
REPLACEMENT: [New pattern]
FILES: [List of files or glob pattern]

STEPS:
1. Find all occurrences of the target pattern
2. Analyze each occurrence for context
3. Apply transformation safely
4. Verify no functionality changes
5. Generate summary report

SAFETY CHECKS:
- Preserve functionality
- Maintain test coverage
- No breaking changes
- Update related documentation

Execute refactoring with confirmation before each change.
```

### Workflow 9: Migration Assistant

**Prompt:**
```
Assist with codebase migration:

FROM: [Source framework/language/version]
TO: [Target framework/language/version]

MIGRATION PLAN:
1. Identify incompatible APIs
2. Map old APIs to new equivalents
3. Generate transformation rules
4. Prioritize migration order (low-risk first)
5. Create migration scripts
6. Update tests for new framework
7. Validate functionality parity

For each file:
- Analyze migration complexity (Easy/Medium/Hard)
- Provide step-by-step migration guide
- Flag manual review items

Start with dependency analysis.
```

---

## Planning & Architecture

### Workflow 10: Architecture Design

**Prompt:**
```
Design a scalable architecture for:

REQUIREMENTS:
[List of functional and non-functional requirements]

CONSTRAINTS:
[Technical constraints, budget, timeline]

DESIGN DELIVERABLES:
1. High-level architecture diagram (textual description)
2. Component breakdown with responsibilities
3. Data flow diagrams
4. Technology stack recommendations
5. Scalability considerations
6. Security architecture
7. Deployment strategy
8. Monitoring and observability plan

EVALUATION CRITERIA:
- Scalability
- Maintainability
- Security
- Cost-effectiveness
- Development velocity

Provide 2-3 architecture options with pros/cons.
```

### Workflow 11: Technical Decision Documentation

**Prompt:**
```
Document a technical decision using ADR (Architecture Decision Record) format:

CONTEXT:
[Problem statement and background]

DECISION:
[What was decided]

ALTERNATIVES CONSIDERED:
[Other options evaluated]

For each alternative, analyze:
1. Technical feasibility
2. Implementation complexity
3. Performance implications
4. Maintenance burden
5. Cost analysis
6. Risk assessment

CONSEQUENCES:
- Positive outcomes
- Negative impacts
- Mitigation strategies

STATUS: [Proposed/Accepted/Superseded]

Generate a comprehensive ADR document.
```

### Workflow 12: Sprint Planning Assistant

**Prompt:**
```
Assist with sprint planning:

BACKLOG ITEMS:
[List of user stories/tasks]

TEAM CAPACITY: [Story points or hours]
SPRINT DURATION: [Days]
PRIORITIES: [Must-have, Should-have, Nice-to-have]

ANALYSIS:
1. Break down large stories into tasks
2. Estimate complexity for each item
3. Identify dependencies
4. Detect potential blockers
5. Suggest optimal task ordering
6. Flag technical debt items

OUTPUT:
- Recommended sprint backlog
- Task assignments (based on expertise)
- Risk assessment
- Daily goals breakdown
- Definition of Done checklist

Optimize for maximum value delivery.
```

---

## Automation Scripts

### Script 1: Daily Code Health Check

**File:** `daily-health-check.sh`
```bash
#!/bin/bash
# Daily automated code health check

PROJECT_DIR="${1:-.}"
REPORT_FILE="health-report-$(date +%Y%m%d).md"

cat > health-check-prompt.txt << 'EOF'
Perform a daily code health check:

1. METRICS:
   - Lines of code added/removed (last 24h)
   - Test coverage changes
   - Number of TODOs/FIXMEs
   - Complexity trend

2. QUALITY CHECKS:
   - New linting errors
   - Type errors
   - Unused variables
   - Import issues

3. DEPENDENCIES:
   - Outdated packages
   - Security advisories
   - License compliance

4. GIT HEALTH:
   - Long-lived branches
   - Large uncommitted changes
   - Merge conflicts

Generate a summary report with action items.
EOF

cd "$PROJECT_DIR"

# Get recent changes
git log --since="24 hours ago" --stat > /tmp/git-changes.txt

# Run health check
crush chat "$(cat health-check-prompt.txt)" \
  --session daily-health-check \
  > "$REPORT_FILE"

echo "Health check complete: $REPORT_FILE"

# Optional: Send to Slack/Email
# ./send-report.sh "$REPORT_FILE"
```

### Script 2: Automated Documentation Update

**File:** `auto-doc-update.sh`
```bash
#!/bin/bash
# Automatically update documentation based on code changes

CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD | grep -E '\.(js|ts|py|go)$')

if [ -z "$CHANGED_FILES" ]; then
  echo "No code changes detected."
  exit 0
fi

PROMPT="The following files have changed:

$CHANGED_FILES

For each file, check if documentation needs updating:
1. README.md
2. API documentation
3. Code comments
4. CHANGELOG.md

Generate updated documentation sections where needed.
Provide git commit message for doc updates."

crush chat "$PROMPT" --session doc-update > /tmp/doc-updates.txt

# Review and apply updates
echo "Documentation updates ready. Review: /tmp/doc-updates.txt"
```

### Script 3: Continuous Code Review Bot

**File:** `review-bot.sh`
```bash
#!/bin/bash
# Continuous code review for new commits

LAST_REVIEWED_COMMIT=$(cat .last-reviewed-commit 2>/dev/null || echo "HEAD~10")
NEW_COMMITS=$(git log --pretty=format:"%H" $LAST_REVIEWED_COMMIT..HEAD)

if [ -z "$NEW_COMMITS" ]; then
  echo "No new commits to review."
  exit 0
fi

REVIEW_DIR="reviews/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$REVIEW_DIR"

for COMMIT in $NEW_COMMITS; do
  echo "Reviewing commit: $COMMIT"

  COMMIT_MSG=$(git log -1 --pretty=format:"%s" $COMMIT)
  COMMIT_DIFF=$(git show $COMMIT)

  PROMPT="Review this commit:

COMMIT: $COMMIT
MESSAGE: $COMMIT_MSG

DIFF:
$COMMIT_DIFF

Provide:
- Code quality assessment
- Potential issues
- Security concerns
- Testing recommendations
- Overall approval status"

  crush chat "$PROMPT" > "$REVIEW_DIR/commit-$COMMIT.review.txt"

  echo "✓ Reviewed: $COMMIT"
done

git rev-parse HEAD > .last-reviewed-commit

echo "All reviews complete: $REVIEW_DIR"
```

### Script 4: Smart Git Commit Message Generator

**File:** `smart-commit.sh`
```bash
#!/bin/bash
# Generate intelligent commit messages based on changes

STAGED_DIFF=$(git diff --cached)

if [ -z "$STAGED_DIFF" ]; then
  echo "No staged changes to commit."
  exit 1
fi

PROMPT="Generate a commit message for these changes:

$STAGED_DIFF

Follow Conventional Commits format:
<type>(<scope>): <subject>

<body>

<footer>

Types: feat, fix, docs, style, refactor, test, chore
- Subject: imperative mood, no period, max 50 chars
- Body: explain what and why (not how), wrap at 72 chars
- Footer: breaking changes, issue references

Generate commit message:"

COMMIT_MSG=$(crush chat "$PROMPT" --session smart-commit)

echo "Generated commit message:"
echo "---"
echo "$COMMIT_MSG"
echo "---"

read -p "Use this message? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  git commit -m "$COMMIT_MSG"
  echo "Committed successfully."
else
  echo "Commit cancelled."
fi
```

### Script 5: Project Bootstrap Assistant

**File:** `bootstrap-project.sh`
```bash
#!/bin/bash
# Bootstrap a new project with AI assistance

PROJECT_NAME="${1:-my-project}"
PROJECT_TYPE="${2:-node}" # node, python, go, etc.

PROMPT="Bootstrap a new $PROJECT_TYPE project named '$PROJECT_NAME':

1. DIRECTORY STRUCTURE:
   - Recommended folder organization
   - Essential files and their purposes

2. CONFIGURATION FILES:
   - Package manager config (package.json, requirements.txt, go.mod)
   - Linter configuration
   - Test framework setup
   - CI/CD configuration

3. BOILERPLATE CODE:
   - Entry point (main file)
   - Sample module/package structure
   - Basic tests
   - README template

4. DEPENDENCIES:
   - Essential packages
   - Development dependencies
   - Recommended tools

Generate all files and provide setup commands."

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

crush chat "$PROMPT" > bootstrap-plan.txt

echo "Bootstrap plan created: bootstrap-plan.txt"
echo "Review and execute the recommended setup steps."
```

---

## Advanced Workflows

### Workflow 13: AI Pair Programming Session

**Interactive Prompt Flow:**
```
SESSION START:
I'm working on [FEATURE/BUG]. Let's pair program together.

CONTEXT:
- Current file: [FILE_PATH]
- What I'm trying to do: [GOAL]
- Challenges I'm facing: [CHALLENGES]

WORKFLOW:
1. You suggest approach
2. I implement partially
3. You review and suggest next step
4. Repeat until complete

Let's start. What's your recommended approach?
```

### Workflow 14: Regression Testing After Refactoring

**Prompt:**
```
I've just refactored [COMPONENT/MODULE]. Help ensure no regressions:

REFACTORING SUMMARY:
[What changed and why]

VERIFICATION NEEDED:
1. Functionality parity check
2. Performance comparison (before/after)
3. API contract validation
4. Edge case testing
5. Integration point verification

APPROACH:
- Generate test cases covering all scenarios
- Compare outputs with previous implementation
- Flag any behavioral changes
- Recommend additional tests

Execute comprehensive regression analysis.
```

### Workflow 15: Legacy Code Modernization

**Prompt:**
```
Modernize this legacy code module:

CURRENT STATE:
- Language/Framework version: [OLD_VERSION]
- Code file: [FILE_PATH]
- Known issues: [LIST]

TARGET STATE:
- Language/Framework version: [NEW_VERSION]
- Modern patterns to adopt: [LIST]
- Backward compatibility requirements: [YES/NO]

MODERNIZATION PLAN:
1. Identify deprecated APIs and their replacements
2. Update syntax to modern standards
3. Apply current best practices
4. Improve error handling
5. Add type safety
6. Enhance testability
7. Update documentation

Provide step-by-step modernization with before/after comparisons.
```

---

## Integration Examples

### Example 1: Crush + Git Hooks

**File:** `.git/hooks/pre-push`
```bash
#!/bin/bash
# Run AI-powered checks before pushing

echo "Running pre-push checks..."

# Get commits being pushed
COMMITS=$(git log @{u}.. --pretty=format:"%H")

if [ -n "$COMMITS" ]; then
  PROMPT="Review these commits before pushing:

$(git log @{u}.. --stat)

Check for:
- Sensitive data (API keys, passwords)
- Debug code (console.log, breakpoints)
- TODOs that should be addressed
- Obvious bugs

Approve for push? (YES/NO with reasons)"

  RESULT=$(crush chat "$PROMPT" --session pre-push-check)

  echo "$RESULT"

  # Parse result (simplified - needs robust parsing)
  if echo "$RESULT" | grep -q "NO"; then
    echo "Push blocked by AI review. Check issues above."
    exit 1
  fi
fi

echo "Pre-push checks passed."
exit 0
```

### Example 2: CI/CD Integration

**File:** `.github/workflows/ai-review.yml`
```yaml
name: AI Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  ai-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Crush CLI
        run: npm install -g @charmland/crush

      - name: Setup LM Studio (or use API)
        run: |
          # Configure Crush to use hosted LM Studio or cloud API
          echo '${{ secrets.CRUSH_CONFIG }}' > .crush.json

      - name: Run AI Review
        run: |
          DIFF=$(git diff origin/main...HEAD)

          crush chat "Review this PR:

          $DIFF

          Provide:
          1. Code quality rating (1-10)
          2. Security issues
          3. Performance concerns
          4. Recommendations

          Format as GitHub comment markdown." > review.md

      - name: Post Review Comment
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('review.md', 'utf8');

            github.rest.issues.createComment({
              ...context.repo,
              issue_number: context.issue.number,
              body: review
            });
```

---

## Monitoring and Analytics

### Workflow 16: Code Quality Trending

**Script:** `quality-trend.sh`
```bash
#!/bin/bash
# Track code quality metrics over time

METRICS_FILE="metrics/quality-$(date +%Y%m%d).json"
mkdir -p metrics

PROMPT="Analyze current codebase and provide metrics:

1. Code Quality Score (0-100)
2. Test Coverage (%)
3. Documentation Coverage (%)
4. Technical Debt Hours
5. Complexity Average
6. Security Risk Level (Low/Medium/High)

Output as JSON format for trending analysis.

Also compare with previous metrics if available:
$(ls -t metrics/*.json 2>/dev/null | head -5)"

crush chat "$PROMPT" > "$METRICS_FILE"

# Generate trend report
if [ $(ls metrics/*.json 2>/dev/null | wc -l) -gt 5 ]; then
  TREND_PROMPT="Generate a trend analysis from these historical metrics:

$(cat metrics/*.json | tail -20)

Show:
- Quality trend (improving/declining)
- Key areas of improvement
- Concerning trends
- Recommendations"

  crush chat "$TREND_PROMPT" > metrics/trend-report.md
  echo "Trend report: metrics/trend-report.md"
fi
```

---

## Best Practices

### Effective Prompting Tips

1. **Be Specific:** Include file paths, line numbers, and context
2. **Set Constraints:** Define what should NOT be changed
3. **Request Format:** Specify output format (JSON, markdown, code)
4. **Iterative Refinement:** Start broad, then narrow focus
5. **Include Examples:** Show desired output format
6. **Session Management:** Use named sessions for related tasks

### Session Management

```bash
# Create focused sessions for different tasks
crush session create code-review
crush session create refactoring
crush session create documentation

# Switch between sessions
crush session use code-review

# List all sessions
crush session list

# Clear session when done
crush session delete code-review
```

### Performance Optimization

1. **Context Management:** Keep context focused and relevant
2. **Batch Similar Tasks:** Group related analyses together
3. **Use Appropriate Models:** Smaller models for simple tasks
4. **Cache Results:** Store analysis results for reuse
5. **Parallel Processing:** Run independent tasks concurrently

---

## Next Steps

- Customize workflows for your specific project needs
- Create project-specific prompt libraries
- Integrate with your CI/CD pipeline
- Set up automated daily/weekly reports
- Build a feedback loop to improve prompts over time

---

**Last Updated:** November 2025
