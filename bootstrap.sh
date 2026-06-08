#!/usr/bin/env bash
set -euo pipefail

REPO="zabrodsk/rockaway-ventures-brain-mcp"
BRANCH="main"
WORKDIR="$(mktemp -d)"

cleanup() {
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

echo
echo "Installing Rockaway Ventures Brain MCP setup..."
echo

if command -v git >/dev/null 2>&1; then
  git clone --depth 1 "https://github.com/${REPO}.git" "$WORKDIR/repo" >/dev/null
else
  curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" -o "$WORKDIR/repo.tar.gz"
  mkdir -p "$WORKDIR/repo"
  tar -xzf "$WORKDIR/repo.tar.gz" -C "$WORKDIR/repo" --strip-components 1
fi

chmod 0755 "$WORKDIR/repo/setup.command"
"$WORKDIR/repo/setup.command"
