#!/bin/bash
###############################################################################
# LM Studio MCP Server Setup Script
#
# This script sets up the MCP server for using LM Studio models as tools
# in Crush CLI.
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     LM Studio MCP Server Setup for Crush CLI              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js not found${NC}"
    echo "  Install Node.js 18+ from: https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo -e "${RED}✗ Node.js version too old (found v${NODE_VERSION}, need v18+)${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Node.js $(node --version)${NC}"

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}✗ npm not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ npm $(npm --version)${NC}"

# Check LM Studio
echo ""
echo -e "${YELLOW}Checking LM Studio...${NC}"

LM_STUDIO_URL="${LM_STUDIO_BASE_URL:-http://localhost:1234/v1}"

if curl -s -f "${LM_STUDIO_URL}/models" > /dev/null 2>&1; then
    MODELS=$(curl -s "${LM_STUDIO_URL}/models" | jq -r '.data[].id' 2>/dev/null || echo "")
    MODEL_COUNT=$(echo "$MODELS" | wc -l)

    echo -e "${GREEN}✓ LM Studio connected!${NC}"
    echo -e "  URL: $LM_STUDIO_URL"
    echo -e "  Models loaded: $MODEL_COUNT"

    if [ -n "$MODELS" ]; then
        echo "  Available models:"
        echo "$MODELS" | sed 's/^/    - /'
    fi
else
    echo -e "${YELLOW}⚠ LM Studio not running or not accessible${NC}"
    echo "  URL: $LM_STUDIO_URL"
    echo ""
    echo "  Please:"
    echo "  1. Open LM Studio"
    echo "  2. Load a model"
    echo "  3. Start the local server (default port 1234)"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install dependencies
echo ""
echo -e "${YELLOW}Installing dependencies...${NC}"

npm install

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${RED}✗ Failed to install dependencies${NC}"
    exit 1
fi

# Test server
echo ""
echo -e "${YELLOW}Testing MCP server...${NC}"

# Create test script
cat > test-connection.js << 'EOF'
const { spawn } = require('child_process');

const server = spawn('node', ['lm-studio-mcp-server.js']);

let output = '';
let errorOutput = '';

server.stderr.on('data', (data) => {
  errorOutput += data.toString();
});

server.stdout.on('data', (data) => {
  output += data.toString();
});

setTimeout(() => {
  server.kill();

  if (errorOutput.includes('Server ready')) {
    console.log('✓ MCP server starts successfully');
    process.exit(0);
  } else {
    console.log('✗ MCP server failed to start');
    console.log('Error output:', errorOutput);
    process.exit(1);
  }
}, 3000);
EOF

if node test-connection.js; then
    echo -e "${GREEN}✓ MCP server test passed${NC}"
    rm -f test-connection.js
else
    echo -e "${RED}✗ MCP server test failed${NC}"
    rm -f test-connection.js
    exit 1
fi

# Create or update Crush configuration
echo ""
echo -e "${YELLOW}Configuring Crush CLI...${NC}"

CRUSH_CONFIG=""

# Check for .crush.json in various locations
if [ -f "../../../../.crush.json" ]; then
    CRUSH_CONFIG="../../../../.crush.json"
elif [ -f "$HOME/.config/crush/crush.json" ]; then
    CRUSH_CONFIG="$HOME/.config/crush/crush.json"
else
    echo -e "${YELLOW}  No existing .crush.json found${NC}"
    read -p "  Create .crush.json in Crush-Local root? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        CRUSH_CONFIG="../../../../.crush.json"
        cp .crush.json "$CRUSH_CONFIG"
        echo -e "${GREEN}  ✓ Created .crush.json${NC}"
    fi
fi

if [ -n "$CRUSH_CONFIG" ]; then
    echo -e "${GREEN}✓ Crush configuration ready${NC}"
    echo "  Config file: $CRUSH_CONFIG"
    echo ""
    echo "  To use the MCP server with Crush, add this to your .crush.json:"
    echo ""
    cat << 'CONFIG'
  "mcp": {
    "lm-studio-tools": {
      "type": "stdio",
      "command": "node",
      "args": ["custom-integrations/lm-studio-tools/option1-mcp-server/lm-studio-mcp-server.js"],
      "env": {
        "LM_STUDIO_BASE_URL": "http://localhost:1234/v1"
      }
    }
  }
CONFIG
fi

# Final instructions
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  Setup Complete!                           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo ""
echo "1. Ensure LM Studio is running with a model loaded"
echo "2. Configure Crush CLI (see configuration above)"
echo "3. Test the integration:"
echo ""
echo "   crush chat \"Use the lm_studio_analyze tool to analyze this code:\""
echo ""
echo "4. Available tools:"
echo "   - mcp_lm-studio-tools_analyze    # Code analysis"
echo "   - mcp_lm-studio-tools_generate   # Code generation"
echo "   - mcp_lm-studio-tools_refactor   # Refactoring suggestions"
echo "   - mcp_lm-studio-tools_plan       # Architecture planning"
echo "   - mcp_lm-studio-tools_custom     # Custom prompts"
echo ""
echo "For detailed usage, see: ../README.md"
echo ""
