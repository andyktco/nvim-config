#!/usr/bin/env bash
# Installs Neovim (in ~/.local) + this config on a new machine.
# Usage:  bash <(curl -fsSL https://raw.githubusercontent.com/andyktco/nvim-config/main/install.sh)
set -euo pipefail

REPO="${NVIM_CONFIG_REPO:-https://github.com/andyktco/nvim-config.git}"
NVIM_VERSION="v0.12.6"

case "$(uname -m)" in
  x86_64) ARCH=x86_64 TS_ARCH=x64 ;;
  aarch64 | arm64) ARCH=arm64 TS_ARCH=arm64 ;;
  *) echo "Unsupported arch: $(uname -m)"; exit 1 ;;
esac

mkdir -p ~/.local/bin ~/.local/opt
export PATH="$HOME/.local/bin:$PATH"
# Add ~/.local/bin to PATH for bash and zsh
RCS=(~/.bashrc)
{ [ -f ~/.zshrc ] || command -v zsh >/dev/null; } && RCS+=(~/.zshrc)
for rc in "${RCS[@]}"; do
  grep -q 'HOME/.local/bin' "$rc" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$rc"
done

# 1. System packages (Ubuntu/Debian)
PKGS=""
command -v git >/dev/null || PKGS+=" git"
command -v curl >/dev/null || PKGS+=" curl"
command -v gcc >/dev/null || PKGS+=" build-essential"
command -v unzip >/dev/null || PKGS+=" unzip"
command -v rg >/dev/null || PKGS+=" ripgrep"
command -v node >/dev/null || PKGS+=" nodejs npm"
if [ -n "$PKGS" ]; then
  if command -v apt-get >/dev/null; then
    echo ">> Installing:$PKGS (needs sudo)"
    SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"
    $SUDO apt-get update -qq && $SUDO apt-get install -y -qq $PKGS || echo "!! apt install failed, continuing"
  else
    echo "!! Please install manually:$PKGS"
  fi
fi

# 2. tree-sitter CLI (needed to compile syntax parsers)
if ! command -v tree-sitter >/dev/null; then
  echo ">> Installing tree-sitter CLI in ~/.local/bin"
  curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-$TS_ARCH.gz" |
    gunzip >~/.local/bin/tree-sitter && chmod +x ~/.local/bin/tree-sitter || echo "!! tree-sitter install failed"
fi

# 3. Neovim
if ! nvim --version 2>/dev/null | head -1 | grep -q "${NVIM_VERSION#v}"; then
  echo ">> Installing Neovim $NVIM_VERSION in ~/.local"
  rm -rf ~/.local/opt/nvim-linux-$ARCH
  curl -fsSL "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-$ARCH.tar.gz" | tar xz -C ~/.local/opt
  ln -sf ~/.local/opt/nvim-linux-$ARCH/bin/nvim ~/.local/bin/nvim
fi

# 4. Config
if [ -d ~/.config/nvim/.git ]; then
  echo ">> Updating config"
  git -C ~/.config/nvim pull --ff-only
else
  [ -e ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)
  echo ">> Cloning config"
  git clone "$REPO" ~/.config/nvim
fi

# 5. Warnings
if command -v node >/dev/null; then
  NODE_MAJOR=$(node -v | sed 's/v\([0-9]*\).*/\1/')
  [ "$NODE_MAJOR" -lt 18 ] && echo "!! Node $(node -v) is old; PHP/Tailwind LSPs need Node 18+ (https://github.com/nodesource/distributions)"
fi

echo ">> Done. Reload your shell (exec \$SHELL), then run 'nvim'."
echo "   Plugins install automatically on first start (wait ~1 min)."
