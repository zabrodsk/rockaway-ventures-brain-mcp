#!/usr/bin/env bash
set -euo pipefail

TEAM_LABEL="Rockaway Ventures"
MCP_NAME="rockaway-ventures"
MCP_URL="http://100.102.180.108:8789/rockaway-ventures/mcp"
TOKEN_ENV="ROCKAWAY_VENTURES_MCP_TOKEN"
ENV_DIR="$HOME/.rockaway-brain-mcp"
ENV_FILE="$ENV_DIR/ventures.env"
SKILL_NAME="rockaway-ventures-brain"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_skill() {
  local src="$ROOT/skills/$SKILL_NAME"
  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "Rockaway brain skill not found at: $src"
    return 0
  fi

  for base in "$HOME/.codex/skills" "$HOME/.claude/skills" "$HOME/.agents/skills"; do
    mkdir -p "$base"
    rm -rf "$base/$SKILL_NAME"
    cp -R "$src" "$base/$SKILL_NAME"
  done
  echo "Rockaway brain skill installed: $SKILL_NAME"
}

echo
echo "${TEAM_LABEL} Brain MCP setup"
echo "This connects Claude Code and Codex to the read-only ${TEAM_LABEL} brain."
echo
echo "Paste your ${TEAM_LABEL} bearer token below."
echo "The input is hidden while you type."
printf "Bearer token: "
IFS= read -rs TOKEN
echo

install_skill

if [[ -z "$TOKEN" ]]; then
  echo "No token entered. MCP setup was skipped."
  exit 0
fi

mkdir -p "$ENV_DIR"
chmod 700 "$ENV_DIR"
cat > "$ENV_FILE" <<EOF
export ${TOKEN_ENV}="${TOKEN}"
EOF
chmod 600 "$ENV_FILE"

if command -v launchctl >/dev/null 2>&1; then
  launchctl setenv "$TOKEN_ENV" "$TOKEN" 2>/dev/null || true
fi

if [[ -f "$HOME/.zshrc" ]] && ! grep -q "$ENV_FILE" "$HOME/.zshrc"; then
  {
    echo
    echo "# Rockaway Brain MCP"
    echo "[[ -f \"$ENV_FILE\" ]] && source \"$ENV_FILE\""
  } >> "$HOME/.zshrc"
fi

if command -v claude >/dev/null 2>&1; then
  claude mcp remove "$MCP_NAME" >/dev/null 2>&1 || true
  claude mcp add "$MCP_NAME" --transport http "$MCP_URL" --header "Authorization: Bearer $TOKEN"
  echo "Claude Code MCP configured: $MCP_NAME"
else
  echo "Claude Code CLI not found; skipped Claude Code MCP setup."
fi

if command -v codex >/dev/null 2>&1; then
  codex mcp remove "$MCP_NAME" >/dev/null 2>&1 || true
  codex mcp add "$MCP_NAME" --url "$MCP_URL" --bearer-token-env-var "$TOKEN_ENV"
  echo "Codex MCP configured: $MCP_NAME"
else
  echo "Codex CLI not found; skipped Codex MCP setup."
fi

echo
echo "Done."
echo "Token saved locally at: $ENV_FILE"
echo "Restart Claude Code or Codex if they were already open."
echo
echo "Try asking:"
echo "  Use the Rockaway brain to answer this: what do we know about this company?"
echo "  Use the Rockaway brain to enrich this CSV."
echo
