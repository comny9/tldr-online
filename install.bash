#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/comny9/tldr-online.git"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tldr-online"
BIN_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
SCRIPT_NAME="${SCRIPT_NAME:-tldr}"
LINK="${BIN_DIR}/${SCRIPT_NAME}"

existing=$(command -v "$SCRIPT_NAME" 2>/dev/null || true)
if [[ -n "$existing" && "$(readlink -f "$existing" 2>/dev/null)" != "$(readlink -f "$LINK" 2>/dev/null)" ]]; then
  echo "Warning: '$SCRIPT_NAME' already exists at $existing"
  if dpkg -S "$existing" &>/dev/null; then
    pkg=$(dpkg -S "$existing" 2>/dev/null | cut -d: -f1)
    echo "  Installed via apt (package: $pkg)"
    echo "  To remove: sudo apt remove $pkg"
  fi
  echo ""
  read -rp "Continue? ($LINK will take priority if PATH is set correctly) [y/N] " ans < /dev/tty
  if [[ "$ans" != [yY] ]]; then
    echo "Aborted."
    exit 0
  fi
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ -f "$SCRIPT_DIR/tldr-online.bash" ]] && git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
  DATA_DIR="$SCRIPT_DIR"
  echo "Using local repository: $DATA_DIR"
elif git -C "$DATA_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Updating existing installation..."
  git -C "$DATA_DIR" pull
else
  echo "Cloning tldr-online..."
  git clone "$REPO_URL" "$DATA_DIR"
fi

mkdir -p "$BIN_DIR"
ln -sf "${DATA_DIR}/tldr-online.bash" "$LINK"
echo "Installed: $LINK -> ${DATA_DIR}/tldr-online.bash"

if ! echo "$PATH" | tr ':' '\n' | grep -qxF "$BIN_DIR"; then
  echo ""
  echo "Warning: ${BIN_DIR} is not in your PATH."
  echo "Add the following to your shell config (~/.bashrc, ~/.zshrc, etc.):"
  echo ""
  echo "  export PATH=\"${BIN_DIR}:\$PATH\""
fi

echo ""
echo "Update later with: $SCRIPT_NAME --update"
