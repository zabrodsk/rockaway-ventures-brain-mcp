# Rockaway Ventures Brain MCP

This connects Claude Code or Codex to the read-only Rockaway Ventures brain.

After setup, you can chat naturally and ask questions like:

```text
Use the Rockaway brain to answer this: what do we know about this company?
Use the Rockaway brain to find recent notes about this founder.
Use the Rockaway brain to find open threads around this deal.
Use the Rockaway brain to enrich this CSV.
```

This repository connects the Rockaway Ventures brain and installs a small Rockaway brain skill so Claude Code or Codex knows how to ask it questions.

## What You Install

This one setup gives you both pieces:

```text
1. The read-only Rockaway Ventures brain connection.
2. The Rockaway Ventures brain skill.
```

After setup, the skill command is:

```text
$rockaway-ventures-brain
```

Use that command at the start of your message when you want Claude Code or Codex to use the Rockaway Ventures brain.

## Install On Windows

Open PowerShell and paste:

```powershell
irm https://raw.githubusercontent.com/zabrodsk/rockaway-ventures-brain-mcp/main/setup.ps1 | iex
```

The setup asks for your bearer token. The token is hidden while you type.

After setup finishes, restart Claude Code or Codex if it was already open.

## Install On Mac Or Linux

Open Terminal and paste:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zabrodsk/rockaway-ventures-brain-mcp/main/bootstrap.sh)"
```

The setup asks for your bearer token. The token is hidden while you type.

After setup finishes, restart Claude Code or Codex if it was already open.

## What Gets Connected

```text
MCP name: rockaway-ventures
MCP URL:  http://100.102.180.108:8789/rockaway-ventures/mcp
Access:   read-only
```

The brain connection is read-only. It can help answer questions, summarize context, and enrich CSVs, but it cannot edit the brain.

## How To Use It

After setup, use this skill command:

```text
$rockaway-ventures-brain
```

The easiest pattern is:

```text
$rockaway-ventures-brain Use the Rockaway brain to answer this: ...
```

Examples:

```text
$rockaway-ventures-brain Use the Rockaway brain to answer this: what do we know about Acme?
$rockaway-ventures-brain Use the Rockaway brain to find what we know about Jane Example.
$rockaway-ventures-brain Use the Rockaway brain to find notes related to the Series A process.
```

For CSV or spreadsheet lookup, tell Codex or Claude:

```text
$rockaway-ventures-brain Use the Rockaway brain to enrich this CSV.
```

Useful output columns are `row`, `match`, `confidence`, `summary`, `next step`, and `sources`.

To verify from a terminal:

```powershell
codex mcp list
```

You should see `rockaway-ventures`.

## Need A Token?

Ask the Rockaway brain admin for a Rockaway Ventures bearer token. You also need access to the private network where `100.102.180.108` is reachable.

## Setup Guide

Open or download the guide:

[Rockaway Ventures Brain MCP Guide.pdf](docs/Rockaway%20Ventures%20Brain%20MCP%20Guide.pdf)
