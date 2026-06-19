#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/tldr-pages/tldr/main/pages"
PLATFORMS=("common" "linux" "osx" "android" "windows" "freebsd" "netbsd" "openbsd" "sunos")

self_update() {
  local script_dir
  script_dir="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
  if git -C "$script_dir" rev-parse --is-inside-work-tree &>/dev/null; then
    git -C "$script_dir" pull
  else
    echo "Error: not a git repository ($script_dir)" >&2
    echo "Reinstall with: https://github.com/comny9/tldr-online" >&2
    exit 1
  fi
}

SELF_NAME="$(basename "$0" .bash)"
SELF_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

show_usage() {
  cat <<EOF
Usage: $SELF_NAME <command> [subcommand...] [--platform=<platform>]
  e.g. $SELF_NAME git worktree
       $SELF_NAME apt --platform=linux
  See '$SELF_NAME -h' for more info.
EOF
}

show_help() {
  cat <<EOF
Usage: $SELF_NAME <command> [subcommand...] [--platform=<platform>]
       $SELF_NAME --update
       $SELF_NAME -h | --help

Options:
  --platform=<platform>  Specify platform (linux, osx, common, etc.)
  --update               Update tldr-online itself (git pull)
  -h, --help             Show this help

Examples:
  $SELF_NAME git worktree
  $SELF_NAME apt --platform=linux

Update:
  $SELF_NAME --update

Uninstall:
  rm "$(command -v "$SELF_NAME" 2>/dev/null || echo ~/.local/bin/$SELF_NAME)"
  rm -rf "$SELF_DIR"
EOF
}

if [[ $# -eq 0 ]]; then
  show_usage
  exit 1
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
  exit 0
fi

if [[ "$1" == "--update" ]]; then
  self_update
  exit 0
fi

explicit_platform=""
args=()
for arg in "$@"; do
  if [[ "$arg" == --platform=* ]]; then
    explicit_platform="${arg#--platform=}"
  else
    args+=("$arg")
  fi
done

cmd=$(IFS=-; echo "${args[*]}")

render() {
  local tmpfile
  tmpfile=$(mktemp /tmp/tldr-XXXXXX.md)
  cat > "$tmpfile"
  trap "rm -f \"$tmpfile\"" EXIT
  if command -v glow &>/dev/null; then
    PAGER=cat glow -p "$tmpfile"
  elif command -v batcat &>/dev/null; then
    batcat --language=md --style=plain --paging=never "$tmpfile"
  elif command -v bat &>/dev/null; then
    bat --language=md --style=plain --paging=never "$tmpfile"
  else
    cat "$tmpfile"
  fi
}

fetch_page() {
  local platform="$1"
  curl -sf "${BASE_URL}/${platform}/${cmd}.md"
}

if [[ -n "$explicit_platform" ]]; then
  page=$(fetch_page "$explicit_platform") || {
    echo "Error: '${cmd}' not found in platform '${explicit_platform}'" >&2
    exit 1
  }
  echo "$page" | render
  exit 0
fi

for p in "${PLATFORMS[@]}"; do
  if page=$(fetch_page "$p"); then
    echo "$page" | render
    exit 0
  fi
done

echo "Error: '${cmd}' not found in any platform" >&2
exit 1
