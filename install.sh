#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
#  pks — One-click Installer
#  Installs the Personal Skills Manager CLI to ~/.local/share/pks
#  and adds ~/.local/bin to PATH via .zshrc (or .bashrc).
# =============================================================================

PKS_HOME="${PKS_HOME:-$HOME/.local/share/pks}"
PKS_BIN_DIR="${PKS_BIN_DIR:-$HOME/.local/bin}"
PKS_BIN="$PKS_BIN_DIR/pks"

# ---- helpers ---------------------------------------------------------------
print_info()  { printf "\033[36mℹ\033[0m %s\n" "$*"; }
print_ok()    { printf "\033[32m✓\033[0m %s\n" "$*"; }
print_error() { printf "\033[31m✖\033[0m %s\n" "$*" >&2; }
print_warn()  { printf "\033[33m⚠\033[0m %s\n" "$*" >&2; }

# ---- resolve source directory ----------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ -f "$SCRIPT_DIR/bin/pks" ]]; then
  SOURCE_DIR="$SCRIPT_DIR"
  print_info "Installing from local path: $SOURCE_DIR"
else
  print_error "Install script must be run from the pks repository directory."
  print_error "Please clone the repo first:"
  print_error "  git clone <repo-url> && cd personal-skills-manager && ./install.sh"
  exit 1
fi

# ---- create directories ----------------------------------------------------
mkdir -p "$PKS_HOME" "$PKS_BIN_DIR"

# ---- copy files ------------------------------------------------------------
print_info "Copying files to $PKS_HOME ..."
cp -R "$SOURCE_DIR/." "$PKS_HOME/"
chmod +x "$PKS_HOME/bin/pks"

# ---- create symlink --------------------------------------------------------
if [[ -f "$PKS_BIN" ]] || [[ -L "$PKS_BIN" ]]; then
  print_warn "Removing existing pks at $PKS_BIN"
  rm -f "$PKS_BIN"
fi
ln -s "$PKS_HOME/bin/pks" "$PKS_BIN"
print_ok "Created symlink: $PKS_BIN → $PKS_HOME/bin/pks"

# ---- add ~/.local/bin to PATH in .zshrc / .bashrc -------------------------
detect_rc_file() {
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    echo "$HOME/.zshrc"
  elif [[ -f "$HOME/.zshrc" ]]; then
    echo "$HOME/.zshrc"
  elif [[ -f "$HOME/.bashrc" ]]; then
    echo "$HOME/.bashrc"
  elif [[ -f "$HOME/.bash_profile" ]]; then
    echo "$HOME/.bash_profile"
  else
    echo "$HOME/.zshrc"
  fi
}

RC_FILE="$(detect_rc_file)"

update_path() {
  local rc="$1"
  local dir="$2"
  local line="export PATH=\"\$PATH:$dir\""

  if [[ ! -f "$rc" ]]; then
    echo "$line" > "$rc"
    print_ok "Created $rc with PATH entry for $dir"
    return 0
  fi

  if grep -qF "$dir" "$rc" 2>/dev/null; then
    print_ok "$dir already in PATH (in $rc)"
    return 0
  fi

  echo "" >> "$rc"
  echo "# Added by pks (Personal Skills Manager) installer" >> "$rc"
  echo "$line" >> "$rc"
  print_ok "Added $dir to PATH in $rc"
  print_info "Run 'source $rc' or restart your terminal to use pks"
}

update_path "$RC_FILE" "$PKS_BIN_DIR"

# ---- verify ----------------------------------------------------------------
if command -v pks &>/dev/null; then
  print_ok "pks is ready!"
  echo ""
  pks help
else
  print_warn "pks installed at $PKS_BIN, but not yet in PATH."
  print_info "Run 'source $RC_FILE' or restart your terminal."
fi
