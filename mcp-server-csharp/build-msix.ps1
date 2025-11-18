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

# Step 1: Build the project
Write-Host "Step 1: Build the project..." -ForegroundColor Yellow
dotnet publish McpServer.csproj -c Release -r $runtime --self-contained true -p:PublishSingleFile=true
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed!"
    exit 1
}

# Step 2: Copy files to server directory
Write-Host "Step 2: Copying executable to msix server directory..." -ForegroundColor Yellow
$sourceFile = ".\bin\Release\net10.0\$runtime\publish\McpServer.exe"
$targetDir = ".\msix\server\"

# Ensure target directory exists
if (!(Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force
}

Copy-Item $sourceFile $targetDir -Force
if (!(Test-Path "$targetDir\McpServer.exe")) {
    Write-Error "Failed to copy executable!"
    exit 1
}

# Step 3: Create the msix package
Write-Host "Step 3: Creating the MSIX package..." -ForegroundColor Yellow

# Check if certificate exists, if not generate one
winapp cert generate --manifest "msix\appxmanifest.xml" --if-exists skip

# Package the MSIX
Write-Host "Packaging MSIX..." -ForegroundColor Yellow
winapp pack ".\msix" --cert ".\devcert.pfx"
if ($LASTEXITCODE -ne 0) {
    Write-Error "MSIX packaging failed!"
    exit 1
}

Write-Host ""
Write-Host "Build and pack completed successfully!" -ForegroundColor Green
Write-Host "You can now install the generated *.msix package" -ForegroundColor Cyan
Write-Host "NOTE: If this is the first time installing on this machine, you may need to install the development certificate first (see README.md)" -ForegroundColor Yellow
