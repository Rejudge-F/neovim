#!/usr/bin/env bash
# ============================================================================
# Makefile Installation Test Script
# Run after `make macos` or `make unix` to verify all tools installed correctly.
#
# Usage:
#   ./test/test.sh           # Run all checks
#   ./test/test.sh --strict  # Fail on ANY missing tool (including optional)
# ============================================================================

set -uo pipefail

# Ensure tools installed by `make unix` are found:
#   ~/.local/bin: lua-language-server, stylua, shfmt (when downloaded as binaries)
#   ~/go/bin:     shfmt (when installed via `go install`), gopls, dlv
# CI shells don't include these in PATH by default.
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

STRICT=${1:-}
PASS=0
FAIL=0
WARN=0

check_required() {
    local name=$1
    local cmd=${2:-$1}
    if command -v "$cmd" >/dev/null 2>&1; then
        printf "  ${GREEN}✓${RESET} %-25s %s\n" "$name" "$(command -v "$cmd")"
        PASS=$((PASS + 1))
    else
        printf "  ${RED}✗${RESET} %-25s MISSING (required)\n" "$name"
        FAIL=$((FAIL + 1))
    fi
}

check_optional() {
    local name=$1
    local cmd=${2:-$1}
    if command -v "$cmd" >/dev/null 2>&1; then
        printf "  ${GREEN}✓${RESET} %-25s %s\n" "$name" "$(command -v "$cmd")"
        PASS=$((PASS + 1))
    else
        if [ "$STRICT" = "--strict" ]; then
            printf "  ${RED}✗${RESET} %-25s MISSING (strict mode)\n" "$name"
            FAIL=$((FAIL + 1))
        else
            printf "  ${YELLOW}○${RESET} %-25s skipped (optional)\n" "$name"
            WARN=$((WARN + 1))
        fi
    fi
}

check_nvim_version() {
    if ! command -v nvim >/dev/null 2>&1; then
        printf "  ${RED}✗${RESET} %-25s NOT INSTALLED\n" "neovim >= 0.10"
        FAIL=$((FAIL + 1))
        return
    fi
    local ver
    ver=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    local major minor
    major=$(echo "$ver" | cut -d. -f1)
    minor=$(echo "$ver" | cut -d. -f2)
    if [ "$major" -ge 1 ] || [ "$minor" -ge 10 ]; then
        printf "  ${GREEN}✓${RESET} %-25s %s\n" "neovim >= 0.10" "$(nvim --version | head -1)"
        PASS=$((PASS + 1))
    else
        printf "  ${RED}✗${RESET} %-25s %s (need 0.10+)\n" "neovim >= 0.10" "$ver"
        FAIL=$((FAIL + 1))
    fi
}

check_npm_global() {
    local name=$1
    if npm list -g "$name" >/dev/null 2>&1; then
        printf "  ${GREEN}✓${RESET} %-25s (npm global)\n" "$name"
        PASS=$((PASS + 1))
    else
        printf "  ${RED}✗${RESET} %-25s MISSING (npm global)\n" "$name"
        FAIL=$((FAIL + 1))
    fi
}

check_pip_package() {
    local name=$1
    if pip3 show "$name" >/dev/null 2>&1; then
        printf "  ${GREEN}✓${RESET} %-25s (pip)\n" "$name"
        PASS=$((PASS + 1))
    else
        printf "  ${RED}✗${RESET} %-25s MISSING (pip)\n" "$name"
        FAIL=$((FAIL + 1))
    fi
}

check_file_link() {
    local name=$1
    local path=$2
    if [ -f "$path" ] || [ -L "$path" ]; then
        printf "  ${GREEN}✓${RESET} %-25s %s\n" "$name" "$path"
        PASS=$((PASS + 1))
    else
        printf "  ${YELLOW}○${RESET} %-25s not found at %s\n" "$name" "$path"
        WARN=$((WARN + 1))
    fi
}

check_font() {
    if command -v fc-list >/dev/null 2>&1; then
        if fc-list 2>/dev/null | grep -qi 'Hack.*Nerd'; then
            printf "  ${GREEN}✓${RESET} %-25s installed\n" "Hack Nerd Font"
            PASS=$((PASS + 1))
        else
            printf "  ${YELLOW}○${RESET} %-25s not found (may need terminal restart)\n" "Hack Nerd Font"
            WARN=$((WARN + 1))
        fi
    else
        # macOS doesn't have fc-list by default
        printf "  ${YELLOW}○${RESET} %-25s cannot verify (no fc-list)\n" "Hack Nerd Font"
        WARN=$((WARN + 1))
    fi
}

echo ''
printf "${CYAN}═══════════════════════════════════════════════════${RESET}\n"
printf "${CYAN}  Neovim Config — Installation Test${RESET}\n"
printf "${CYAN}═══════════════════════════════════════════════════${RESET}\n"
echo ''

# --- Core ---
printf "${CYAN}Core Tools${RESET}\n"
echo '───────────────────────────────────────────────'
check_nvim_version
check_required 'git'
check_required 'ripgrep' 'rg'
check_required 'curl'
check_required 'make'
check_optional 'fd'
check_optional 'cmake'
echo ''

# --- Node.js ---
printf "${CYAN}Node.js${RESET}\n"
echo '───────────────────────────────────────────────'
check_required 'node'
check_required 'npm'
check_npm_global 'bash-language-server'
check_npm_global 'vscode-langservers-extracted'
echo ''

# --- Python ---
printf "${CYAN}Python${RESET}\n"
echo '───────────────────────────────────────────────'
check_required 'python3'
check_required 'pip3'
check_pip_package 'pyright'
check_pip_package 'black'
check_pip_package 'ruff'
check_pip_package 'debugpy'
echo ''

# --- Go (optional) ---
printf "${CYAN}Go (optional)${RESET}\n"
echo '───────────────────────────────────────────────'
check_optional 'go'
check_optional 'gopls'
check_optional 'goimports'
check_optional 'dlv'
echo ''

# --- Rust (optional) ---
printf "${CYAN}Rust (optional)${RESET}\n"
echo '───────────────────────────────────────────────'
check_optional 'rustup'
check_optional 'rust-analyzer'
check_optional 'rustfmt'
echo ''

# --- Lua ---
printf "${CYAN}Lua${RESET}\n"
echo '───────────────────────────────────────────────'
check_required 'lua-language-server'
check_required 'stylua'
echo ''

# --- Shell ---
printf "${CYAN}Shell${RESET}\n"
echo '───────────────────────────────────────────────'
check_required 'shfmt'
echo ''

# --- Terminal ---
printf "${CYAN}Terminal & Fonts${RESET}\n"
echo '───────────────────────────────────────────────'
check_optional 'starship'
check_file_link 'kitty.conf' "$HOME/.config/kitty/kitty.conf"
check_file_link 'starship.toml' "$HOME/.config/starship.toml"
check_font
echo ''

# --- Neovim Plugins ---
printf "${CYAN}Neovim Plugins${RESET}\n"
echo '───────────────────────────────────────────────'
LAZY_DIR="${HOME}/.local/share/nvim/lazy"
if [ -d "$LAZY_DIR" ]; then
    PLUGIN_COUNT=$(ls -1 "$LAZY_DIR" 2>/dev/null | wc -l | tr -d ' ')
    printf "  ${GREEN}✓${RESET} %-25s %s plugins installed\n" "lazy.nvim" "$PLUGIN_COUNT"
    PASS=$((PASS + 1))
else
    printf "  ${YELLOW}○${RESET} %-25s not yet synced (run nvim first)\n" "lazy.nvim"
    WARN=$((WARN + 1))
fi
echo ''

# --- Summary ---
echo '═══════════════════════════════════════════════════'
printf "  ${GREEN}✓ Passed: %d${RESET}" "$PASS"
if [ "$FAIL" -gt 0 ]; then
    printf "  ${RED}✗ Failed: %d${RESET}" "$FAIL"
fi
if [ "$WARN" -gt 0 ]; then
    printf "  ${YELLOW}○ Skipped: %d${RESET}" "$WARN"
fi
echo ''
echo '═══════════════════════════════════════════════════'
echo ''

if [ "$FAIL" -gt 0 ]; then
    printf "${RED}Some required tools are missing!${RESET}\n"
    exit 1
else
    printf "${GREEN}All required tools installed successfully!${RESET}\n"
    exit 0
fi