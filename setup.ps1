$ErrorActionPreference = "Stop"

$TeamLabel = "Rockaway Ventures"
$McpName = "rockaway-ventures"
$McpUrl = "http://100.102.180.108:8789/rockaway-ventures/mcp"
$TokenEnv = "ROCKAWAY_VENTURES_MCP_TOKEN"

if (Get-Variable PSNativeCommandUseErrorActionPreference -Scope Global -ErrorAction SilentlyContinue) {
  $global:PSNativeCommandUseErrorActionPreference = $false
}

function Invoke-NativeQuiet {
  param(
    [string]$Command,
    [string[]]$Arguments
  )

  $PreviousErrorActionPreference = $ErrorActionPreference
  $ErrorActionPreference = "SilentlyContinue"
  try {
    & $Command @Arguments *> $null
  } catch {
  } finally {
    $ErrorActionPreference = $PreviousErrorActionPreference
  }
}

function Set-CodexMcpConfig {
  param(
    [string]$ServerName,
    [string]$Url,
    [string]$EnvVar
  )

  $CodexDir = Join-Path $HOME ".codex"
  $ConfigPath = Join-Path $CodexDir "config.toml"
  New-Item -ItemType Directory -Force -Path $CodexDir | Out-Null

  $Block = "[mcp_servers.$ServerName]`nurl = `"$Url`"`nbearer_token_env_var = `"$EnvVar`"`n"
  if (Test-Path $ConfigPath) {
    $Content = Get-Content -Raw -Path $ConfigPath
    $Pattern = "(?ms)^\[mcp_servers\." + [regex]::Escape($ServerName) + "\]\s.*?(?=^\[|\z)"
    if ([regex]::IsMatch($Content, $Pattern)) {
      $Content = [regex]::Replace($Content, $Pattern, $Block)
    } else {
      if ($Content.Length -gt 0 -and -not $Content.EndsWith("`n")) {
        $Content += "`n"
      }
      $Content += "`n" + $Block
    }
  } else {
    $Content = $Block
  }

  [System.IO.File]::WriteAllText($ConfigPath, $Content, [System.Text.UTF8Encoding]::new($false))
  Write-Host "Codex config ensured: $ConfigPath"
}

Write-Host ""
Write-Host "$TeamLabel Brain MCP setup"
Write-Host "This connects Claude Code and Codex to the read-only $TeamLabel brain."
Write-Host ""
Write-Host "Paste your $TeamLabel bearer token below."
Write-Host "The input is hidden while you type."

$SecureToken = Read-Host "Bearer token" -AsSecureString
$Bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureToken)
try {
  $Token = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($Bstr)
} finally {
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($Bstr)
}

if ([string]::IsNullOrWhiteSpace($Token)) {
  Write-Host "No token entered. MCP setup was skipped."
  exit 0
}

[Environment]::SetEnvironmentVariable($TokenEnv, $Token, "User")
Set-Item -Path "Env:$TokenEnv" -Value $Token

$Claude = Get-Command claude -ErrorAction SilentlyContinue
if ($Claude) {
  Invoke-NativeQuiet "claude" @("mcp", "remove", $McpName)
  & claude mcp add --transport http $McpName $McpUrl --header "Authorization: Bearer $Token"
  Write-Host "Claude Code MCP configured: $McpName"
} else {
  Write-Host "Claude Code CLI not found; skipped Claude Code MCP setup."
}

$Codex = Get-Command codex -ErrorAction SilentlyContinue
if ($Codex) {
  Invoke-NativeQuiet "codex" @("mcp", "remove", $McpName)
  & codex mcp add $McpName --url $McpUrl --bearer-token-env-var $TokenEnv
  Write-Host "Codex MCP configured: $McpName"
} else {
  Write-Host "Codex CLI not found; writing Codex config directly."
}

Set-CodexMcpConfig $McpName $McpUrl $TokenEnv

Write-Host ""
Write-Host "Done."
Write-Host "Token saved to your Windows user environment variable: $TokenEnv"
Write-Host "Restart Claude Code or Codex if they were already open."
Write-Host ""
Write-Host "Try asking:"
Write-Host "  What does the Ventures brain know about this company?"
Write-Host "  Search the Ventures brain for recent notes about this founder."
Write-Host ""
