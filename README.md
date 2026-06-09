# Rockaway Ventures Brain MCP

This connects Claude Code or Codex to the read-only Rockaway Ventures brain.

After setup, you can chat naturally and ask questions like:

```text
What does the Ventures brain know about this company?
Search the Ventures brain for recent notes about this founder.
What open threads do we have around this deal?
Which pages mention this person?
```

This repository installs the MCP connection plus a small memory lookup skill that tells agents to call `memory_lookup` first.

## Install On Windows

Open PowerShell and paste:

```powershell
irm https://raw.githubusercontent.com/zabrodsk/rockaway-ventures-brain-mcp/main/setup.ps1 | iex
```

The setup asks for your bearer token. The token is hidden while you type.

## Install On Mac Or Linux

Open Terminal and paste:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zabrodsk/rockaway-ventures-brain-mcp/main/bootstrap.sh)"
```

The setup asks for your bearer token. The token is hidden while you type.

## What Gets Connected

```text
MCP name: rockaway-ventures
MCP URL:  http://100.102.180.108:8789/rockaway-ventures/mcp
Access:   read-only
```

Available brain tools include `memory_lookup`, `brain_help`, search, query, page reads, links, backlinks, QMD deeper retrieval, and stats. The MCP cannot edit the brain.
For speed, agents should use `memory_lookup` first. It uses the Mac mini's sanitized Ventures QMD index first, then falls back to GBrain.

## How To Use It

After setup, restart Claude Code or Codex if it was already open.

Then ask normal questions:

```text
Use the Rockaway Ventures brain to summarize what we know about Acme.
Search the Ventures brain for the latest context on Jane Example.
What notes in the Ventures brain mention the Series A process?
```

For CSV or spreadsheet lookup, tell Codex or Claude:

```text
Use the Rockaway memory lookup skill for this team. For each CSV row, call memory_lookup first, then get_page only for the strongest matches.
```

Expected output columns: `row_id`, `query`, `matched_pages`, `confidence`, `summary`, `recommended_next_step`, `source_slugs`.

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
