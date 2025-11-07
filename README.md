# Crush CLI + LM Studio: Local Agentic Coding System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Crush CLI](https://img.shields.io/badge/Crush-CLI-blueviolet)](https://github.com/charmbracelet/crush)
[![LM Studio](https://img.shields.io/badge/LM-Studio-green)](https://lmstudio.ai/)

> A comprehensive guide and toolkit for setting up a truly local, GPU-accelerated agentic coding system using Crush CLI connected to LM Studio. Maximize your high-end hardware (Nvidia RTX 5090, DDR5 RAM) for AI-powered code analysis, planning, and automation.

---

## 🚀 Quick Start

```bash
# 1. Clone this repository
git clone <repository-url>
cd Crush-Local

# 2. Install Crush CLI
npm install -g @charmland/crush
# or: brew install charmbracelet/tap/crush

# 3. Install LM Studio
# Download from: https://lmstudio.ai

# 4. Copy your config
cp examples/your-models.crush.json .crush.json

# 5. Start LM Studio server
# Open LM Studio → Local Server → Select Model → Start Server

# 6. Test connection
crush chat "Hello! Test local model."

# 7. Try automation scripts
chmod +x scripts/*.sh
./scripts/daily-health-check.sh
```

---

## 📋 What's Included

### 📚 Documentation

| File | Description |
|------|-------------|
| **[SETUP_GUIDE.md](SETUP_GUIDE.md)** | Complete installation and configuration guide |
| **[WORKFLOWS.md](WORKFLOWS.md)** | Sample workflows, prompts, and agent orchestration patterns |
| **[MULTI_AGENT_GUIDE.md](MULTI_AGENT_GUIDE.md)** | ⭐ **Multi-agent orchestration with reasoning models** |
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** | Common issues and solutions |
| **[RESOURCES.md](RESOURCES.md)** | Community links, tools, and learning resources |

### ⚙️ Configuration Examples

Located in `examples/`:

- `basic-lmstudio.crush.json` - Simple single-model setup
- `multi-model.crush.json` - Multiple models for different tasks
- `with-mcp-servers.crush.json` - MCP server integrations
- `advanced-optimization.crush.json` - Performance-optimized config
- `your-models.crush.json` - **YOUR personalized config based on installed models**

### 🤖 Automation Scripts

Located in `scripts/`:

| Script | Purpose |
|--------|---------|
| `daily-health-check.sh` | Automated daily codebase health analysis |
| `smart-commit.sh` | AI-generated conventional commit messages |
| `batch-analyze.sh` | Batch analysis of multiple files |
| `code-review-pr.sh` | Comprehensive PR review automation |

All scripts are executable and ready to use!

---

## 🎯 Key Features

### ✨ Fully Local Operation
- **Zero Cloud Dependency:** All processing happens on your hardware
- **Privacy-First:** Your code never leaves your machine
- **No Recurring Costs:** One-time hardware investment only
- **Offline Capable:** Work without internet connection

### ⚡ Hardware Optimization
- **RTX 5090 Support:** Optimized for 32GB VRAM
- **DDR5 RAM Utilization:** Fast model loading and context processing
- **Multi-Model Support:** Run multiple models based on task complexity
- **Quantization Strategies:** Balance between quality and performance

### 🧠 Agent Orchestration
- **Model Context Protocol (MCP):** Connect to external tools and services
- **Multi-Agent Workflows:** Lead agent delegates to specialized sub-agents
- **Session Management:** Maintain context across multiple interactions
- **Batch Processing:** Analyze entire codebases efficiently

### 🛠️ Comprehensive Workflows
- **Codebase Scanning:** Analyze structure, dependencies, and quality
- **Code Review:** Automated PR reviews with detailed feedback
- **Security Audits:** Vulnerability scanning and remediation
- **Refactoring:** AI-guided code improvement
- **Documentation:** Auto-generate and update docs
- **Planning:** Architecture design and technical decisions

---

## 📊 Your Hardware Setup

### Installed Models

You have the following models ready to use:

| Model | Quantization | Size | Best For |
|-------|-------------|------|----------|
| **Qwen2.5 Coder 32B Instruct** | Q6_K | 25.04 GB | ⭐ Primary - Complex analysis, highest quality |
| **Qwen3 Coder 30B A3B** | Q4_K_M | 17.35 GB | ⚡ Fast - Real-time coding assistance |
| **Qwen2.5 Coder 32B** | Q4_K_M | 18.49 GB | ⚖️ Balanced - Quick tasks, good quality |
| **DeepSeek Coder v2 236B** | Q2_K | 80.04 GB | 🧠 **Reasoning** - Multi-agent orchestration, architecture |
| **Nomic Embed Text v1.5** | Q4_K_M | 80.21 MB | 📝 Embeddings - Semantic search |

### 🔥 Special Note: Multi-Agent Workflows with DeepSeek 236B

Your **DeepSeek Coder v2 236B** is perfect for multi-agent orchestration and complex reasoning tasks! However, at 80GB, it won't fit entirely in your 32GB VRAM. Here's how to use it effectively:

**Option 1: CPU Offloading (Slower but Works)**
- LM Studio can offload layers to CPU/RAM
- Inference will be slower (10-30 seconds per response vs 1-5 seconds)
- Perfect for planning/architecture where quality > speed
- Your DDR5 6000MHz RAM will help significantly

**Option 2: Download a Smaller Reasoning Model**
Consider adding one of these reasoning-focused models that fit in 32GB:
- **DeepSeek-R1-Distill-Qwen-32B Q4** (~18GB) - Distilled reasoning model
- **Qwen2.5-32B-Instruct Q6** (you have this!) - Also has good reasoning
- **Code Llama 70B Q2** (~35GB with offload) - Needs some CPU offload

**For Multi-Agent Setup:** See [MULTI_AGENT_GUIDE.md](MULTI_AGENT_GUIDE.md) for detailed instructions!

### Recommended Usage by Task

```
┌──────────────────────────────────────────────────────────────────┐
│ Task Type              │ Recommended Model                       │
├────────────────────────┼─────────────────────────────────────────┤
│ Real-time coding       │ Qwen3 Coder 30B (Q4)                   │
│ Code review            │ Qwen2.5 Coder 32B (Q6)                 │
│ Quick analysis         │ Qwen2.5 Coder 32B (Q4)                 │
│ Complex refactoring    │ Qwen2.5 Coder 32B (Q6)                 │
│ Multi-agent lead       │ DeepSeek Coder v2 236B (with offload)  │
│ Architecture design    │ DeepSeek Coder v2 236B (with offload)  │
│ Batch processing       │ Qwen3 Coder 30B (Q4) - faster          │
│ Security audit         │ Qwen2.5 Coder 32B (Q6)                 │
└──────────────────────────────────────────────────────────────────┘
```

### VRAM Considerations (RTX 5090 - 32GB)

- ✅ **Qwen3 Coder 30B Q4 (17GB):** Fits with 15GB free for context
- ✅ **Qwen2.5 Coder 32B Q4 (18GB):** Fits with 14GB free
- ⚠️ **Qwen2.5 Coder 32B Q6 (25GB):** Fits with 7GB free (limited context)
- ⚠️ **DeepSeek Coder v2 236B Q2 (80GB):** Requires CPU offload (slower but usable for reasoning tasks)

**Recommendation:**
- **Daily coding:** Qwen3-30B-Q4 or Qwen2.5-32B-Q4
- **Multi-agent orchestration:** DeepSeek-236B-Q2 with CPU offload (slower but worth it for reasoning)
- **Critical analysis:** Qwen2.5-32B-Q6

---

## 🎓 Getting Started Guides

### For First-Time Users

1. **Read:** [SETUP_GUIDE.md](SETUP_GUIDE.md) - Complete installation walkthrough
2. **Configure:** Copy `examples/your-models.crush.json` to `.crush.json`
3. **Test:** Run `crush chat "Analyze this project structure"`
4. **Explore:** Try workflows from [WORKFLOWS.md](WORKFLOWS.md)

### For Multi-Agent Workflows

1. **Read:** [MULTI_AGENT_GUIDE.md](MULTI_AGENT_GUIDE.md) - Specialized guide
2. **Configure:** Set up DeepSeek 236B with CPU offloading in LM Studio
3. **Test:** Try the lead agent orchestration examples
4. **Scale:** Build your own agent hierarchies

### For Experienced Users

1. **Configure MCP:** Use `examples/with-mcp-servers.crush.json` as template
2. **Automate:** Set up `scripts/daily-health-check.sh` as cron job
3. **Integrate:** Add `scripts/code-review-pr.sh` to CI/CD pipeline
4. **Customize:** Create project-specific prompts and workflows

### Sample Workflow: Code Review

```bash
# 1. Stage your changes
git add .

# 2. Generate smart commit message
./scripts/smart-commit.sh

# 3. Create a PR
git push && gh pr create

# 4. Run automated review
./scripts/code-review-pr.sh main
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Your Workflow                        │
│              (Scripts, Prompts, Automation)             │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                    Crush CLI                            │
│         (Session Management, Context Handling)          │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Model Context Protocol (MCP)               │
│       (Filesystem, Git, GitHub, Custom Tools)           │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                   LM Studio                             │
│            (OpenAI-compatible API Server)               │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Local LLM (Your Models)                    │
│    Qwen3-30B, Qwen2.5-32B, DeepSeek-236B, etc.        │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│             Hardware Acceleration                       │
│   RTX 5090 (32GB VRAM) + DDR5 RAM (6000MHz+)          │
│   GPU: Fast models  |  CPU+RAM: Large reasoning models │
└─────────────────────────────────────────────────────────┘
```

---

## 🔧 Configuration Tips

### Performance Tuning

**For Maximum Speed:**
```json
{
  "models": [{
    "id": "qwen3-30b-q4",
    "context_window": 8192,
    "default_max_tokens": 2048
  }]
}
```

**For Maximum Quality:**
```json
{
  "models": [{
    "id": "qwen2.5-32b-q6",
    "context_window": 32768,
    "default_max_tokens": 4096
  }]
}
```

**For Multi-Agent Reasoning:**
```json
{
  "models": [{
    "id": "deepseek-coder-v2-236b-q2",
    "context_window": 64000,
    "default_max_tokens": 8000,
    "timeout": 600000
  }]
}
```

### LM Studio Settings (Recommended)

**For Fast Models (Qwen 30B/32B Q4):**
1. **GPU Offloading:** Maximum (all layers to GPU)
2. **Context Length:** 16384
3. **Batch Size:** 2048
4. **Temperature:** 0.7

**For Reasoning Models (DeepSeek 236B Q2):**
1. **GPU Offloading:** ~20-30 layers (rest to CPU)
2. **Context Length:** 8192 (to leave room for processing)
3. **Batch Size:** 512
4. **Temperature:** 0.8
5. **Note:** Expect 10-30 seconds per response (worth it for complex reasoning!)

---

## 🚨 Troubleshooting

### Connection Issues
```bash
# Test LM Studio server
curl http://localhost:1234/v1/models

# Check if model is loaded
# LM Studio → Local Server → Verify model selected
```

### Slow Performance with DeepSeek 236B
This is expected! The model is 80GB and requires CPU offloading:
- Normal: 10-30 seconds per response
- Acceptable for planning/architecture tasks
- Use smaller models for real-time needs

### Out of Memory
- Use smaller model (30B Q4 instead of 32B Q6)
- Reduce context window
- Close other GPU applications
- For DeepSeek 236B: Reduce GPU layers, offload more to CPU

**Full troubleshooting guide:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 🤝 Contributing

This is a community-driven project. Contributions welcome!

---

## 📜 License

MIT License - See [LICENSE](LICENSE) file for details.

---

## 🔗 Quick Links

- **Crush CLI:** https://github.com/charmbracelet/crush
- **LM Studio:** https://lmstudio.ai/
- **Model Context Protocol:** https://modelcontextprotocol.io/
- **Multi-Agent Guide:** [MULTI_AGENT_GUIDE.md](MULTI_AGENT_GUIDE.md)
- **Resources:** [RESOURCES.md](RESOURCES.md)

---

## 🙏 Acknowledgments

- **Charm Bracelet** - For creating Crush CLI
- **LM Studio Team** - For excellent local LLM tooling
- **Open Source Community** - For the amazing models (Qwen, DeepSeek, Code Llama, etc.)
- **Anthropic** - For Model Context Protocol specification

---

**Happy Coding with Local AI! 🚀**

*Last Updated: November 2025*
*Version: 1.0.0*
