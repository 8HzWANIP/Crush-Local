# LM Studio Tools - Usage Guide

## Quick Start Example

Once your MCP server is running, you can use local LM Studio models as tools in Crush:

```bash
crush chat "Analyze this Python function for security issues using the lm_studio_analyze tool:

def login(username, password):
    query = f\"SELECT * FROM users WHERE username='{username}' AND password='{password}'\"
    return db.execute(query)
"
```

**What happens:**
1. Crush (using Claude/GPT as main LLM) receives your request
2. Claude decides to call the `mcp_lm-studio-tools_analyze` tool
3. The tool sends the code to your local Qwen3-30B model via LM Studio
4. Qwen3-30B analyzes the code (finds SQL injection!)
5. Qwen's analysis is returned to Claude
6. Claude synthesizes the final response

---

## Example 1: Multi-Model Code Review

**Scenario:** Use Claude as orchestrator, local Qwen for detailed code analysis

```bash
crush chat "Review this entire pull request:

Use mcp_lm-studio-tools_analyze to have the local model analyze each changed file:
- auth/login.js (150 lines)
- auth/register.js (200 lines)
- api/users.js (300 lines)

For each file, check:
- Security vulnerabilities
- Code quality
- Performance issues

Then provide a comprehensive PR review synthesizing all findings."
```

**Benefits:**
- ✅ Main LLM (Claude) orchestrates the review strategy
- ✅ Local model does heavy lifting (analyzing 650 lines of code)
- ✅ No API costs for code analysis
- ✅ Privacy - code never leaves your machine
- ✅ Fast - local GPU inference

**Expected workflow:**
1. Claude creates review strategy
2. Claude calls `mcp_lm-studio-tools_analyze` 3 times (once per file)
3. Each call sends file to local Qwen3-30B
4. Qwen analyzes each file (~5 seconds each = 15 seconds total)
5. Claude synthesizes 3 analyses into comprehensive review

---

## Example 2: Architecture Design with DeepSeek

**Scenario:** Use DeepSeek's reasoning for architecture planning

### Step 1: Configure DeepSeek instance

```json
{
  "mcp": {
    "lm-studio-reasoning": {
      "type": "stdio",
      "command": "node",
      "args": ["path/to/lm-studio-mcp-server.js"],
      "env": {
        "LM_STUDIO_BASE_URL": "http://localhost:1234/v1",
        "LM_STUDIO_MODEL": "deepseek-coder-v2-236b-q2",
        "LM_STUDIO_TIMEOUT": "120000",
        "LM_STUDIO_LABEL": "reasoning"
      }
    }
  }
}
```

### Step 2: Use in Crush

```bash
crush chat "Design a microservices architecture for an e-commerce platform.

Requirements:
- 100k daily active users
- Product catalog (50k items)
- Real-time inventory
- Payment processing
- Admin dashboard

Budget: $5k/month AWS
Team: 5 developers
Timeline: 6 months

Use mcp_lm-studio-reasoning_plan to create the high-level architecture,
then use mcp_lm-studio-tools_generate to create service interfaces."
```

**What happens:**
1. Crush calls `mcp_lm-studio-reasoning_plan` with requirements
2. DeepSeek-236B (running with CPU offloading) creates architecture (~20-30 seconds)
3. Crush receives DeepSeek's architecture
4. Crush calls `mcp_lm-studio-tools_generate` for each service interface
5. Qwen3-30B generates service code (~5 seconds each)
6. Crush synthesizes everything into complete design document

---

## Example 3: Batch Code Analysis

**Scenario:** Analyze 50 Python files for technical debt

```bash
crush chat "Analyze all Python files in src/ for technical debt.

For EACH file:
1. Use mcp_lm-studio-tools_analyze to check complexity and maintainability
2. Rate technical debt level (Low/Medium/High)
3. Estimate refactoring hours

Generate summary report with:
- Total technical debt hours
- Top 10 files by debt
- Prioritized refactoring recommendations"
```

**Benefits:**
- 50 file analyses = 50 local API calls = $0 cost
- vs. 50 cloud API calls ≈ $2-5
- No rate limits
- No PII/code leaving your machine

---

## Example 4: Custom Prompts with Different Models

```bash
# Fast analysis with Qwen3-30B
crush chat "Use mcp_lm-studio-tools_custom with these parameters:
{
  \"prompt\": \"Explain OAuth 2.0 flow in simple terms\",
  \"model\": \"qwen3-30b-q4\",
  \"temperature\": 0.3,
  \"max_tokens\": 500
}"

# Deep reasoning with DeepSeek-236B
crush chat "Use mcp_lm-studio-tools_custom with these parameters:
{
  \"prompt\": \"Design a distributed consensus algorithm for microservices\",
  \"model\": \"deepseek-coder-v2-236b-q2\",
  \"temperature\": 0.8,
  \"max_tokens\": 4000,
  \"system_prompt\": \"You are a distributed systems expert. Think step by step.\"
}"
```

---

## Example 5: Refactoring Legacy Code

```bash
crush chat "I need to refactor this legacy PHP code to modern Python.

Step 1: Use mcp_lm-studio-tools_analyze to understand the PHP code
Step 2: Use mcp_lm-studio-tools_plan to create refactoring strategy
Step 3: Use mcp_lm-studio-tools_generate to create Python equivalent
Step 4: Use mcp_lm-studio-tools_analyze to verify Python code quality

Here's the PHP code:
[paste legacy code]
"
```

---

## Example 6: Multi-Language Codebase Analysis

```bash
crush chat "This repository has:
- 50 JavaScript files (frontend)
- 30 Python files (backend API)
- 20 Go files (microservices)

Use the appropriate lm_studio tools to:
1. Analyze each language separately
2. Identify cross-language integration issues
3. Suggest architecture improvements

Focus on:
- Security across all layers
- API consistency
- Error handling patterns"
```

---

## Pro Tips

### Tip 1: Parallel Tool Calls

Crush can call tools in parallel:

```bash
crush chat "Analyze these 3 files in parallel using mcp_lm-studio-tools_analyze:
- auth.js
- database.js
- api.js

Provide combined security assessment."
```

### Tip 2: Mix Cloud and Local

```bash
crush chat "I'm going to use Claude (you) for strategic planning and local models for execution.

You (Claude): Create the overall code review strategy
Local model: Analyze each file for issues (use mcp_lm-studio-tools_analyze)
You (Claude): Synthesize findings and prioritize fixes"
```

### Tip 3: Cache Frequently-Used Analyses

Enable caching in MCP server config:

```bash
export LM_STUDIO_ENABLE_CACHE=true
export LM_STUDIO_CACHE_TTL=3600  # 1 hour
```

Same analysis within 1 hour = instant response from cache

### Tip 4: Multiple LM Studio Instances

Run different models on different ports:

```bash
# Terminal 1: Fast model on port 1234
# LM Studio: Load Qwen3-30B-Q4, start server on 1234

# Terminal 2: Quality model on port 1235
# LM Studio: Load Qwen2.5-32B-Q6, start server on 1235

# Terminal 3: Reasoning model on port 1236
# LM Studio: Load DeepSeek-236B-Q2, start server on 1236
```

Configure three separate MCP servers in `.crush.json`:

```json
{
  "mcp": {
    "lm-fast": {
      "env": { "LM_STUDIO_BASE_URL": "http://localhost:1234/v1", "LM_STUDIO_LABEL": "fast" }
    },
    "lm-quality": {
      "env": { "LM_STUDIO_BASE_URL": "http://localhost:1235/v1", "LM_STUDIO_LABEL": "quality" }
    },
    "lm-reasoning": {
      "env": { "LM_STUDIO_BASE_URL": "http://localhost:1236/v1", "LM_STUDIO_LABEL": "reasoning" }
    }
  }
}
```

Then use specific tools:
- `mcp_lm-fast_analyze` - Quick checks
- `mcp_lm-quality_generate` - High-quality code generation
- `mcp_lm-reasoning_plan` - Deep architectural planning

---

## Common Patterns

### Pattern 1: Orchestrator + Workers

```
Main LLM (Cloud): Strategic planning and synthesis
Local Models (LM Studio): Heavy lifting and execution
```

### Pattern 2: Specialist Models

```
DeepSeek-236B: Architecture, planning, reasoning
Qwen2.5-32B: Code generation, refactoring
Qwen3-30B: Quick analysis, reviews
```

### Pattern 3: Hybrid Cloud-Local

```
Step 1: Cloud LLM plans (5 API calls)
Step 2: Local models execute (50 calls, $0)
Step 3: Cloud LLM synthesizes (1 API call)

Total: 6 cloud calls instead of 56
Savings: ~90% on API costs
```

---

## Troubleshooting Usage

### "Tool not found" errors

```bash
# List available tools
crush tools

# Should show:
# - mcp_lm-studio-tools_analyze
# - mcp_lm-studio-tools_generate
# etc.

# If not showing, check MCP server status
crush logs --follow
```

### Slow responses

- **Expected for DeepSeek-236B:** 10-30 seconds
- **Expected for Qwen models:** 2-8 seconds
- **If slower:** Check GPU utilization with `nvidia-smi`

### "Connection refused" errors

```bash
# Verify LM Studio is running
curl http://localhost:1234/v1/models

# Should return JSON with loaded models
```

---

## Advanced: Custom Workflows

### Workflow 1: Daily Code Quality Check

```bash
#!/bin/bash
# daily-quality-check.sh

crush chat "Run daily code quality check:

1. Use mcp_lm-studio-tools_analyze on all files changed in last 24h
2. Check for:
   - New security vulnerabilities
   - Increased complexity
   - Missing tests
   - Code style violations

3. Generate report with:
   - Issues by severity
   - Trend vs. yesterday
   - Action items

Use local models to minimize API costs."
```

### Workflow 2: PR Review Bot

```bash
#!/bin/bash
# pr-review-bot.sh

PR_FILES=$(git diff --name-only main...HEAD)

crush chat "Review this PR using local models for analysis:

Files changed:
$PR_FILES

For each file:
1. Use mcp_lm-studio-tools_analyze for automated review
2. Focus on security, quality, performance

Synthesize into PR comment with:
- Approval recommendation
- Critical issues (must fix)
- Suggestions (nice to have)
- Positive highlights"
```

---

## Cost Comparison

### Scenario: Analyze 100 files

**Option A: Cloud only**
- 100 API calls to Claude
- Cost: ~$3-5
- Time: ~10 minutes (rate limits)

**Option B: Hybrid (this solution)**
- 1 planning call to Claude: $0.03
- 100 analysis calls to local: $0
- 1 synthesis call to Claude: $0.03
- **Total: $0.06**
- Time: ~8 minutes (parallel local calls)

**Savings: 98%** 🎉

---

## Next Steps

1. Try the Quick Start example above
2. Experiment with your own prompts
3. Create custom workflows for your team
4. Share your use cases!

Happy coding with local AI tools! 🚀
