#!/usr/bin/env bash
set -euo pipefail

TPM_DIR="$HOME/.tmux/plugins/tpm"
TPM_REPO="https://github.com/tmux-plugins/tpm"

echo "→ Checking TPM..."

if [ -d "$TPM_DIR" ]; then
  echo "✓ TPM already installed at $TPM_DIR"
else
  echo "→ Installing TPM..."
  mkdir -p "$(dirname "$TPM_DIR")"
  git clone "$TPM_REPO" "$TPM_DIR"
  echo "✓ TPM installed"
fi

echo "→ Done"
echo "👉 Start tmux and press prefix + I to install plugins"
