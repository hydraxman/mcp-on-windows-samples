# MCP Server MSIX Solution

This solution contains a Windows WinUI 3 app (`mcp-server-msix`) and an MCP server (`McpServer`) that expose shared functionality via a `SharedLibrary`. The MSIX app packages both the WinUI application and the MCP server together, allowing them to work simultaneously while sharing common code.

## Projects

- **mcp-server-msix** - WinUI 3 application that packages and runs alongside the MCP server
- **McpServer** - MCP server built as a self-contained single-file executable
- **SharedLibrary** - Shared functionality used by both the app and the MCP server

## Requirements

- .NET 9.0 SDK or later
- Windows 10 version 19041.0 or later
- Visual Studio 2022 or later (recommended for MSIX development)

## How to Run

**Build the solution (requires x64 platform):**
```powershell
dotnet build -p:Platform=x64
```

**Run the application:**
```powershell
cd mcp-server-msix\bin\x64\Debug\net9.0-windows10.0.19041.0\win-x64
.\mcp-server-msix.exe
```

Or run it directly from Visual Studio by setting `mcp-server-msix` as the startup project and pressing F5.