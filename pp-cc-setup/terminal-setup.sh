#!/bin/bash
set -eo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# Terminal Setup Script
# Installs: Homebrew · Ghostty · Starship · Claude Code
# Platforms: macOS · Windows (Git Bash) · Linux / WSL
# Safe to re-run — already-installed tools are skipped, but configuration
# is always verified and completed if missing.
# ──────────────────────────────────────────────────────────────────────────────

# ── Logging helpers ───────────────────────────────────────────────────────────
STEP=0
step()  { STEP=$((STEP+1)); echo ""; echo "Step $STEP: $*"; printf '%.0s─' {1..50}; echo; }
ok()    { echo "  [DONE] $*"; }
info()  { echo "         $*"; }
warn()  { echo "  [NOTE] $*"; }
err()   { echo "  [ERR]  $*" >&2; }

# ── OS detection ──────────────────────────────────────────────────────────────
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]] || [[ "${OS:-}" == "Windows_NT" ]]; then
        echo "windows"
    elif grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
    else
        echo "linux"
    fi
}

OS=$(detect_os)

# ── Config helpers ────────────────────────────────────────────────────────────

# Ensure a line is in a file, and report what happened.
ensure_line() {
    local line="$1" file="$2" label="$3"
    touch "$file"
    if grep -qxF "$line" "$file" 2>/dev/null; then
        ok "$label already configured in $(basename "$file")"
    else
        echo "$line" >> "$file"
        ok "$label added to $(basename "$file")"
    fi
}

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║             Terminal Setup Script                ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "  Platform: $OS"
echo ""
echo "  What will be installed / configured:"
echo "    1. Homebrew   — package manager (downloads other tools)"
echo "    2. Ghostty    — fast, modern terminal app"
echo "    3. Starship   — smart shell prompt with git info"
echo "    4. Claude Code — AI coding assistant"
echo ""
echo "  This script is safe to run more than once."
echo "  Already-installed tools are skipped; missing"
echo "  configuration is always completed."
echo ""

# ══════════════════════════════════════════════════════════════════════════════
# macOS
# ══════════════════════════════════════════════════════════════════════════════
install_macos() {
    local zshrc="$HOME/.zshrc"

    # Apple Silicon Macs use /opt/homebrew; older Intel Macs use /usr/local
    if [[ "$(uname -m)" == "arm64" ]]; then
        local brew_bin="/opt/homebrew/bin/brew"
        local brew_init='eval "$(/opt/homebrew/bin/brew shellenv)"'
    else
        local brew_bin="/usr/local/bin/brew"
        local brew_init='eval "$(/usr/local/bin/brew shellenv)"'
    fi

    # ── 1. Homebrew ────────────────────────────────────────────────────────────
    step "Homebrew (package manager)"
    if command -v brew &>/dev/null; then
        ok "Homebrew already installed"
    else
        info "Downloading installer..."
        info "You will be asked for your Mac login password. This is normal."
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
            -o /tmp/_brew_install.sh
        NONINTERACTIVE=1 bash /tmp/_brew_install.sh
        rm -f /tmp/_brew_install.sh
        ok "Homebrew installed"
    fi
    ensure_line "$brew_init" "$zshrc" "Homebrew PATH"
    eval "$brew_init"

    # ── 2. Ghostty ─────────────────────────────────────────────────────────────
    step "Ghostty (terminal app)"
    if brew list --cask ghostty &>/dev/null; then
        ok "Ghostty already installed"
    else
        info "Downloading Ghostty (this may take a minute)..."
        brew install --cask ghostty
        ok "Ghostty installed"
    fi
    # Ghostty is a GUI app — no shell config needed.

    # ── 3. Starship ────────────────────────────────────────────────────────────
    step "Starship (shell prompt)"
    if brew list starship &>/dev/null; then
        ok "Starship already installed"
    else
        info "Installing Starship..."
        brew install starship
        ok "Starship installed"
    fi
    ensure_line 'eval "$(starship init zsh)"' "$zshrc" "Starship prompt init"

    # ── 4. Claude Code ─────────────────────────────────────────────────────────
    step "Claude Code (AI assistant)"
    if command -v claude &>/dev/null; then
        ok "Claude Code already installed"
    else
        info "Downloading Claude Code..."
        curl -fsSL https://claude.ai/install.sh -o /tmp/_claude_install.sh
        bash /tmp/_claude_install.sh
        rm -f /tmp/_claude_install.sh
        ok "Claude Code installed"
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
# Windows (Git Bash / MSYS2)
# ══════════════════════════════════════════════════════════════════════════════
install_windows() {
    local bashrc="$HOME/.bashrc"
    local -a wflags=(--accept-package-agreements --accept-source-agreements --silent)

    if ! command -v winget &>/dev/null; then
        echo ""
        err "winget (Windows Package Manager) was not found."
        echo ""
        echo "  To fix this:"
        echo "    1. Open the Microsoft Store"
        echo "    2. Search for 'App Installer'"
        echo "    3. Click Install or Update"
        echo "    4. Close Git Bash and reopen it, then run this script again"
        exit 1
    fi

    # ── 1. Ghostty ─────────────────────────────────────────────────────────────
    step "Ghostty (terminal app)"
    if command -v ghostty &>/dev/null; then
        ok "Ghostty already installed"
    else
        info "Installing Ghostty via Windows Package Manager..."
        if winget install --id Ghostty.Ghostty "${wflags[@]}"; then
            ok "Ghostty installed"
        else
            warn "Ghostty could not be installed automatically."
            warn "Download it manually from: https://ghostty.org/download"
            warn "Continuing with the rest of the setup..."
        fi
    fi
    # Ghostty is a GUI app — no shell config needed.

    # ── 2. Starship ────────────────────────────────────────────────────────────
    step "Starship (shell prompt)"
    if command -v starship &>/dev/null; then
        ok "Starship already installed"
    else
        info "Installing Starship via Windows Package Manager..."
        if winget install --id Starship.Starship "${wflags[@]}"; then
            ok "Starship installed"
        else
            warn "Starship could not be installed automatically."
            warn "Download it manually from: https://starship.rs"
        fi
    fi
    ensure_line 'eval "$(starship init bash)"' "$bashrc" "Starship prompt init"

    # ── 3. Node.js (required by Claude Code) ───────────────────────────────────
    step "Node.js (required by Claude Code)"
    if command -v npm &>/dev/null; then
        ok "Node.js already installed"
    else
        info "Installing Node.js via Windows Package Manager..."
        winget install --id OpenJS.NodeJS.LTS "${wflags[@]}" || true

        # The MSI installer puts node + npm in C:\Program Files\nodejs
        # In Git Bash that path is /c/Program Files/nodejs
        local node_path="/c/Program Files/nodejs"
        if [[ -d "$node_path" ]]; then
            export PATH="$node_path:$PATH"
            ensure_line "export PATH=\"/c/Program Files/nodejs:\$PATH\"" "$bashrc" "Node.js PATH"
            ok "Node.js installed and added to PATH"
        else
            echo ""
            warn "Node.js was installed but needs a shell restart to activate."
            echo ""
            echo "  ┌─────────────────────────────────────────────────────┐"
            echo "  │  ACTION REQUIRED — please do the following:         │"
            echo "  │                                                     │"
            echo "  │  1. Close this Git Bash window                      │"
            echo "  │  2. Open a new Git Bash window                      │"
            echo "  │  3. Run this script again to finish the setup       │"
            echo "  └─────────────────────────────────────────────────────┘"
            exit 0
        fi
    fi

    # ── 4. Claude Code ─────────────────────────────────────────────────────────
    step "Claude Code (AI assistant)"
    if command -v claude &>/dev/null; then
        ok "Claude Code already installed"
    else
        info "Installing Claude Code..."
        npm install -g @anthropic-ai/claude-code
        ok "Claude Code installed"
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
# Linux / WSL
# ══════════════════════════════════════════════════════════════════════════════
install_linux() {
    local bashrc="$HOME/.bashrc"

    # ── 1. Homebrew ────────────────────────────────────────────────────────────
    step "Homebrew (package manager)"
    if command -v brew &>/dev/null; then
        ok "Homebrew already installed"
    else
        info "Downloading installer..."
        info "You may be asked for your password. This is normal."
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
            -o /tmp/_brew_install.sh
        NONINTERACTIVE=1 bash /tmp/_brew_install.sh
        rm -f /tmp/_brew_install.sh
        ok "Homebrew installed"
    fi

    # Detect prefix — system-wide install vs. user install
    if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
        BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"
    elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
        BREW_BIN="$HOME/.linuxbrew/bin/brew"
    else
        err "Homebrew was installed but could not be located."
        err "Please close and reopen your terminal, then run this script again."
        exit 1
    fi
    local brew_init="eval \"\$($BREW_BIN shellenv)\""
    ensure_line "$brew_init" "$bashrc" "Homebrew PATH"
    eval "$($BREW_BIN shellenv)"

    # ── 2. Ghostty ─────────────────────────────────────────────────────────────
    step "Ghostty (terminal app)"
    if [[ "$OS" == "wsl" ]]; then
        warn "Running inside WSL — Ghostty is a Windows app."
        warn "Install it on the Windows side by running this script"
        warn "in Git Bash (not inside WSL)."
        warn "Skipping. Your current terminal still works fine."
    elif command -v ghostty &>/dev/null; then
        ok "Ghostty already installed"
    else
        warn "Ghostty cannot be installed automatically on Linux."
        warn "Visit https://ghostty.org/download for instructions."
        warn "Your current terminal still works fine — this is optional."
    fi

    # ── 3. Starship ────────────────────────────────────────────────────────────
    step "Starship (shell prompt)"
    if command -v starship &>/dev/null; then
        ok "Starship already installed"
    else
        info "Installing Starship..."
        brew install starship
        ok "Starship installed"
    fi
    ensure_line 'eval "$(starship init bash)"' "$bashrc" "Starship prompt init"

    # ── 4. Claude Code ─────────────────────────────────────────────────────────
    step "Claude Code (AI assistant)"
    if command -v claude &>/dev/null; then
        ok "Claude Code already installed"
    else
        info "Downloading Claude Code..."
        curl -fsSL https://claude.ai/install.sh -o /tmp/_claude_install.sh
        bash /tmp/_claude_install.sh
        rm -f /tmp/_claude_install.sh
        ok "Claude Code installed"
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
# Run
# ══════════════════════════════════════════════════════════════════════════════
case "$OS" in
    macos)       install_macos ;;
    windows)     install_windows ;;
    wsl | linux) install_linux ;;
    *)
        err "Unsupported operating system: '$OS'"
        echo "  This script supports macOS, Windows (Git Bash), and Linux/WSL."
        exit 1
        ;;
esac

# ══════════════════════════════════════════════════════════════════════════════
# Done
# ══════════════════════════════════════════════════════════════════════════════
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║                  All done!                      ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
if [[ "$OS" == "macos" ]]; then
    echo "  To activate your new prompt now, run:"
    echo ""
    echo "    source ~/.zshrc"
else
    echo "  To activate your new prompt now, run:"
    echo ""
    echo "    source ~/.bashrc"
fi
echo ""
echo "  Or just close and reopen your terminal — it will"
echo "  pick up all changes automatically."
echo ""
echo "  Quick reference:"
echo "    Ghostty    → open it from your Applications / Start Menu"
echo "    Starship   → your prompt changes next time you open a terminal"
echo "    Claude Code → type 'claude' in any terminal window to start"
echo ""
