# Resources and Community Links

## Official Documentation

### Crush CLI
- **GitHub Repository:** https://github.com/charmbracelet/crush
- **Official Website:** https://charm.sh/
- **Documentation:** https://github.com/charmbracelet/crush/blob/main/README.md
- **Discussions:** https://github.com/charmbracelet/crush/discussions
- **Issues:** https://github.com/charmbracelet/crush/issues

### LM Studio
- **Official Website:** https://lmstudio.ai/
- **Documentation:** https://lmstudio.ai/docs
- **Blog:** https://lmstudio.ai/blog
- **Discord Community:** https://discord.gg/lmstudio
- **Developer Docs:** https://lmstudio.ai/docs/developer
- **API Reference:** https://lmstudio.ai/docs/api

### Model Context Protocol (MCP)
- **Official Website:** https://modelcontextprotocol.io/
- **Specification:** https://spec.modelcontextprotocol.io/
- **GitHub:** https://github.com/modelcontextprotocol
- **Community Servers:** https://github.com/modelcontextprotocol/servers
- **SDK - TypeScript:** https://github.com/modelcontextprotocol/typescript-sdk
- **SDK - Python:** https://github.com/modelcontextprotocol/python-sdk

---

## Open Source LLM Models

### Code-Specialized Models

#### Qwen Coder Series (Recommended ⭐)
- **Homepage:** https://github.com/QwenLM/Qwen-Coder
- **Models:**
  - Qwen3-Coder-70B
  - Qwen2.5-Coder-30B
  - Qwen2.5-Coder-7B
- **Download:** Available on Hugging Face and through LM Studio
- **License:** Apache 2.0
- **Best for:** Multi-language code analysis, agentic tasks, long context

#### DeepSeek Coder
- **Homepage:** https://github.com/deepseek-ai/DeepSeek-Coder
- **Models:**
  - DeepSeek-R1 (Reasoning)
  - DeepSeek-Coder-V3-20B
  - DeepSeek-Coder-V2-236B (requires multiple GPUs)
- **Download:** https://huggingface.co/deepseek-ai
- **License:** DeepSeek License (check terms)
- **Best for:** Planning, reasoning, complex code analysis

#### Code Llama (Meta)
- **Homepage:** https://github.com/facebookresearch/codellama
- **Models:**
  - Code Llama 70B
  - Code Llama 34B
  - Code Llama 13B
  - Code Llama 7B
- **Download:** https://huggingface.co/codellama
- **License:** Llama 2 Community License
- **Best for:** General coding tasks, broad language support

#### StarCoder2
- **Homepage:** https://github.com/bigcode-project/starcoder2
- **Models:**
  - StarCoder2-15B
  - StarCoder2-7B
  - StarCoder2-3B
- **Download:** https://huggingface.co/bigcode
- **License:** OpenRAIL (permissive)
- **Best for:** Fast inference, real-time assistance

#### Microsoft Phi-3
- **Homepage:** https://azure.microsoft.com/en-us/products/phi-3
- **Models:**
  - Phi-3-Mini (3.8B)
  - Phi-3-Medium (14B)
- **Download:** https://huggingface.co/microsoft
- **License:** MIT
- **Best for:** Efficient local deployment, low-resource environments

### General-Purpose Models (Good for Code)

#### Llama 3.1/3.2 (Meta)
- **Homepage:** https://llama.meta.com/
- **Models:** 8B, 70B, 405B
- **Download:** https://huggingface.co/meta-llama
- **License:** Llama 3 Community License

#### Mistral/Mixtral
- **Homepage:** https://mistral.ai/
- **Models:** Mistral-7B, Mixtral-8x7B, Mixtral-8x22B
- **Download:** https://huggingface.co/mistralai
- **License:** Apache 2.0

#### Gemma (Google)
- **Homepage:** https://ai.google.dev/gemma
- **Models:** Gemma-2B, Gemma-7B, Gemma-27B
- **Download:** https://huggingface.co/google
- **License:** Gemma Terms of Use

---

## Model Hosting & Quantization Tools

### Ollama
- **Website:** https://ollama.com/
- **GitHub:** https://github.com/ollama/ollama
- **Description:** Easy local LLM deployment
- **Use Case:** Alternative to LM Studio, CLI-focused

### llama.cpp
- **GitHub:** https://github.com/ggerganov/llama.cpp
- **Description:** C++ inference engine (powers LM Studio)
- **Use Case:** Building custom inference solutions

### vLLM
- **GitHub:** https://github.com/vllm-project/vllm
- **Description:** High-throughput inference engine
- **Use Case:** Production-scale local deployment

### Text Generation WebUI (oobabooga)
- **GitHub:** https://github.com/oobabooga/text-generation-webui
- **Description:** Web UI for running LLMs
- **Use Case:** Alternative interface to LM Studio

---

## MCP Server Implementations

### Official MCP Servers
- **Filesystem:** https://github.com/modelcontextprotocol/servers/tree/main/filesystem
- **Git:** https://github.com/modelcontextprotocol/servers/tree/main/git
- **GitHub:** https://github.com/modelcontextprotocol/servers/tree/main/github
- **PostgreSQL:** https://github.com/modelcontextprotocol/servers/tree/main/postgres
- **Puppeteer:** https://github.com/modelcontextprotocol/servers/tree/main/puppeteer

### Community MCP Servers
- **MCP Hub:** https://github.com/topics/model-context-protocol
- **Awesome MCP:** https://github.com/punkpeye/awesome-mcp

### Build Your Own
- **TypeScript Template:** https://github.com/modelcontextprotocol/typescript-sdk/tree/main/examples
- **Python Template:** https://github.com/modelcontextprotocol/python-sdk/tree/main/examples

---

## Related Projects & Tools

### Code Analysis Tools

#### Static Analysis
- **SonarQube:** https://www.sonarqube.org/ (multi-language)
- **ESLint:** https://eslint.org/ (JavaScript/TypeScript)
- **Pylint:** https://pylint.org/ (Python)
- **Semgrep:** https://semgrep.dev/ (multi-language, pattern-based)

#### Security Scanning
- **Snyk:** https://snyk.io/ (dependency vulnerabilities)
- **Bandit:** https://github.com/PyCQA/bandit (Python security)
- **GitGuardian:** https://www.gitguardian.com/ (secret detection)
- **Trivy:** https://github.com/aquasecurity/trivy (container/code scanning)

#### Complexity Analysis
- **CodeScene:** https://codescene.com/
- **SonarLint:** https://www.sonarlint.org/
- **Radon:** https://radon.readthedocs.io/ (Python complexity)

### AI Coding Assistants (Comparison)

#### Cloud-Based
- **GitHub Copilot:** https://github.com/features/copilot
- **Cursor:** https://cursor.sh/
- **Tabnine:** https://www.tabnine.com/
- **Amazon CodeWhisperer:** https://aws.amazon.com/codewhisperer/

#### Local/Hybrid
- **Crush CLI:** https://github.com/charmbracelet/crush ⭐ (this project)
- **Continue:** https://continue.dev/ (VS Code extension, supports local)
- **Codeium:** https://codeium.com/ (free, local option)
- **Aider:** https://github.com/paul-gauthier/aider (CLI, local models)

---

## Learning Resources

### Tutorials & Guides

#### Crush CLI
- **Getting Started:** https://github.com/charmbracelet/crush/blob/main/README.md
- **Community Guides:** https://github.com/charmbracelet/crush/discussions/categories/guides

#### LM Studio
- **Quick Start:** https://lmstudio.ai/docs/welcome
- **Model Selection:** https://lmstudio.ai/docs/basics/model-selection
- **API Usage:** https://lmstudio.ai/docs/app/api

#### MCP Development
- **Introduction:** https://modelcontextprotocol.io/introduction
- **Building Servers:** https://modelcontextprotocol.io/quickstart/server
- **Building Clients:** https://modelcontextprotocol.io/quickstart/client

### Blog Posts & Articles

#### Performance Optimization
- **LM Studio Performance Guide:** https://lmstudio.ai/blog/performance-optimization
- **Quantization Explained:** https://huggingface.co/docs/transformers/quantization

#### Prompt Engineering for Code
- **OpenAI Prompt Engineering:** https://platform.openai.com/docs/guides/prompt-engineering
- **Anthropic Prompt Library:** https://docs.anthropic.com/claude/prompt-library

#### Local LLM Best Practices
- **Running LLMs Locally (n8n Blog):** https://blog.n8n.io/local-llm/
- **Local AI Setup Guide:** https://www.gpu-mart.com/blog/run-llms-with-lm-studio

---

## Community Forums & Support

### Discussion Platforms
- **Reddit:**
  - r/LocalLLaMA: https://reddit.com/r/LocalLLaMA
  - r/MachineLearning: https://reddit.com/r/MachineLearning
  - r/artificial: https://reddit.com/r/artificial

- **Discord Servers:**
  - LM Studio: https://discord.gg/lmstudio
  - Ollama: https://discord.gg/ollama
  - Hugging Face: https://huggingface.co/join/discord

- **Stack Overflow:**
  - [llm] tag: https://stackoverflow.com/questions/tagged/llm
  - [local-llm] tag: https://stackoverflow.com/questions/tagged/local-llm

### YouTube Channels
- **MattVidPro AI:** https://www.youtube.com/@MattVidPro (LM Studio tutorials)
- **Prompt Engineering:** https://www.youtube.com/@engineerprompt
- **AI Explained:** https://www.youtube.com/@aiexplained-official

---

## Hardware & Optimization

### GPU Optimization
- **NVIDIA CUDA Toolkit:** https://developer.nvidia.com/cuda-toolkit
- **CUDA Best Practices:** https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/
- **TensorRT-LLM:** https://github.com/NVIDIA/TensorRT-LLM

### Performance Monitoring
- **nvtop:** https://github.com/Syllo/nvtop (GPU monitoring)
- **htop:** https://htop.dev/ (system monitoring)
- **jtop:** https://github.com/rbonghi/jetson_stats (Jetson devices)

### Benchmarking
- **llama-bench:** Built into llama.cpp
- **vLLM Benchmarks:** https://github.com/vllm-project/vllm/tree/main/benchmarks
- **MLPerf Inference:** https://mlcommons.org/benchmarks/inference/

---

## Example Projects & Templates

### GitHub Repositories

#### Crush CLI Examples
- **Search:** https://github.com/search?q=crush+cli+examples
- **Templates:** https://github.com/topics/crush-cli

#### LM Studio Integration Examples
- **FastAPI + LM Studio:** https://github.com/topics/lmstudio-api
- **Python Clients:** https://github.com/topics/lmstudio-python

#### MCP Server Examples
- **Custom Servers:** https://github.com/topics/mcp-server
- **Integration Examples:** https://github.com/modelcontextprotocol/servers

### Project Starter Templates
- **AI Coding Agent Template:** https://github.com/topics/ai-coding-agent
- **Local LLM API Template:** https://github.com/topics/local-llm-api

---

## Conferences & Events

### AI/ML Conferences
- **NeurIPS:** https://neurips.cc/
- **ICML:** https://icml.cc/
- **ACL:** https://aclweb.org/

### Developer Conferences
- **GitHub Universe:** https://githubuniverse.com/
- **AWS re:Invent:** https://reinvent.awsevents.com/
- **Google I/O:** https://io.google/

---

## Research Papers

### Foundational Papers
- **Attention Is All You Need (Transformers):** https://arxiv.org/abs/1706.03762
- **GPT-3:** https://arxiv.org/abs/2005.14165
- **LLaMA:** https://arxiv.org/abs/2302.13971

### Code-Specific
- **Code Llama:** https://arxiv.org/abs/2308.12950
- **StarCoder:** https://arxiv.org/abs/2305.06161
- **CodeGen:** https://arxiv.org/abs/2203.13474

### Optimization
- **GPTQ:** https://arxiv.org/abs/2210.17323 (quantization)
- **Flash Attention:** https://arxiv.org/abs/2205.14135

---

## Datasets for Training/Fine-tuning

### Code Datasets
- **The Stack:** https://huggingface.co/datasets/bigcode/the-stack
- **CodeParrot:** https://huggingface.co/datasets/codeparrot/github-code
- **CodeSearchNet:** https://github.com/github/CodeSearchNet

### Instruction Datasets
- **Alpaca:** https://github.com/tatsu-lab/stanford_alpaca
- **ShareGPT:** https://huggingface.co/datasets/anon8231489123/ShareGPT_Vicuna_unfiltered

---

## Newsletters & Blogs

- **The Batch (DeepLearning.AI):** https://www.deeplearning.ai/the-batch/
- **Import AI:** https://jack-clark.net/
- **TLDR AI:** https://tldr.tech/ai
- **Ben's Bites:** https://www.bensbites.co/
- **Hugging Face Blog:** https://huggingface.co/blog

---

## Commercial Alternatives (for Comparison)

- **OpenAI API:** https://platform.openai.com/
- **Anthropic Claude:** https://www.anthropic.com/api
- **Google Gemini API:** https://ai.google.dev/
- **Cohere:** https://cohere.com/
- **Together AI:** https://www.together.ai/

---

## Contributing

Found a great resource? Submit a PR to add it!

**Repository:** https://github.com/[your-username]/Crush-Local

---

**Last Updated:** November 2025
**Maintained by:** Community Contributors
