#!/usr/bin/env bash
set -euo pipefail

USER_HOME="${HOME:-/home/node}"

# Base deps
sudo apt-get update
sudo apt-get install -y socat curl ca-certificates vim fish

BASHRC="$HOME/.bashrc"

# Ensure SSH_AUTH_SOCK exported for bash login shells
LINE='export SSH_AUTH_SOCK="/tmp/ssh-agent.sock"'
grep -qxF "$LINE" "$BASHRC" || echo "$LINE" >> "$BASHRC"

# pnpm 10
npm install -g pnpm@latest-10

# Claude Code
if command -v claude >/dev/null 2>&1; then
  echo "Claude already installed at: $(command -v claude) — skipping."
else
  curl -fsSL https://claude.ai/install.sh | bash
fi

# Codex
npm i -g @openai/codex
