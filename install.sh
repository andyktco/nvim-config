#!/usr/bin/env bash
# Installs / updates Neovim + tmux and this config. Safe to run again any time:
# every step only does what is missing or changed.
# Usage:  bash <(curl -fsSL https://raw.githubusercontent.com/andyktco/nvim-config/main/install.sh)
set -euo pipefail

REPO="${NVIM_CONFIG_REPO:-https://github.com/andyktco/nvim-config.git}"
NVIM_VERSION="v0.12.6"
CATPPUCCIN_VERSION="v2.3.2"

CFG=~/.config/nvim
PLUGINS=~/.tmux/plugins
CATP=~/.local/share/tmux/catppuccin # outside TPM dir, so clean_plugins keeps it

# Everything is inside main() so bash reads the whole file before running it
# (the script updates itself via git pull while it runs).
main() {
  case "$(uname -m)" in
    x86_64) ARCH=x86_64 TS_ARCH=x64 ;;
    aarch64 | arm64) ARCH=arm64 TS_ARCH=arm64 ;;
    *) echo "Unsupported arch: $(uname -m)"; exit 1 ;;
  esac

  mkdir -p ~/.local/bin ~/.local/opt ~/.config
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
  command -v tmux >/dev/null || PKGS+=" tmux"
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

  # 4. Config repo
  if [ -d $CFG/.git ]; then
    echo ">> Updating config"
    git -C $CFG pull --ff-only
  else
    [ -e $CFG ] && mv $CFG $CFG.bak.$(date +%s)
    echo ">> Cloning config"
    git clone "$REPO" $CFG
  fi

  # 5. nvim plugins: install missing ones and match the versions in nvim-pack-lock.json
  echo ">> Syncing nvim plugins"
  nvim --headless -c 'lua vim.pack.update(nil, { target = "lockfile", force = true })' -c 'qa' >/dev/null 2>&1 ||
    echo "!! nvim plugin sync failed (open nvim and run :lua vim.pack.update())"

  # 6. tmux config: ~/.config/tmux -> repo/tmux
  if [ "$(readlink ~/.config/tmux 2>/dev/null)" != "$CFG/tmux" ]; then
    [ -e ~/.config/tmux ] || [ -L ~/.config/tmux ] && mv ~/.config/tmux ~/.config/tmux.bak.$(date +%s)
    ln -s $CFG/tmux ~/.config/tmux
    echo ">> Linked ~/.config/tmux"
  fi
  # ~/.tmux.conf would take precedence over ~/.config/tmux/tmux.conf
  [ -e ~/.tmux.conf ] && mv ~/.tmux.conf ~/.tmux.conf.bak.$(date +%s) && echo ">> Moved old ~/.tmux.conf to backup"

  # 7. tmux plugins
  mkdir -p "$(dirname $CATP)"
  if [ "$(cat $CATP.version 2>/dev/null)" != "$CATPPUCCIN_VERSION" ] || [ ! -f $CATP/catppuccin.tmux ]; then
    echo ">> Installing catppuccin $CATPPUCCIN_VERSION"
    rm -rf $CATP
    git -c advice.detachedHead=false clone -q --depth 1 -b "$CATPPUCCIN_VERSION" https://github.com/catppuccin/tmux.git $CATP
    echo "$CATPPUCCIN_VERSION" >$CATP.version
  fi

  if [ -d $PLUGINS/tpm/.git ]; then
    git -C $PLUGINS/tpm pull -q --ff-only || true
  else
    echo ">> Installing TPM"
    git clone -q --depth 1 https://github.com/tmux-plugins/tpm $PLUGINS/tpm
  fi
  echo ">> Syncing tmux plugins"
  $PLUGINS/tpm/bin/install_plugins >/dev/null || echo "!! tmux plugin install failed"
  $PLUGINS/tpm/bin/update_plugins all >/dev/null || true
  $PLUGINS/tpm/bin/clean_plugins >/dev/null || true

  # reload tmux if it is running
  tmux info >/dev/null 2>&1 && tmux source-file ~/.config/tmux/tmux.conf && echo ">> Reloaded running tmux"

  # 8. Warnings
  if command -v node >/dev/null; then
    NODE_MAJOR=$(node -v | sed 's/v\([0-9]*\).*/\1/')
    [ "$NODE_MAJOR" -lt 18 ] && echo "!! Node $(node -v) is old; PHP/Tailwind LSPs need Node 18+ (https://github.com/nodesource/distributions)"
  fi
  if command -v tmux >/dev/null; then
    TMUX_V=$(tmux -V | grep -oE '[0-9]+\.[0-9]+' | head -1)
    awk "BEGIN{exit !($TMUX_V < 3.2)}" && echo "!! tmux $TMUX_V is old; the theme needs tmux 3.2+"
  fi

  echo ">> Done. Reload your shell (exec \$SHELL), then run 'tmux' and 'nvim'."
  echo "   On first start nvim installs LSP tools in the background (wait ~1 min)."
}

main "$@"
exit
