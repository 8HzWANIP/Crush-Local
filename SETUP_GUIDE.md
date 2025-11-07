# Crush CLI + LM Studio: Local Agentic Coding System Setup Guide

## Overview

This guide provides comprehensive instructions for setting up a truly local agentic coding system using Crush CLI connected to LM Studio, maximizing your high-end hardware (Nvidia RTX 5090 with 32GB VRAM, DDR5 RAM) for AI-powered code analysis, planning, and review.

## Table of Contents

1. [Installation](#installation)
2. [LM Studio Configuration](#lm-studio-configuration)
3. [Crush CLI Integration](#crush-cli-integration)
4. [Model Context Protocol (MCP) Setup](#model-context-protocol-mcp-setup)
5. [Performance Optimization](#performance-optimization)
6. [Recommended Models](#recommended-models)
7. [Sample Workflows](#sample-workflows)
8. [Troubleshooting](#troubleshooting)

---

## Installation

### 1. Crush CLI Installation

Crush CLI supports multiple installation methods across platforms:

#### **macOS/Linux (Homebrew)**
```bash
brew install charmbracelet/tap/crush
```

#### **NPM (Cross-platform)**
```bash
npm install -g @charmland/crush
```

#### **Windows (Winget)**
```bash
winget install charmbracelet.crush
```

#### **Windows (Scoop)**
```bash
scoop install crush
```

#### **Arch Linux**
```bash
yay -S crush-bin
```

#### **Nix**
```bash
nix-env -iA nixpkgs.crush
```

### 2. LM Studio Installation

1. Download LM Studio from [lmstudio.ai](https://lmstudio.ai)
2. Install for your platform (Windows, macOS, or Linux)
3. Launch LM Studio and verify GPU detection

**Version Requirement:** LM Studio 0.3.15+ is required for RTX 50-series GPU support.

---

## LM Studio Configuration

### Hardware Optimization for RTX 5090 (32GB VRAM)

#### **Recommended Settings**

**For Medium-Large Models (30B-70B parameters):**
- **Context Length:** 8,000-16,000 tokens
- **Evaluation Batch Size:** 1,024-2,048
- **GPU Layers:** Set to maximum (offload all layers to GPU)
- **Memory Allocation:** Enable "Limit model weights to dedicated GPU memory"

**For Smaller Models (7B-20B parameters):**
- **Context Length:** 16,000-32,000 tokens
- **Evaluation Batch Size:** 2,048-4,096
- **GPU Layers:** Maximum
- **Multi-model Support:** Can run multiple models simultaneously

#### **Multi-GPU Setup (if applicable)**

LM Studio 0.3.14+ supports advanced multi-GPU controls:
- Enable/disable specific GPUs
- Choose allocation strategy (balanced, performance, memory-optimized)
- Limit model weights to dedicated GPU memory

### Starting the Local API Server

1. Open LM Studio
2. Navigate to **"Local Server"** tab
3. Select your model from the dropdown
4. Click **"Start Server"**
5. Default endpoint: `http://localhost:1234/v1/`

**API Features:**
- OpenAI-compatible endpoints
- `/v1/models` - List available models
- `/v1/chat/completions` - Chat interface
- `/v1/completions` - Single-shot completions
- `/v1/embeddings` - Text embeddings
- Enhanced REST API with token/second metrics

---

## Crush CLI Integration

### Configuration File: `.crush.json`

Create a `.crush.json` file in your project directory or home folder (`~/.config/crush/crush.json`).

#### **Basic LM Studio Configuration**

```json
{
  "$schema": "https://charm.land/crush.json",
  "providers": {
    "lmstudio": {
      "name": "LM Studio",
      "base_url": "http://localhost:1234/v1/",
      "type": "openai-compat",
      "models": [
        {
          "name": "Qwen3-Coder-30B",
          "id": "qwen/qwen3-coder-30b",
          "context_window": 32768,
          "default_max_tokens": 4096
        },
        {
          "name": "DeepSeek-Coder-V3-20B",
          "id": "deepseek/deepseek-coder-v3-20b",
          "context_window": 16384,
          "default_max_tokens": 2048
        }
      ]
    }
  },
  "default_provider": "lmstudio"
}
```

#### **Advanced Configuration with Multiple Providers**

```json
{
  "$schema": "https://charm.land/crush.json",
  "providers": {
    "lmstudio-code": {
      "name": "LM Studio - Code Analysis",
      "base_url": "http://localhost:1234/v1/",
      "type": "openai-compat",
      "models": [
        {
          "name": "Qwen3-Coder-70B",
          "id": "qwen/qwen3-coder-70b",
          "context_window": 32768,
          "default_max_tokens": 4096
        }
      ]
    },
    "lmstudio-planning": {
      "name": "LM Studio - Planning",
      "base_url": "http://localhost:1234/v1/",
      "type": "openai-compat",
      "models": [
        {
          "name": "DeepSeek-R1",
          "id": "deepseek/deepseek-r1",
          "context_window": 64000,
          "default_max_tokens": 8000
        }
      ]
    }
  },
  "default_provider": "lmstudio-code"
}
```

### Configuration Priority

Crush searches for configuration in this order:
1. `./.crush.json` (current directory)
2. `./crush.json` (current directory)
3. `$HOME/.config/crush/crush.json` (global config)

---

## Model Context Protocol (MCP) Setup

MCP enables Crush to connect to external services and tools for enhanced agent orchestration.

### MCP Server Configuration

Add MCP servers to your `.crush.json`:

```json
{
  "$schema": "https://charm.land/crush.json",
  "providers": {
    "lmstudio": {
      "name": "LM Studio",
      "base_url": "http://localhost:1234/v1/",
      "type": "openai-compat",
      "models": [...]
    }
  },
  "mcp_servers": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/workspace"],
      "env": {
        "NODE_ENV": "production"
      }
    },
    "github": {
      "type": "http",
      "url": "https://api.github.com/mcp/",
      "headers": {
        "Authorization": "$(echo Bearer $GITHUB_TOKEN)"
      }
    },
    "code-analysis": {
      "type": "stdio",
      "command": "python",
      "args": ["/path/to/custom-code-analyzer.py"]
    }
  }
}
```

### MCP Transport Types

1. **stdio** - Command-line servers (most common for local tools)
2. **http** - HTTP endpoints (for web services)
3. **sse** - Server-Sent Events (for streaming services)

### Environment Variable Expansion

Use `$(echo $VAR)` syntax for sensitive data:
```json
"headers": {
  "Authorization": "$(echo Bearer $API_TOKEN)"
}
```

---

## Performance Optimization

### DDR5 RAM Utilization (6000MHz+)

Your high-speed DDR5 RAM enables:
- **Faster Model Loading:** Reduced startup time for large models
- **Better Multi-Model Performance:** Run multiple models simultaneously
- **Enhanced Context Processing:** Handle larger context windows efficiently

### GPU Optimization for RTX 5090

#### **Memory Management**
```
Model Size          | Quantization | VRAM Usage | Context Window
--------------------|-------------|-----------|----------------
7B parameters       | Q8          | ~8GB      | 32K-128K
20B parameters      | Q8          | ~22GB     | 16K-32K
30B parameters      | Q6          | ~24GB     | 16K-32K
70B parameters      | Q4          | ~28GB     | 8K-16K
```

#### **Batch Size Optimization**

- **Small batches (256-512):** Lower latency, faster first token
- **Medium batches (1024-2048):** Balanced performance
- **Large batches (4096+):** Maximum throughput for batch processing

### LM Studio Performance Tips

1. **Enable GPU Acceleration:** Ensure CUDA is properly installed
2. **Use Quantized Models:** Q4_K_M or Q6_K for optimal balance
3. **Adjust Thread Count:** Match physical core count
4. **Monitor Memory:** Use Task Manager/htop to track usage
5. **Persistent Model Loading:** Keep frequently-used models loaded

---

## Recommended Models

### Best Local LLMs for Code Analysis (2025)

#### **Top Tier (70B+ parameters)**

1. **Qwen3-Coder-70B** ⭐ RECOMMENDED
   - **Strengths:** Multi-language support, long context, agentic tasks
   - **VRAM:** ~28GB (Q4), ~40GB (Q6)
   - **Context:** 32K-64K tokens
   - **Best for:** Complex code analysis, multi-file refactoring

2. **DeepSeek-R1** ⭐ RECOMMENDED
   - **Strengths:** Advanced reasoning, code planning, architecture design
   - **VRAM:** ~30GB (Q4)
   - **Context:** 64K tokens
   - **Best for:** Planning, design decisions, code reviews

3. **Code Llama 70B**
   - **Strengths:** Proven performance, broad language support
   - **VRAM:** ~35GB (Q4)
   - **Context:** 16K tokens
   - **Best for:** General coding tasks, code generation

#### **Mid Tier (20B-30B parameters)**

4. **Qwen2.5-Coder-30B** ⭐ BEST BALANCE
   - **Strengths:** Excellent performance-to-size ratio
   - **VRAM:** ~18GB (Q6), ~12GB (Q4)
   - **Context:** 32K tokens
   - **Best for:** Daily coding tasks, real-time assistance

5. **DeepSeek-Coder-V3-20B**
   - **Strengths:** Fast inference, good code understanding
   - **VRAM:** ~15GB (Q6)
   - **Context:** 16K tokens
   - **Best for:** Quick code checks, syntax analysis

6. **Devastral**
   - **Strengths:** Multi-step planning, code translation
   - **VRAM:** Varies by variant
   - **Best for:** Complex refactoring, language migration

#### **Efficient Tier (7B-13B parameters)**

7. **StarCoder2-15B**
   - **Strengths:** Fast, efficient, good for real-time
   - **VRAM:** ~10GB (Q6)
   - **Best for:** Quick suggestions, autocomplete

8. **Phi-3 Mini**
   - **Strengths:** Extremely efficient, good reasoning
   - **VRAM:** ~4GB
   - **Best for:** Low-latency tasks, multiple instances

### Model Selection Strategy

**For Your RTX 5090 Setup:**

| Use Case | Primary Model | Fallback Model |
|----------|--------------|----------------|
| Code Review | Qwen3-Coder-70B (Q4) | Qwen2.5-Coder-30B (Q6) |
| Planning & Design | DeepSeek-R1 (Q4) | Qwen3-Coder-30B |
| Real-time Coding | Qwen2.5-Coder-30B (Q6) | StarCoder2-15B |
| Batch Analysis | Code Llama 70B (Q4) | DeepSeek-Coder-V3-20B |

---

## Sample Workflows

See [WORKFLOWS.md](./WORKFLOWS.md) for detailed workflow examples and prompts.

---

## Troubleshooting

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues and solutions.

---

## Additional Resources

- [Crush CLI GitHub](https://github.com/charmbracelet/crush)
- [LM Studio Documentation](https://lmstudio.ai/docs)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Example Configurations](./examples/)

---

## Quick Start Checklist

- [ ] Install Crush CLI
- [ ] Install LM Studio (v0.3.15+)
- [ ] Download recommended model (Qwen2.5-Coder-30B)
- [ ] Start LM Studio local server
- [ ] Create `.crush.json` configuration
- [ ] Test connection: `crush chat "Hello, test local model"`
- [ ] Configure MCP servers (optional)
- [ ] Set up workflow automation scripts

---

**Last Updated:** November 2025
**Tested with:** Crush CLI v1.x, LM Studio 0.3.15+, RTX 5090 (32GB VRAM)
