#!/usr/bin/env pwsh
# Build script for MCP C# bundle

Write-Host "Building MCP C# server and packaging as bundle..." -ForegroundColor Green

# Detect current machine architecture
$arch = $env:PROCESSOR_ARCHITECTURE
if ($arch -eq "ARM64") {
    $runtime = "win-arm64"
} elseif ($arch -eq "AMD64" -or $arch -eq "x64") {
    $runtime = "win-x64"
} else {
    Write-Error "Unsupported architecture: $arch"
    exit 1
}

Write-Host "Detected architecture: $arch, using runtime: $runtime" -ForegroundColor Cyan

# Step 1: Build the server
Write-Host "Step 1: Building the server..." -ForegroundColor Yellow
dotnet publish McpServer.csproj -c Release -r $runtime --self-contained true -p:PublishSingleFile=true
if ($LASTEXITCODE -ne 0) {
    Write-Error "Publish failed!"
    exit 1
}

# Step 2: Copy files to server directory
Write-Host "Step 2: Copying executable to mcpb server directory..." -ForegroundColor Yellow
$sourceFile = ".\bin\Release\net10.0\$runtime\publish\McpServer.exe"
$targetDir = ".\mcpb\server\"

# Ensure target directory exists
if (!(Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force
}

Copy-Item $sourceFile $targetDir -Force
if (!(Test-Path "$targetDir\McpServer.exe")) {
    Write-Error "Failed to copy executable!"
    exit 1
}

# Step 3: Pack the bundle
Write-Host "Step 3: Packing the MCP bundle..." -ForegroundColor Yellow
npx -y @anthropic-ai/mcpb pack mcpb mcp-dotnet-mcpb-server.mcpb
if ($LASTEXITCODE -ne 0) {
    Write-Error "Packing failed!"
    exit 1
}

Write-Host "Build and pack completed successfully!" -ForegroundColor Green
Write-Host "You can now double-click 'mcp-dotnet-mcpb-server.mcpb' to install the bundle." -ForegroundColor Cyan
