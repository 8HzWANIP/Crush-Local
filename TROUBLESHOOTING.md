# Troubleshooting Guide: Crush CLI + LM Studio

## Overview

This guide covers common issues, error messages, and solutions when using Crush CLI with LM Studio for local agentic coding.

---

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Connection Problems](#connection-problems)
3. [Performance Issues](#performance-issues)
4. [Model Loading Errors](#model-loading-errors)
5. [MCP Configuration Issues](#mcp-configuration-issues)
6. [Memory and GPU Problems](#memory-and-gpu-problems)
7. [Configuration Errors](#configuration-errors)
8. [Known Limitations](#known-limitations)

---

## Installation Issues

### Issue 1: Crush CLI Not Found After Installation

**Symptoms:**
```
crush: command not found
```

**Solutions:**

**For NPM Installation:**
```bash
# Check NPM global bin path
npm config get prefix

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$PATH:$(npm config get prefix)/bin"

# Reload shell
source ~/.bashrc  # or source ~/.zshrc
```

**For Homebrew:**
```bash
# Verify installation
brew list charmbracelet/tap/crush

# Re-link if necessary
brew unlink crush && brew link crush
```

**For Windows (Winget):**
```powershell
# Restart terminal as Administrator
# Or add to PATH manually:
$env:PATH += ";C:\Program Files\Crush"
```

### Issue 2: Permission Denied on Linux/Mac

**Symptoms:**
```
EACCES: permission denied
```

**Solutions:**
```bash
# Fix NPM permissions (avoid sudo npm install -g)
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Reinstall
npm install -g @charmland/crush
```

### Issue 3: LM Studio Won't Start

**Symptoms:**
- LM Studio crashes on launch
- "GPU not detected" error

**Solutions:**

**Windows (Nvidia):**
```bash
# Verify CUDA installation
nvidia-smi

# Update Nvidia drivers
# Download from: https://www.nvidia.com/drivers

# Reinstall CUDA Toolkit if needed
# Version 12.8+ recommended for RTX 50 series
```

**Linux:**
```bash
# Check GPU detection
lspci | grep -i nvidia

# Install/update Nvidia drivers
sudo ubuntu-drivers autoinstall

# Install CUDA
sudo apt install nvidia-cuda-toolkit

# Verify installation
nvcc --version
```

**Mac:**
```bash
# M-series Macs use Metal backend (no CUDA needed)
# Verify Metal support:
system_profiler SPDisplaysDataType | grep Metal

# Update to latest macOS for best compatibility
```

---

## Connection Problems

### Issue 4: Crush Can't Connect to LM Studio

**Symptoms:**
```
Error: Failed to connect to http://localhost:1234/v1/
ECONNREFUSED
```

**Diagnostic Steps:**

1. **Verify LM Studio Server is Running:**
   ```bash
   # Check if server is listening
   curl http://localhost:1234/v1/models

   # Expected output: JSON list of models
   ```

2. **Check Correct Port:**
   ```bash
   # Default is 1234, but verify in LM Studio settings
   # LM Studio → Server → Port Number
   ```

3. **Test with Simple Request:**
   ```bash
   curl -X POST http://localhost:1234/v1/chat/completions \
     -H "Content-Type: application/json" \
     -d '{
       "messages": [{"role": "user", "content": "test"}],
       "temperature": 0.7
     }'
   ```

**Solutions:**

**A. Restart LM Studio Server:**
1. Open LM Studio
2. Navigate to "Local Server" tab
3. Stop server (if running)
4. Select model from dropdown
5. Click "Start Server"
6. Wait for "Server running on port 1234" message

**B. Check Firewall Settings:**
```bash
# Windows
# Allow LM Studio through Windows Firewall
# Settings → Privacy & Security → Windows Security → Firewall → Allow an app

# Mac
# System Settings → Network → Firewall → Options
# Add LM Studio to allowed apps

# Linux
sudo ufw allow 1234/tcp
```

**C. Fix Port Conflict:**
```bash
# Check if another process is using port 1234
# Windows
netstat -ano | findstr :1234

# Mac/Linux
lsof -i :1234

# Change LM Studio port if needed (Settings → Server → Port)
# Update .crush.json accordingly
```

### Issue 5: Slow Response or Timeout

**Symptoms:**
- Requests take several minutes
- "Request timeout" errors
- Crush hangs waiting for response

**Solutions:**

1. **Adjust Timeout Settings:**

**.crush.json:**
```json
{
  "providers": {
    "lmstudio": {
      "base_url": "http://localhost:1234/v1/",
      "type": "openai-compat",
      "timeout": 300000,  // 5 minutes (in milliseconds)
      "models": [...]
    }
  }
}
```

2. **Reduce Context Size:**
```json
{
  "models": [{
    "context_window": 8192,  // Reduce from 32768
    "default_max_tokens": 2048  // Reduce from 4096
  }]
}
```

3. **Optimize LM Studio Settings:**
- Reduce batch size (512-1024 instead of 4096)
- Lower context length
- Use quantized model (Q4 instead of Q8)
- Increase GPU layers offloaded

---

## Performance Issues

### Issue 6: Slow Model Inference

**Symptoms:**
- Low tokens/second (<10 t/s)
- High GPU temperature
- Stuttering or freezing

**Diagnostic:**
```bash
# Monitor GPU usage
# Windows/Linux
nvidia-smi -l 1

# Check utilization, temperature, memory
```

**Solutions:**

**A. Optimize GPU Offloading:**
1. Open LM Studio → Settings → GPU
2. Set "GPU Layers" to maximum (offload all to GPU)
3. Enable "Use GPU Acceleration"
4. Increase "GPU Memory Buffer"

**B. Adjust Batch Size:**
- **Current:** Too low → Underutilized GPU
- **Too high:** OOM errors
- **Optimal for RTX 5090:** 1024-2048

**C. Use Better Quantization:**
```
Model Size     | Quantization | Speed | Quality
---------------|--------------|-------|--------
Qwen3-70B      | Q4_K_M      | Fast  | Good
Qwen3-70B      | Q6_K        | Med   | Better
Qwen3-70B      | Q8_0        | Slow  | Best

Recommendation for RTX 5090: Q6_K or Q8_0
```

**D. Check for Thermal Throttling:**
```bash
# Monitor GPU temperature
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader

# If >85°C, improve cooling or reduce batch size
```

**E. Optimize System Resources:**
```bash
# Close unnecessary applications
# Disable background processes

# Windows: Task Manager → Startup → Disable unused apps
# Mac: System Settings → Login Items
# Linux: systemctl list-unit-files --state=enabled
```

### Issue 7: High Memory Usage

**Symptoms:**
- System RAM usage >90%
- Swap file active
- System slowdown

**Solutions:**

1. **Reduce Context Window:**
```json
"context_window": 4096  // Instead of 32768
```

2. **Use Smaller Models:**
```
If using: Qwen3-70B (Q8) → Switch to: Qwen2.5-30B (Q6)
If using: DeepSeek-R1 (Q6) → Switch to: DeepSeek-Coder-20B (Q6)
```

3. **Close Unused Sessions:**
```bash
# List Crush sessions
crush session list

# Delete old sessions
crush session delete <session-name>
```

4. **Increase Swap/Page File:**
```bash
# Linux
sudo fallocate -l 32G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Windows
# Settings → System → About → Advanced system settings
# Performance Settings → Advanced → Virtual memory → Change
```

---

## Model Loading Errors

### Issue 8: Model Not Found

**Symptoms:**
```
Error: Model 'qwen/qwen3-70b' not found
```

**Solutions:**

1. **Check Model ID:**
```bash
# List available models in LM Studio
curl http://localhost:1234/v1/models | jq '.data[].id'

# Update .crush.json with exact model ID
```

2. **Download Model:**
- Open LM Studio
- Navigate to "Discover" tab
- Search for model (e.g., "Qwen3 Coder 30B")
- Click "Download"
- Wait for download to complete

3. **Verify Model is Loaded:**
- LM Studio → "My Models" tab
- Model should appear with green checkmark
- Click "Load" if not loaded

### Issue 9: Out of Memory (OOM) Error

**Symptoms:**
```
Error: Failed to allocate memory for model
CUDA out of memory
```

**Solutions:**

**A. Use Smaller Quantization:**
```
Current: Q8 (highest quality, most memory)
Try: Q6 or Q4 (lower quality, less memory)

Model Size Estimate:
Q8: ~8 bytes per parameter
Q6: ~6 bytes per parameter
Q4: ~4 bytes per parameter

Example: 30B model
Q8: ~240GB (won't fit in 32GB VRAM)
Q6: ~18GB (fits comfortably)
Q4: ~12GB (plenty of room)
```

**B. Reduce GPU Layers:**
- If model still too large, offload some layers to CPU
- LM Studio → Settings → GPU Offloading → Adjust slider
- Trade-off: Slower inference, but model will run

**C. Close Other GPU Applications:**
```bash
# Check what's using GPU
nvidia-smi

# Close browsers, games, video editors using GPU
```

### Issue 10: Model Loads But Produces Gibberish

**Symptoms:**
- Model responds with random characters
- Output doesn't make sense
- Model repeats endlessly

**Solutions:**

1. **Check Model Download Integrity:**
```bash
# Re-download model in LM Studio
# Delete → Re-download from "Discover" tab
```

2. **Adjust Temperature:**
```json
{
  "models": [{
    "temperature": 0.7,  // Not too high (>1.5) or low (<0.1)
    "top_p": 0.9,
    "top_k": 40
  }]
}
```

3. **Verify Model Compatibility:**
- Some models require specific prompt formats
- Check model card for requirements
- Use correct chat template

---

## MCP Configuration Issues

### Issue 11: MCP Server Won't Start

**Symptoms:**
```
Error: Failed to start MCP server 'filesystem'
Command not found: npx
```

**Solutions:**

1. **Install Node.js (for stdio MCP servers):**
```bash
# Install Node.js 18+
# Download from: https://nodejs.org/

# Verify installation
node --version
npm --version
npx --version
```

2. **Fix MCP Server Path:**
```json
{
  "mcp_servers": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",  // or full path: /usr/local/bin/npx
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/workspace"]
    }
  }
}
```

3. **Check Environment Variables:**
```json
{
  "mcp_servers": {
    "custom": {
      "type": "stdio",
      "command": "python3",
      "args": ["/full/path/to/script.py"],
      "env": {
        "PYTHONPATH": "/path/to/modules",
        "API_KEY": "$(echo $MY_API_KEY)"
      }
    }
  }
}
```

### Issue 12: MCP Server Authentication Failed

**Symptoms:**
```
Error: HTTP 401 Unauthorized
MCP server rejected connection
```

**Solutions:**

1. **Verify API Tokens:**
```bash
# Check environment variable is set
echo $GITHUB_TOKEN

# If not set:
export GITHUB_TOKEN="ghp_your_token_here"

# Add to shell config for persistence
echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.bashrc
```

2. **Use Command Substitution:**
```json
{
  "mcp_servers": {
    "github": {
      "type": "http",
      "url": "https://api.github.com/mcp",
      "headers": {
        "Authorization": "$(echo Bearer $GITHUB_TOKEN)"
      }
    }
  }
}
```

3. **Test MCP Server Manually:**
```bash
# Test HTTP MCP server
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/mcp/

# Test stdio MCP server
npx -y @modelcontextprotocol/server-filesystem /workspace
```

---

## Configuration Errors

### Issue 13: Invalid .crush.json

**Symptoms:**
```
Error: Failed to parse configuration
Unexpected token in JSON at position 123
```

**Solutions:**

1. **Validate JSON:**
```bash
# Use jq to validate
jq '.' .crush.json

# Or use online validator: https://jsonlint.com/
```

2. **Common JSON Errors:**
```json
// ❌ WRONG: Trailing comma
{
  "providers": {
    "lmstudio": {},  // <- Remove trailing comma
  }
}

// ✅ CORRECT
{
  "providers": {
    "lmstudio": {}
  }
}

// ❌ WRONG: Comments not allowed in JSON
{
  // This is a comment  <- Remove comments
  "providers": {}
}

// ✅ CORRECT
{
  "providers": {}
}
```

3. **Use Schema Validation:**
```json
{
  "$schema": "https://charm.land/crush.json",
  // Rest of config...
}
```

### Issue 14: Config Not Being Loaded

**Symptoms:**
- Changes to .crush.json don't take effect
- Crush uses default configuration

**Solutions:**

1. **Check Config Location:**
```bash
# Crush looks in this order:
# 1. ./.crush.json (current directory)
# 2. ./crush.json
# 3. ~/.config/crush/crush.json

# Check which config is being used
crush config show
```

2. **Force Config Reload:**
```bash
# Restart Crush session
crush session delete <session-name>
crush session create <session-name>
```

3. **Use Explicit Config Path:**
```bash
crush chat --config /path/to/custom/.crush.json "Your prompt"
```

---

## Known Limitations

### Limitation 1: Context Window Constraints

**Issue:**
Large files (>10k lines) or multiple files exceed context window.

**Workarounds:**

1. **Split Analysis:**
```bash
# Analyze files in smaller chunks
crush chat "Analyze lines 1-1000 of large-file.js"
crush chat "Analyze lines 1001-2000 of large-file.js"
```

2. **Use Summarization:**
```bash
crush chat "Summarize the main functions in this large file,
then I'll ask detailed questions about specific parts"
```

3. **Choose Longer Context Models:**
```
Model              | Max Context
-------------------|------------
Qwen3-Coder-30B    | 32K tokens
DeepSeek-R1        | 64K tokens
Claude (via API)   | 200K tokens
```

### Limitation 2: No Real-time Code Execution

**Issue:**
Crush can't directly execute code or run tests.

**Workarounds:**

1. **Generate Test Scripts:**
```bash
crush chat "Generate a bash script to run all tests and capture output"
# Then manually run the generated script
```

2. **Integration with CI/CD:**
- Use Crush to analyze code
- Use CI/CD to execute tests
- Feed results back to Crush for interpretation

### Limitation 3: Large Repository Scanning

**Issue:**
Full repository scans take a long time or fail.

**Workarounds:**

1. **Targeted Scanning:**
```bash
crush chat "Analyze only files in src/auth/ directory"
```

2. **Use MCP Filesystem Server:**
- Configure MCP server with project root
- Allows Crush to query filesystem efficiently

3. **Pre-filter Files:**
```bash
# Create file list
find src/ -name "*.js" -type f > files-to-analyze.txt

# Analyze in batches
while read file; do
  crush chat "Analyze $file for code quality"
done < files-to-analyze.txt
```

### Limitation 4: No Multi-model Simultaneous Use

**Issue:**
Can't use multiple models in single session (without manual switching).

**Workarounds:**

1. **Multiple Sessions:**
```bash
# Session 1: Code review with large model
crush session create review --provider lmstudio-70b

# Session 2: Quick queries with small model
crush session create quick --provider lmstudio-7b
```

2. **Model Switching:**
```bash
crush chat "Switch to model: qwen3-70b"
# Then ask your question
```

---

## Diagnostic Commands

### System Information

```bash
# Crush version
crush --version

# GPU information
nvidia-smi

# System resources
# Linux
free -h
df -h

# Windows
systeminfo | findstr /C:"Total Physical Memory"
wmic logicaldisk get size,freespace,caption

# Mac
sysctl hw.memsize
df -h
```

### Connection Testing

```bash
# Test LM Studio API
curl http://localhost:1234/v1/models

# Test with verbose output
curl -v http://localhost:1234/v1/models

# Test chat completion
curl -X POST http://localhost:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "test"}]
  }' | jq '.'
```

### Performance Monitoring

```bash
# GPU monitoring (refresh every second)
watch -n 1 nvidia-smi

# Detailed GPU stats
nvidia-smi dmon -s pucvmet

# Process monitoring
# Linux
htop
iotop

# Windows
# Task Manager → Performance → GPU

# Mac
sudo powermetrics --samplers gpu_power
```

---

## Getting Help

### Community Resources

- **Crush GitHub:** https://github.com/charmbracelet/crush
  - Check Issues tab for similar problems
  - Search closed issues for solutions

- **LM Studio Discord:** https://discord.gg/lmstudio
  - Active community support
  - LM Studio staff present

- **Crush Discussions:** https://github.com/charmbracelet/crush/discussions
  - Ask questions
  - Share configurations

### Reporting Bugs

When reporting issues, include:

1. **Environment Information:**
```bash
crush --version
node --version
npm --version
uname -a  # or 'systeminfo' on Windows
nvidia-smi  # if GPU-related
```

2. **Configuration:** (sanitize sensitive data)
```bash
cat .crush.json
```

3. **Error Messages:** (full stack trace)

4. **Steps to Reproduce**

5. **Expected vs. Actual Behavior**

### Log Files

```bash
# Crush logs location
# Linux/Mac
~/.local/share/crush/logs/

# Windows
%LOCALAPPDATA%\crush\logs\

# View latest log
tail -f ~/.local/share/crush/logs/crush.log

# Search for errors
grep ERROR ~/.local/share/crush/logs/crush.log
```

---

## Quick Reference: Common Fixes

| Problem | Quick Fix |
|---------|-----------|
| Connection refused | Restart LM Studio server |
| Command not found | Add to PATH or use full path |
| Slow responses | Reduce context window, use smaller model |
| OOM error | Use lower quantization (Q4 instead of Q8) |
| Invalid JSON | Validate with `jq '.' .crush.json` |
| MCP server fails | Check Node.js installed, verify paths |
| Gibberish output | Re-download model, check temperature |
| Timeout | Increase timeout in .crush.json |

---

**Last Updated:** November 2025
**For issues not covered here:** https://github.com/charmbracelet/crush/issues
