# Quick Start: LM Studio Tools in Crush CLI

## 5-Minute Setup

### Prerequisites
- ✅ Crush CLI installed
- ✅ LM Studio running with a model loaded (port 1234)
- ✅ Node.js 18+ installed

### Step 1: Install MCP Server (2 minutes)

```bash
cd custom-integrations/lm-studio-tools/option1-mcp-server

# Install dependencies
npm install

# Test installation
./setup.sh
```

### Step 2: Configure Crush (1 minute)

Add to your `.crush.json` (in project root or `~/.config/crush/crush.json`):

```json
{
  "$schema": "https://charm.land/crush.json",
  "mcp": {
    "lm-studio-tools": {
      "type": "stdio",
      "command": "node",
      "args": ["/absolute/path/to/custom-integrations/lm-studio-tools/option1-mcp-server/lm-studio-mcp-server.js"],
      "env": {
        "LM_STUDIO_BASE_URL": "http://localhost:1234/v1"
      }
    }
  }
}
```

**Important:** Use absolute path! Replace `/absolute/path/to/` with actual path.

### Step 3: Test (2 minutes)

```bash
# Start Crush
crush

# In Crush, type:
/tools

# Should show:
# - mcp_lm-studio-tools_analyze
# - mcp_lm-studio-tools_generate
# - mcp_lm-studio-tools_refactor
# - mcp_lm-studio-tools_plan
# - mcp_lm-studio-tools_custom
```

### Step 4: First Tool Call

```bash
crush chat "Analyze this Python code for security issues using mcp_lm-studio-tools_analyze:

def login(username, password):
    query = f\"SELECT * FROM users WHERE username='{username}'\"
    return db.execute(query)
"
```

**Expected flow:**
1. Crush (Claude/GPT) receives your request
2. Crush calls `mcp_lm-studio-tools_analyze` tool
3. Tool sends code to local Qwen model via LM Studio
4. Local model analyzes code (~5 seconds)
5. Analysis returned to Crush
6. Crush synthesizes final response

---

## Verify Everything Works

### Check 1: MCP Server Status

```bash
# Run server directly to see logs
cd custom-integrations/lm-studio-tools/option1-mcp-server
node lm-studio-mcp-server.js

# Should output:
# [LM Studio MCP] Starting server...
# [LM Studio MCP] Connected! Found X model(s):
#   - qwen3-30b-q4
# [LM Studio MCP] Server ready!
```

Press Ctrl+C to stop.

### Check 2: LM Studio Connection

```bash
curl http://localhost:1234/v1/models | jq

# Should show loaded models
```

### Check 3: Crush Tools List

```bash
crush tools | grep lm-studio

# Should show 5 tools
```

---

## Common Issues

### "Tool not found"

**Fix:** Check absolute path in `.crush.json`

```bash
pwd  # Get current directory
# Update args in .crush.json with full path
```

### "Connection refused"

**Fix:** Ensure LM Studio server is running

1. Open LM Studio
2. Load a model (e.g., Qwen3-30B-Q4)
3. Click "Start Server" in "Local Server" tab
4. Verify: `curl http://localhost:1234/v1/models`

### "MCP server not starting"

**Fix:** Check Node.js version

```bash
node --version  # Should be v18+

# If too old, upgrade Node.js
```

---

## What You Get

### Available Tools

| Tool | Purpose | Speed |
|------|---------|-------|
| `mcp_lm-studio-tools_analyze` | Code analysis | Fast (5s) |
| `mcp_lm-studio-tools_generate` | Code generation | Medium (8s) |
| `mcp_lm-studio-tools_refactor` | Refactoring ideas | Medium (8s) |
| `mcp_lm-studio-tools_plan` | Architecture planning | Slow (20s+) |
| `mcp_lm-studio-tools_custom` | Custom prompts | Varies |

### Example Use Cases

**1. Security Audit:**
```
crush chat "Use mcp_lm-studio-tools_analyze to audit all JavaScript files for XSS vulnerabilities"
```

**2. Code Generation:**
```
crush chat "Use mcp_lm-studio-tools_generate to create a Python REST API for user management"
```

**3. Refactoring:**
```
crush chat "Use mcp_lm-studio-tools_refactor to improve this function's performance"
```

**4. Architecture:**
```
crush chat "Use mcp_lm-studio-tools_plan to design a microservices architecture for e-commerce"
```

---

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────┐
│                     You (User)                           │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
         ┌───────────────────────────┐
         │      Crush CLI            │
         │  (Main LLM: Claude/GPT)   │
         └──────────┬────────────────┘
                    │
                    ├─── Built-in Tools (view, edit, grep)
                    │
                    └─── MCP: lm-studio-tools
                         │
                         ▼
            ┌────────────────────────┐
            │  lm-studio-mcp-server  │
            │     (Node.js)          │
            └──────────┬─────────────┘
                       │
                       ▼
            ┌────────────────────────┐
            │   LM Studio API        │
            │  (localhost:1234)      │
            └──────────┬─────────────┘
                       │
                       ▼
            ┌────────────────────────┐
            │   Local Models         │
            │   - Qwen3-30B (fast)   │
            │   - Qwen2.5-32B (quality)│
            │   - DeepSeek-236B (reasoning)│
            └────────────────────────┘
```

---

## Next Steps

1. ✅ Complete setup above
2. 📖 Read [USAGE_GUIDE.md](examples/USAGE_GUIDE.md) for detailed examples
3. 🔧 Customize tools in `lm-studio-mcp-server.js`
4. 🚀 Build your own workflows!

---

## Pro Tips

### Tip 1: Allow Tools (Skip Permission Prompts)

Add to `.crush.json`:

```json
{
  "permissions": {
    "allowed_tools": [
      "mcp_lm-studio-tools_analyze",
      "mcp_lm-studio-tools_generate",
      "mcp_lm-studio-tools_refactor"
    ]
  }
}
```

### Tip 2: Multiple Model Instances

Run 3 LM Studio instances on different ports:

- Port 1234: Qwen3-30B (fast)
- Port 1235: Qwen2.5-32B (quality)
- Port 1236: DeepSeek-236B (reasoning)

Configure 3 separate MCP servers in `.crush.json`

### Tip 3: Enable Caching

In `.crush.json`:

```json
{
  "mcp": {
    "lm-studio-tools": {
      "env": {
        "LM_STUDIO_ENABLE_CACHE": "true",
        "LM_STUDIO_CACHE_TTL": "3600"
      }
    }
  }
}
```

---

**You're all set! Happy coding with local AI tools!** 🎉
