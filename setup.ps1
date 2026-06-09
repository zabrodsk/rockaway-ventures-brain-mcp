$ErrorActionPreference = "Stop"

$TeamLabel = "Rockaway Ventures"
$McpName = "rockaway-ventures"
$McpUrl = "http://100.102.180.108:8789/rockaway-ventures/mcp"
$QmdMcpName = "rockaway-ventures-qmd"
$QmdMcpUrl = "https://clawdbot--mac-mini.taild9e247.ts.net:8445/mcp"
$TokenEnv = "ROCKAWAY_VENTURES_MCP_TOKEN"
$SkillName = "rockaway-ventures-brain"
$SkillRawUrl = "https://raw.githubusercontent.com/zabrodsk/rockaway-ventures-brain-mcp/main/skills/rockaway-ventures-brain/SKILL.md"

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

function Set-CodexMcpConfigNoAuth {
  param(
    [string]$ServerName,
    [string]$Url
  )

  $CodexDir = Join-Path $HOME ".codex"
  $ConfigPath = Join-Path $CodexDir "config.toml"
  New-Item -ItemType Directory -Force -Path $CodexDir | Out-Null

  $Block = "[mcp_servers.$ServerName]`nurl = `"$Url`"`n"
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

function Install-RockawayBrainSkill {
  $Source = $null
  $TempRoot = $null

  if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $Candidate = Join-Path $PSScriptRoot "skills\$SkillName"
    if (Test-Path (Join-Path $Candidate "SKILL.md")) {
      $Source = $Candidate
    }
  }

  if (-not $Source) {
    $TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("rockaway-brain-skill-" + [guid]::NewGuid().ToString("N"))
    $Source = Join-Path $TempRoot $SkillName
    New-Item -ItemType Directory -Force -Path $Source | Out-Null
    Invoke-WebRequest -Uri $SkillRawUrl -UseBasicParsing -OutFile (Join-Path $Source "SKILL.md")
  }

  try {
    foreach ($Base in @((Join-Path $HOME ".codex\skills"), (Join-Path $HOME ".claude\skills"))) {
      New-Item -ItemType Directory -Force -Path $Base | Out-Null
      $Dest = Join-Path $Base $SkillName
      if (Test-Path $Dest) {
        Remove-Item -Recurse -Force $Dest
      }
      Copy-Item -Recurse -Path $Source -Destination $Dest
    }
  } finally {
    if ($TempRoot -and (Test-Path $TempRoot)) {
      Remove-Item -Recurse -Force $TempRoot
    }
  }

  Write-Host "Rockaway brain skill installed: $SkillName"
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
  Install-RockawayBrainSkill
  $Claude = Get-Command claude -ErrorAction SilentlyContinue
  if ($Claude) {
    Invoke-NativeQuiet "claude" @("mcp", "remove", $QmdMcpName)
    & claude mcp add --transport http $QmdMcpName $QmdMcpUrl
    Write-Host "Claude Code QMD MCP configured: $QmdMcpName"
  }

  $Codex = Get-Command codex -ErrorAction SilentlyContinue
  if ($Codex) {
    Invoke-NativeQuiet "codex" @("mcp", "remove", $QmdMcpName)
    & codex mcp add $QmdMcpName --url $QmdMcpUrl
    Write-Host "Codex QMD MCP configured: $QmdMcpName"
  }

  Set-CodexMcpConfigNoAuth $QmdMcpName $QmdMcpUrl
  Write-Host "No token entered. Bearer-protected GBrain MCP setup was skipped."
  Write-Host "QMD MCP configured without a token: $QmdMcpName"
  exit 0
}

Install-RockawayBrainSkill

[Environment]::SetEnvironmentVariable($TokenEnv, $Token, "User")
Set-Item -Path "Env:$TokenEnv" -Value $Token

$Claude = Get-Command claude -ErrorAction SilentlyContinue
if ($Claude) {
  Invoke-NativeQuiet "claude" @("mcp", "remove", $McpName)
  & claude mcp add --transport http $McpName $McpUrl --header "Authorization: Bearer $Token"
  Write-Host "Claude Code MCP configured: $McpName"
  Invoke-NativeQuiet "claude" @("mcp", "remove", $QmdMcpName)
  & claude mcp add --transport http $QmdMcpName $QmdMcpUrl
  Write-Host "Claude Code QMD MCP configured: $QmdMcpName"
} else {
  Write-Host "Claude Code CLI not found; skipped Claude Code MCP setup."
}

$Codex = Get-Command codex -ErrorAction SilentlyContinue
if ($Codex) {
  Invoke-NativeQuiet "codex" @("mcp", "remove", $McpName)
  & codex mcp add $McpName --url $McpUrl --bearer-token-env-var $TokenEnv
  Write-Host "Codex MCP configured: $McpName"
  Invoke-NativeQuiet "codex" @("mcp", "remove", $QmdMcpName)
  & codex mcp add $QmdMcpName --url $QmdMcpUrl
  Write-Host "Codex QMD MCP configured: $QmdMcpName"
} else {
  Write-Host "Codex CLI not found; writing Codex config directly."
}

Set-CodexMcpConfig $McpName $McpUrl $TokenEnv
Set-CodexMcpConfigNoAuth $QmdMcpName $QmdMcpUrl

Write-Host ""
Write-Host "Done."
Write-Host "Token saved to your Windows user environment variable: $TokenEnv"
Write-Host "QMD MCP configured without a token: $QmdMcpName"
Write-Host "Restart Claude Code or Codex if they were already open."
Write-Host ""
Write-Host "Try asking:"
Write-Host "  Use the Rockaway brain to answer this: what do we know about this company?"
Write-Host "  Use the Rockaway brain to enrich this CSV."
Write-Host ""
