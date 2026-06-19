# tldr-online

Fetch and render [tldr-pages](https://github.com/tldr-pages/tldr) directly from GitHub — no local cache, always up-to-date.

## Features

- Fetches tldr pages from GitHub on every invocation (no install/update of page data needed)
- Supports subcommands with spaces (`git worktree`, `docker compose`, etc.)
- Auto-detects platform (`common`, `linux`, `osx`, ...)
- Renders Markdown with [glow](https://github.com/charmbracelet/glow), [bat](https://github.com/sharkdp/bat), or plain text
- Self-update with `--update` (`git pull`)

## Requirements

- `bash`, `curl`, `git`
- (Optional) `glow` or `bat`/`batcat` for Markdown rendering

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/comny9/tldr-online/main/install.bash | bash
```

This will:
1. Clone the repository to `~/.local/share/tldr-online`
2. Create a symlink `~/.local/bin/tldr` -> the script

If an existing `tldr` command is detected, you will be prompted before continuing.

To customize:

```bash
# Change install directory and command name
curl -fsSL https://raw.githubusercontent.com/comny9/tldr-online/main/install.bash | INSTALL_DIR=~/bin SCRIPT_NAME=tldr-online bash
```

## Update

```bash
tldr --update
```

## Uninstall

```bash
rm ~/.local/bin/tldr
rm -rf ~/.local/share/tldr-online
```

## Usage

```bash
# Basic usage
tldr tar
tldr curl

# Subcommands (space-separated)
tldr git worktree
tldr docker compose

# Specify platform explicitly
tldr apt --platform=linux
tldr brew --platform=osx
```

## How it works

Pages are fetched from the raw GitHub URL:

```
https://raw.githubusercontent.com/tldr-pages/tldr/main/pages/{platform}/{command}.md
```

When no platform is specified, the following are searched in order:

`common` → `linux` → `osx` → `android` → `windows` → `freebsd` → `netbsd` → `openbsd` → `sunos`

## License

MIT
