###############################################################################
# LM Studio MCP Server Setup Script (PowerShell/Windows)
#
# This script sets up the MCP server for using LM Studio models as tools
# in Crush CLI on Windows.
###############################################################################

$ErrorActionPreference = "Stop"

# Colors
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success { Write-ColorOutput Green $args }
function Write-Warning { Write-ColorOutput Yellow $args }
function Write-Error { Write-ColorOutput Red $args }
function Write-Info { Write-ColorOutput Cyan $args }

Write-Info "╔════════════════════════════════════════════════════════════╗"
Write-Info "║     LM Studio MCP Server Setup for Crush CLI              ║"
Write-Info "║                  (Windows)                                 ║"
Write-Info "╚════════════════════════════════════════════════════════════╝"
Write-Host ""

# Check prerequisites
Write-Warning "Checking prerequisites..."

# Check Node.js
try {
    $nodeVersion = node --version
    $versionNumber = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')

    if ($versionNumber -lt 18) {
        Write-Error "✗ Node.js version too old (found $nodeVersion, need v18+)"
        Write-Host "  Download from: https://nodejs.org/"
        exit 1
    }

    Write-Success "✓ Node.js $nodeVersion"
} catch {
    Write-Error "✗ Node.js not found"
    Write-Host "  Install Node.js 18+ from: https://nodejs.org/"
    exit 1
}

# Check npm
try {
    $npmVersion = npm --version
    Write-Success "✓ npm $npmVersion"
} catch {
    Write-Error "✗ npm not found"
    exit 1
}

# Check LM Studio
Write-Host ""
Write-Warning "Checking LM Studio..."

$lmStudioUrl = if ($env:LM_STUDIO_BASE_URL) { $env:LM_STUDIO_BASE_URL } else { "http://localhost:1234/v1" }

try {
    $response = Invoke-RestMethod -Uri "$lmStudioUrl/models" -Method Get -TimeoutSec 5
    $modelCount = $response.data.Count

    Write-Success "✓ LM Studio connected!"
    Write-Host "  URL: $lmStudioUrl"
    Write-Host "  Models loaded: $modelCount"

    if ($modelCount -gt 0) {
        Write-Host "  Available models:"
        foreach ($model in $response.data) {
            Write-Host "    - $($model.id)"
        }
    }
} catch {
    Write-Warning "⚠ LM Studio not running or not accessible"
    Write-Host "  URL: $lmStudioUrl"
    Write-Host ""
    Write-Host "  Please:"
    Write-Host "  1. Open LM Studio"
    Write-Host "  2. Load a model"
    Write-Host "  3. Start the local server (default port 1234)"
    Write-Host ""

    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        exit 1
    }
}

# Install dependencies
Write-Host ""
Write-Warning "Installing dependencies..."

npm install

if ($LASTEXITCODE -eq 0) {
    Write-Success "✓ Dependencies installed"
} else {
    Write-Error "✗ Failed to install dependencies"
    exit 1
}

# Test server
Write-Host ""
Write-Warning "Testing MCP server..."

# Create test script
@"
const { spawn } = require('child_process');

const server = spawn('node', ['lm-studio-mcp-server.js']);

let errorOutput = '';

server.stderr.on('data', (data) => {
  errorOutput += data.toString();
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
"@ | Out-File -FilePath "test-connection.js" -Encoding UTF8

$testResult = node test-connection.js
if ($LASTEXITCODE -eq 0) {
    Write-Success $testResult
    Remove-Item "test-connection.js"
} else {
    Write-Error $testResult
    Remove-Item "test-connection.js"
    exit 1
}

# Get absolute path for configuration
$currentPath = Get-Location
$serverPath = Join-Path $currentPath "lm-studio-mcp-server.js"

# Create or update Crush configuration
Write-Host ""
Write-Warning "Configuring Crush CLI..."

# Check for .crush.json in various locations
$crushConfigPath = $null
$possiblePaths = @(
    "..\..\..\..\..\.crush.json",
    "$env:USERPROFILE\.config\crush\crush.json",
    "$env:APPDATA\crush\crush.json"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $crushConfigPath = $path
        break
    }
}

if (-not $crushConfigPath) {
    Write-Warning "  No existing .crush.json found"
    $create = Read-Host "  Create .crush.json in Crush-Local root? (y/n)"

    if ($create -eq 'y' -or $create -eq 'Y') {
        $crushConfigPath = "..\..\..\..\..\.crush.json"
        Copy-Item ".crush.json" $crushConfigPath
        Write-Success "  ✓ Created .crush.json"
    }
}

if ($crushConfigPath) {
    Write-Success "✓ Crush configuration ready"
    Write-Host "  Config file: $crushConfigPath"
    Write-Host ""
    Write-Host "  Add this to your .crush.json (use the FULL Windows path):"
    Write-Host ""
    Write-Host @"
  "mcp": {
    "lm-studio-tools": {
      "type": "stdio",
      "command": "node",
      "args": ["$serverPath"],
      "env": {
        "LM_STUDIO_BASE_URL": "http://localhost:1234/v1"
      }
    }
  }
"@
}

# Final instructions
Write-Host ""
Write-Info "╔════════════════════════════════════════════════════════════╗"
Write-Info "║                  Setup Complete!                           ║"
Write-Info "╚════════════════════════════════════════════════════════════╝"
Write-Host ""
Write-Success "Next steps:"
Write-Host ""
Write-Host "1. Ensure LM Studio is running with a model loaded"
Write-Host "2. Configure Crush CLI (see configuration above)"
Write-Host "3. Test the integration:"
Write-Host ""
Write-Host '   crush chat "Use the lm_studio_analyze tool to analyze this code:"'
Write-Host ""
Write-Host "4. Available tools:"
Write-Host "   - mcp_lm-studio-tools_analyze    # Code analysis"
Write-Host "   - mcp_lm-studio-tools_generate   # Code generation"
Write-Host "   - mcp_lm-studio-tools_refactor   # Refactoring suggestions"
Write-Host "   - mcp_lm-studio-tools_plan       # Architecture planning"
Write-Host "   - mcp_lm-studio-tools_custom     # Custom prompts"
Write-Host ""
Write-Host "For detailed usage, see: ../README.md"
Write-Host ""

Write-Info "Windows-specific notes:"
Write-Host "  - Use PowerShell (not Command Prompt)"
Write-Host "  - Use backslashes in paths: C:\path\to\file"
Write-Host "  - Or use forward slashes: C:/path/to/file (also works)"
Write-Host "  - Ensure Node.js is in your PATH"
Write-Host ""
