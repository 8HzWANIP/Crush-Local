# Windows Setup Guide: LM Studio Tools for Crush CLI

## ✅ Yes, It Works on Windows!

The LM Studio MCP server is fully compatible with Windows. This guide covers Windows-specific setup.

---

## Prerequisites

- ✅ **Windows 10/11** (PowerShell 5.1+ or PowerShell 7+)
- ✅ **Crush CLI** installed via Winget or Scoop
- ✅ **LM Studio** for Windows
- ✅ **Node.js 18+** for Windows

---

## Quick Start (Windows)

### Step 1: Install Node.js

Download and install from: https://nodejs.org/

```powershell
# Verify installation
node --version  # Should be v18.0.0 or higher
npm --version
```

### Step 2: Install Dependencies

```powershell
cd custom-integrations\lm-studio-tools\option1-mcp-server

# Install npm packages
npm install
```

### Step 3: Run Setup Script (PowerShell)

```powershell
# Run PowerShell setup script
.\setup.ps1
```

**Note:** If you get "execution policy" error:

```powershell
# Allow script execution (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then run setup again
.\setup.ps1
```

### Step 4: Configure Crush (Windows Paths)

Edit `.crush.json` in your project root or `%USERPROFILE%\.config\crush\crush.json`

**Important:** Use **full Windows paths** with escaped backslashes or forward slashes:

#### Option A: Backslashes (Escaped)

```json
{
  "$schema": "https://charm.land/crush.json",
  "mcp": {
    "lm-studio-tools": {
      "type": "stdio",
      "command": "node",
      "args": ["C:\\Users\\YourName\\Projects\\Crush-Local\\custom-integrations\\lm-studio-tools\\option1-mcp-server\\lm-studio-mcp-server.js"],
      "env": {
        "LM_STUDIO_BASE_URL": "http://localhost:1234/v1"
      }
    }
  }
}
```

#### Option B: Forward Slashes (Easier)

```json
{
  "$schema": "https://charm.land/crush.json",
  "mcp": {
    "lm-studio-tools": {
      "type": "stdio",
      "command": "node",
      "args": ["C:/Users/YourName/Projects/Crush-Local/custom-integrations/lm-studio-tools/option1-mcp-server/lm-studio-mcp-server.js"],
      "env": {
        "LM_STUDIO_BASE_URL": "http://localhost:1234/v1"
      }
    }
  }
}
```

**Tip:** Get your current directory in PowerShell:

```powershell
# Get full path
(Get-Location).Path

# Copy full path to lm-studio-mcp-server.js
Join-Path (Get-Location).Path "lm-studio-mcp-server.js"
```

### Step 5: Test

```powershell
# Start Crush
crush

# List tools
crush tools

# Should show:
# - mcp_lm-studio-tools_analyze
# - mcp_lm-studio-tools_generate
# - etc.
```

---

## Windows-Specific Considerations

### 1. **PowerShell vs Command Prompt**

✅ **Use PowerShell** (recommended)
❌ **Don't use Command Prompt** (cmd.exe) - limited functionality

```powershell
# Open PowerShell
# Windows + X → "Windows PowerShell" or "Terminal"
```

### 2. **Path Separators**

Windows accepts both:
- ✅ `C:\path\to\file` (native Windows)
- ✅ `C:/path/to/file` (Unix-style, works in JSON)

In `.crush.json`, use **forward slashes** or **escaped backslashes**:

```json
// ✅ CORRECT
"args": ["C:/Users/Me/project/server.js"]
"args": ["C:\\Users\\Me\\project\\server.js"]

// ❌ WRONG (will fail)
"args": ["C:\Users\Me\project\server.js"]  // Unescaped backslashes
```

### 3. **Environment Variables**

Windows uses different environment variable syntax:

**PowerShell:**
```powershell
$env:LM_STUDIO_BASE_URL = "http://localhost:1234/v1"
$env:LM_STUDIO_ENABLE_CACHE = "true"
```

**Command Prompt (if you must use it):**
```cmd
set LM_STUDIO_BASE_URL=http://localhost:1234/v1
```

**In .crush.json (same as Linux):**
```json
"env": {
  "LM_STUDIO_BASE_URL": "http://localhost:1234/v1"
}
```

### 4. **Firewall**

If you get connection errors, ensure Windows Firewall allows Node.js and LM Studio:

```powershell
# Run as Administrator
New-NetFirewallRule -DisplayName "Node.js" -Direction Inbound -Program "C:\Program Files\nodejs\node.exe" -Action Allow
New-NetFirewallRule -DisplayName "LM Studio" -Direction Inbound -Program "C:\Users\YourName\AppData\Local\LMStudio\LM Studio.exe" -Action Allow
```

Or manually:
1. **Windows Security** → **Firewall & network protection**
2. **Allow an app through firewall**
3. Add Node.js and LM Studio

### 5. **Line Endings**

If you edit files on Windows, ensure they use LF (not CRLF):

**In VS Code:**
1. Open file
2. Bottom-right corner: "CRLF" → Click it
3. Select "LF"

**In Git:**
```bash
# Configure Git to handle line endings
git config --global core.autocrlf false
```

---

## Troubleshooting (Windows-Specific)

### Issue 1: "Cannot be loaded because running scripts is disabled"

**Error:**
```
.\setup.ps1 : File cannot be loaded because running scripts is disabled on this system.
```

**Fix:**
```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue 2: "node is not recognized"

**Error:**
```
'node' is not recognized as an internal or external command
```

**Fix:**
1. Reinstall Node.js from https://nodejs.org/
2. During installation, check "Add to PATH"
3. Restart PowerShell
4. Verify: `node --version`

### Issue 3: "Path not found" in Crush

**Error:**
```
Error: Cannot find module 'C:\Users\...\lm-studio-mcp-server.js'
```

**Fix:**
Use **absolute path** in `.crush.json`:

```powershell
# Get absolute path
(Get-Item lm-studio-mcp-server.js).FullName

# Example output: C:\Users\Me\Crush-Local\custom-integrations\...
# Copy this path to .crush.json
```

### Issue 4: LM Studio Connection Refused

**Error:**
```
ECONNREFUSED http://localhost:1234/v1/models
```

**Fix:**
1. Open **LM Studio**
2. Load a model
3. **Local Server** tab → **Start Server**
4. Verify: Open browser to `http://localhost:1234`

**Check with PowerShell:**
```powershell
Invoke-RestMethod -Uri "http://localhost:1234/v1/models"
```

### Issue 5: Slow Performance on Windows

**If DeepSeek 236B is slow (>60 seconds):**

Windows CPU scheduling can affect performance. Try:

```powershell
# Run as Administrator
# Set Node.js process priority to High
Get-Process -Name node | ForEach-Object { $_.PriorityClass = "High" }
```

Or in LM Studio settings:
- Reduce GPU layers (offload more to CPU)
- Close background apps
- Use Task Manager to monitor CPU/GPU usage

---

## Configuration Examples (Windows)

### Example 1: Basic Setup

**Location:** `C:\Users\YourName\.config\crush\crush.json`

```json
{
  "$schema": "https://charm.land/crush.json",
  "providers": {
    "anthropic": {
      "api_key": "$ANTHROPIC_API_KEY",
      "models": [
        {
          "id": "claude-sonnet-4-20250514",
          "name": "Claude Sonnet 4"
        }
      ]
    }
  },
  "mcp": {
    "lm-studio-tools": {
      "type": "stdio",
      "command": "node",
      "args": ["C:/Users/YourName/Projects/Crush-Local/custom-integrations/lm-studio-tools/option1-mcp-server/lm-studio-mcp-server.js"],
      "timeout": 120,
      "env": {
        "LM_STUDIO_BASE_URL": "http://localhost:1234/v1",
        "LM_STUDIO_TIMEOUT": "60000",
        "LM_STUDIO_ENABLE_CACHE": "true"
      }
    }
  }
}
```

### Example 2: Multiple LM Studio Instances (Windows)

Run 3 LM Studio instances:
- **Port 1234:** Qwen3-30B (fast)
- **Port 1235:** Qwen2.5-32B (quality)
- **Port 1236:** DeepSeek-236B (reasoning)

**Note:** LM Studio on Windows can only run one instance at a time. For multiple ports, you need:
- **Option A:** Multiple Windows users (each running LM Studio)
- **Option B:** Docker containers (advanced)
- **Option C:** Switch models in same instance (simpler)

**Recommended for Windows:** Switch models as needed:

```json
{
  "mcp": {
    "lm-studio-tools": {
      "type": "stdio",
      "command": "node",
      "args": ["C:/Users/YourName/Projects/Crush-Local/custom-integrations/lm-studio-tools/option1-mcp-server/lm-studio-mcp-server.js"],
      "env": {
        "LM_STUDIO_BASE_URL": "http://localhost:1234/v1"
      }
    }
  }
}
```

Then manually switch models in LM Studio as needed.

---

## WSL (Windows Subsystem for Linux) Option

If you prefer Linux environment:

### Step 1: Enable WSL

```powershell
# Run as Administrator
wsl --install
# Restart computer
```

### Step 2: Install Ubuntu

```powershell
wsl --install -d Ubuntu
```

### Step 3: Follow Linux Instructions

Inside WSL, follow the regular Linux setup:

```bash
cd /mnt/c/Users/YourName/Projects/Crush-Local/custom-integrations/lm-studio-tools/option1-mcp-server
./setup.sh
```

**Note:** LM Studio running on Windows can be accessed from WSL at `http://localhost:1234`

---

## Testing on Windows

### Test 1: Verify Node.js and MCP Server

```powershell
# Navigate to server directory
cd C:\Users\YourName\Projects\Crush-Local\custom-integrations\lm-studio-tools\option1-mcp-server

# Run server directly (for testing)
node lm-studio-mcp-server.js

# Should output:
# [LM Studio MCP] Starting server...
# [LM Studio MCP] Connected! Found 1 model(s):
#   - qwen3-30b-q4
# [LM Studio MCP] Server ready!

# Press Ctrl+C to stop
```

### Test 2: Verify LM Studio API

```powershell
Invoke-RestMethod -Uri "http://localhost:1234/v1/models" | ConvertTo-Json
```

### Test 3: Verify Crush Integration

```powershell
# List Crush tools
crush tools | Select-String "lm-studio"

# Should show:
# mcp_lm-studio-tools_analyze
# mcp_lm-studio-tools_generate
# etc.
```

### Test 4: First Tool Call

```powershell
crush chat "Use mcp_lm-studio-tools_analyze to check this code:

def hello():
    return 'world'
"
```

---

## Performance Tips (Windows)

### 1. GPU Optimization

**For RTX 5090 on Windows:**

1. **Update NVIDIA Drivers:**
   - Download latest from: https://www.nvidia.com/Download/index.aspx
   - Use "Game Ready Driver" or "Studio Driver"

2. **CUDA Toolkit:**
   - Download from: https://developer.nvidia.com/cuda-downloads
   - LM Studio uses this for GPU acceleration

3. **Windows Power Plan:**
   ```powershell
   # Set to High Performance
   powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
   ```

### 2. RAM Optimization

**For DDR5 6000MHz:**

1. **Enable XMP in BIOS** (for advertised speed)
2. **Close background apps** before running large models
3. **Monitor in Task Manager:** Ctrl+Shift+Esc → Performance → Memory

### 3. Storage Optimization

**Models are large (80GB for DeepSeek):**

1. **Use SSD** (NVMe preferred) for model storage
2. **LM Studio models location:**
   - Default: `C:\Users\YourName\.cache\lm-studio\models`
   - Change in LM Studio settings if needed

---

## Common Workflows (Windows PowerShell)

### Workflow 1: Daily Code Review

```powershell
# daily-review.ps1
$changedFiles = git diff --name-only HEAD~1 HEAD

$prompt = @"
Review files changed in last commit using local models:

Files: $changedFiles

Use mcp_lm-studio-tools_analyze for each file.
Provide summary of issues found.
"@

crush chat $prompt
```

### Workflow 2: Batch Analysis

```powershell
# analyze-all.ps1
$pythonFiles = Get-ChildItem -Path src\ -Filter *.py -Recurse

foreach ($file in $pythonFiles) {
    Write-Host "Analyzing: $($file.FullName)"

    $code = Get-Content $file.FullName -Raw

    $prompt = @"
Use mcp_lm-studio-tools_analyze to check this Python file:

File: $($file.Name)
$code
"@

    crush chat $prompt | Out-File -FilePath "reports\$($file.BaseName).txt"
}
```

---

## Summary

### ✅ What Works on Windows

- ✅ Node.js MCP server (fully compatible)
- ✅ LM Studio (native Windows app)
- ✅ Crush CLI (via Winget/Scoop)
- ✅ All 5 tools (analyze, generate, refactor, plan, custom)
- ✅ Response caching
- ✅ Multi-model support
- ✅ GPU acceleration (CUDA)

### ⚠️ Windows-Specific Notes

- ⚠️ Use **PowerShell** (not cmd.exe)
- ⚠️ Use **absolute paths** in `.crush.json`
- ⚠️ Use **forward slashes** or **escaped backslashes** in JSON
- ⚠️ May need to allow scripts: `Set-ExecutionPolicy RemoteSigned`
- ⚠️ Firewall may block Node.js (allow it)

### 🚀 Performance on Windows

- **Qwen3-30B:** ~3-6 seconds (fast)
- **Qwen2.5-32B:** ~4-10 seconds (quality)
- **DeepSeek-236B:** ~15-40 seconds (reasoning, CPU offload)

**Note:** Windows may be slightly slower than Linux for CPU offloading, but GPU performance is identical.

---

## Getting Help

**Windows-specific issues:**
1. Check Windows Firewall
2. Verify Node.js in PATH
3. Use PowerShell (not cmd.exe)
4. Check LM Studio is running
5. Use absolute paths in configuration

**General issues:**
See main [TROUBLESHOOTING.md](../../TROUBLESHOOTING.md)

---

**Windows setup complete! You're ready to use local LM Studio models as tools in Crush CLI!** 🎉
