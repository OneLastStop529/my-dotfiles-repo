#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf "\033[1;32m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!!\033[0m %s\n" "$*"; }
die() {
  printf "\033[1;31mxx\033[0m %s\n" "$*"
  exit 1
}

cd "$REPO_DIR"

log "Bootstrapping dotfiles from: $REPO_DIR"

# 0) Basic deps check
command -v git >/dev/null 2>&1 || die "git is required"
if ! command -v stow >/dev/null 2>&1; then
  warn "GNU stow not found."
  warn "Install it first:"
  warn "  Arch:  sudo pacman -S stow"
  warn "  macOS: brew install stow"
  die "Missing dependency: stow"
fi

# 1) Sync and update submodules
log "Syncing submodules"
git submodule sync --recursive

log "Updating submodules (init + recursive)"
git submodule update --init --recursive

# 2) Stow configs into $HOME
# Assumes repo is structured like:
#   tmux/.config/tmux -> stow tmux => ~/.config/tmux
log "Stowing configs into \$HOME"
STOW_PKGS=(nvim tmux wezterm zsh starship)

for pkg in "${STOW_PKGS[@]}"; do
  if [ -d "$REPO_DIR/$pkg" ]; then
    log "stow --restow $pkg"
    stow --dir "$REPO_DIR" --target "$HOME" --restow "$pkg"
  else
    warn "Skipping missing package dir: $pkg"
  fi
done

# 3) Install TPM (your script)
if [ -x "$REPO_DIR/scripts/install-tpm.sh" ]; then
  log "Installing tmux plugin manager (TPM)"
  "$REPO_DIR/scripts/install-tpm.sh"
else
  warn "scripts/install-tpm.sh not found or not executable; skipping TPM install"
fi

# 4) Helpful post-steps
log "Done."
echo
echo "Next steps:"
echo "  - Restart your shell (or run: exec \$SHELL -l)"
echo "  - Start tmux, then press: prefix + I  (to install tmux plugins)"
echo
