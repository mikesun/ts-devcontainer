#!/usr/bin/env bash
set -euo pipefail

install_config_if_missing() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  # If file exists, do not overwrite (preserve user edits in persistent home).
  if [[ -f "$dst" ]]; then
    echo "Config exists, leaving as-is: $dst"
    return 0
  fi

  # Install with safe permissions.
  install -m 600 "$src" "$dst"
  echo "Installed: $dst"
}

USER_HOME="${HOME:-/home/node}"

# Base deps
sudo apt-get update
sudo apt-get install -y socat curl ca-certificates vim fish

BASHRC="$HOME/.bashrc"

# Ensure SSH_AUTH_SOCK exported for bash login shells
LINE='export SSH_AUTH_SOCK="/tmp/ssh-agent.sock"'
grep -qxF "$LINE" "$BASHRC" || echo "$LINE" >> "$BASHRC"

# pnpm 9
npm install -g pnpm@latest-9

# Deno
npm install -g deno

# Claude Code
if command -v claude >/dev/null 2>&1; then
  echo "Claude already installed at: $(command -v claude) — skipping."
else
  curl -fsSL https://claude.ai/install.sh | bash
fi

install_config_if_missing \
  "$WORKSPACE_DIR/.devcontainer/config/claude/settings.json" \
  "${USER_HOME}/.claude/settings.json"

# Codex
npm i -g @openai/codex
