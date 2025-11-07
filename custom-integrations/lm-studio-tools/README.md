# Custom LM Studio Tools Integration for Crush CLI

## Overview

This integration allows Crush to **call your local LM Studio models as tools** during task execution, not just use them as the main LLM provider. This enables powerful workflows like:

- **Lead agent (Claude/OpenAI)** orchestrates tasks
- **Local models (via LM Studio)** act as specialized tools for specific operations
- **Multi-model collaboration** - Each model contributes its strengths

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Crush CLI                              │
│            (Main LLM: Claude/OpenAI/etc)                │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ├─── Built-in Tools (view, edit, grep, etc.)
                        │
                        ├─── MCP Tools (filesystem, git, etc.)
                        │
                        └─── LM Studio Tools (NEW!)
                             │
                             ▼
                   ┌─────────────────────┐
                   │  LM Studio MCP     │
                   │  Server            │
                   └──────────┬──────────┘
                              │
                              ▼
                   ┌─────────────────────┐
                   │  LM Studio API     │
                   │  (localhost:1234)  │
                   └──────────┬──────────┘
                              │
                              ▼
                   ┌─────────────────────┐
                   │  Your Local Models │
                   │  - Qwen3-30B       │
                   │  - Qwen2.5-32B     │
                   │  - DeepSeek-236B   │
                   └─────────────────────┘
```

## Solution Options

We provide **three** implementation options:

### Option 1: MCP Server (Recommended) ⭐
- **Pros:** Clean separation, follows MCP standard, reusable across MCP clients
- **Cons:** Requires Node.js/Python to run MCP server
- **Best for:** Production use, multi-client scenarios

### Option 2: Direct Crush Tool (Go Implementation)
- **Pros:** No external dependencies, integrated directly into Crush
- **Cons:** Requires rebuilding Crush from source
- **Best for:** Custom Crush builds, development

### Option 3: Hybrid - MCP Wrapper Script
- **Pros:** Quick to set up, no code changes
- **Cons:** Less flexible than full MCP server
- **Best for:** Quick prototyping, testing

---

## Implementation

This directory contains all three implementations:

```
custom-integrations/lm-studio-tools/
├── README.md                          # This file
├── option1-mcp-server/                # Full MCP server (Node.js/Python)
│   ├── lm-studio-mcp-server.js        # Node.js implementation
│   ├── lm-studio-mcp-server.py        # Python implementation
│   ├── package.json                   # Node dependencies
│   ├── requirements.txt               # Python dependencies
│   └── .crush.json                    # Crush configuration
├── option2-go-tool/                   # Direct Crush tool (requires rebuild)
│   ├── lm_studio_tool.go              # Go implementation
│   ├── lm_studio_tool.md              # Tool description
│   ├── BUILD.md                       # How to rebuild Crush
│   └── .crush.json                    # Crush configuration
└── option3-wrapper/                   # Simple wrapper script
    ├── lm-studio-wrapper.sh           # Bash MCP wrapper
    ├── lm-studio-wrapper.py           # Python MCP wrapper
    └── .crush.json                    # Crush configuration
```

---

## Quick Start

### Prerequisites

- Crush CLI installed
- LM Studio running with local server on `http://localhost:1234`
- At least one model loaded in LM Studio

### Choose Your Option

**For Quick Testing (5 minutes):**
```bash
cd custom-integrations/lm-studio-tools/option3-wrapper
./setup.sh
```

**For Production Use (15 minutes):**
```bash
cd custom-integrations/lm-studio-tools/option1-mcp-server
npm install  # or: pip install -r requirements.txt
./setup.sh
```

**For Custom Crush Build (30 minutes):**
```bash
cd custom-integrations/lm-studio-tools/option2-go-tool
./build-crush.sh
```

---

## Use Cases

### Use Case 1: Code Review with Specialized Models

**Scenario:** Use Claude Sonnet as orchestrator, local Qwen for code analysis

```bash
crush chat "Review this PR:

Use the 'lm_studio_code_analysis' tool to have the local Qwen3-30B model
analyze each changed file for:
- Code quality
- Potential bugs
- Security issues

Then synthesize the results into a comprehensive review."
```

**What happens:**
1. Claude (main LLM) orchestrates the review
2. Claude calls `lm_studio_code_analysis` tool multiple times
3. Each tool call sends code to local Qwen3-30B via LM Studio
4. Qwen3-30B analyzes code (fast, local, no API costs)
5. Claude synthesizes Qwen's analyses into final review

### Use Case 2: Multi-Model Architecture Design

**Scenario:** Use DeepSeek for planning, Qwen for implementation details

```bash
crush chat "Design a microservices architecture for e-commerce:

1. Use 'lm_studio_planning' (DeepSeek-236B) to create high-level architecture
2. Use 'lm_studio_code_gen' (Qwen3-30B) to generate service interfaces
3. Synthesize into complete design document"
```

### Use Case 3: Batch Code Analysis

**Scenario:** Analyze 100 files with local model, avoid API rate limits

```bash
crush chat "Analyze all Python files in src/ directory:

For each file, use 'lm_studio_analyze' to check:
- Complexity
- Test coverage needs
- Refactoring opportunities

Generate summary report with prioritized recommendations."
```

**Benefits:**
- No API costs for 100 file analyses
- No rate limits (local model)
- Fast inference with local GPU
- Privacy (code never leaves your machine)

### Use Case 4: Research Agent with Local Fact-Checking

**Scenario:** Main LLM does research, local model fact-checks

```bash
crush chat "Research the latest trends in AI for 2025:

1. Gather information from web sources
2. Use 'lm_studio_fact_check' (local model) to verify claims
3. Use 'lm_studio_summarize' to condense findings
4. Generate final research report"
```

---

## Available Tools

Each implementation provides these tools:

### `lm_studio_analyze`
**Purpose:** General code analysis
**Model:** Qwen3-30B-Q4 (fast)
**Parameters:**
- `code` (string): Code to analyze
- `language` (string): Programming language
- `focus` (string, optional): Analysis focus (quality, security, performance)

### `lm_studio_generate`
**Purpose:** Code generation
**Model:** Qwen2.5-32B-Q6 (quality)
**Parameters:**
- `prompt` (string): What to generate
- `language` (string): Programming language
- `style` (string, optional): Code style preferences

### `lm_studio_refactor`
**Purpose:** Code refactoring suggestions
**Model:** Qwen2.5-32B-Q6
**Parameters:**
- `code` (string): Code to refactor
- `language` (string): Programming language
- `constraints` (string, optional): Refactoring constraints

### `lm_studio_plan`
**Purpose:** Architecture and planning
**Model:** DeepSeek-236B-Q2 (reasoning, slow)
**Parameters:**
- `requirements` (string): Project requirements
- `constraints` (string): Technical constraints
- `output_format` (string, optional): Desired output format

### `lm_studio_custom`
**Purpose:** Custom prompt to any model
**Model:** User-specified
**Parameters:**
- `prompt` (string): The prompt to send
- `model` (string): Model ID in LM Studio
- `max_tokens` (int, optional): Max response tokens
- `temperature` (float, optional): Temperature (0.0-1.0)

---

## Configuration

### Basic Configuration

Add to `.crush.json`:

```json
{
  "$schema": "https://charm.land/crush.json",
  "mcp": {
    "lm-studio-tools": {
      "type": "stdio",
      "command": "node",
      "args": ["custom-integrations/lm-studio-tools/option1-mcp-server/lm-studio-mcp-server.js"],
      "env": {
        "LM_STUDIO_BASE_URL": "http://localhost:1234/v1",
        "LM_STUDIO_TIMEOUT": "60000"
      }
    }
  }
}
```

### Advanced Configuration

```json
{
  "$schema": "https://charm.land/crush.json",
  "providers": {
    "anthropic": {
      "models": [...]
    }
  },
  "mcp": {
    "lm-studio-fast": {
      "type": "stdio",
      "command": "node",
      "args": ["path/to/lm-studio-mcp-server.js"],
      "env": {
        "LM_STUDIO_BASE_URL": "http://localhost:1234/v1",
        "LM_STUDIO_MODEL": "qwen3-30b-q4",
        "LM_STUDIO_LABEL": "fast"
      }
    },
    "lm-studio-quality": {
      "type": "stdio",
      "command": "node",
      "args": ["path/to/lm-studio-mcp-server.js"],
      "env": {
        "LM_STUDIO_BASE_URL": "http://localhost:1234/v1",
        "LM_STUDIO_MODEL": "qwen2.5-32b-q6",
        "LM_STUDIO_LABEL": "quality"
      }
    },
    "lm-studio-reasoning": {
      "type": "stdio",
      "command": "node",
      "args": ["path/to/lm-studio-mcp-server.js"],
      "env": {
        "LM_STUDIO_BASE_URL": "http://localhost:1234/v1",
        "LM_STUDIO_MODEL": "deepseek-236b-q2",
        "LM_STUDIO_LABEL": "reasoning",
        "LM_STUDIO_TIMEOUT": "120000"
      }
    }
  }
}
```

---

## Troubleshooting

### Tool Not Appearing in Crush

**Check MCP server is running:**
```bash
# List available tools
crush tools

# Should show: mcp_lm-studio-tools_analyze, etc.
```

**Check logs:**
```bash
crush logs --follow
# Look for MCP connection errors
```

### "Connection Refused" Errors

**Verify LM Studio is running:**
```bash
curl http://localhost:1234/v1/models
# Should return list of loaded models
```

### Slow Performance

**For DeepSeek 236B:**
- Expected: 10-30 seconds per call
- This is normal due to CPU offloading
- Use for planning/reasoning only, not real-time tasks

**For Qwen models:**
- Expected: 2-8 seconds
- If slower, check GPU utilization: `nvidia-smi`

### Tool Calls Failing

**Check model is loaded in LM Studio:**
1. Open LM Studio
2. Verify model is loaded in "Local Server" tab
3. Check model ID matches configuration

---

## Performance Optimization

### Multi-Tool Instances

Run multiple LM Studio instances on different ports for parallel execution:

```bash
# Instance 1: Port 1234 - Qwen3-30B (fast)
# Instance 2: Port 1235 - Qwen2.5-32B (quality)
# Instance 3: Port 1236 - DeepSeek-236B (reasoning)
```

Configuration:
```json
{
  "mcp": {
    "lm-studio-fast": {
      "env": { "LM_STUDIO_BASE_URL": "http://localhost:1234/v1" }
    },
    "lm-studio-quality": {
      "env": { "LM_STUDIO_BASE_URL": "http://localhost:1235/v1" }
    },
    "lm-studio-reasoning": {
      "env": { "LM_STUDIO_BASE_URL": "http://localhost:1236/v1" }
    }
  }
}
```

### Caching

Enable response caching in MCP server:

```javascript
// In lm-studio-mcp-server.js
const ENABLE_CACHE = true;
const CACHE_TTL = 3600; // 1 hour
```

---

## Examples

See `examples/` directory for:
- `multi-model-code-review.md` - Full code review workflow
- `architecture-design.md` - Architecture planning with DeepSeek
- `batch-analysis.md` - Analyzing 100+ files
- `research-agent.md` - Research with fact-checking

---

## Contributing

Want to add more tools or improve the integration? See `CONTRIBUTING.md`.

---

## Next Steps

1. Choose your implementation option (1, 2, or 3)
2. Follow setup instructions in that option's directory
3. Test with simple prompt
4. Explore use case examples
5. Customize for your workflow

---

**Ready to unleash local models as tools in Crush CLI!** 🚀
