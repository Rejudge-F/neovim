.PHONY: macos unix brew-deps apt-deps neovim node-deps python-deps go-deps rust-deps \
       lua-deps lua-deps-brew lua-deps-apt shell-deps shell-deps-brew shell-deps-apt \
       fonts fonts-brew fonts-apt terminal terminal-macos terminal-linux \
       nvim-plugins check help clean

# ============================================================================
# Neovim Configuration Installer
# Usage:
#   make macos   — Install everything on macOS (Homebrew)
#   make unix    — Install everything on Linux (apt/dnf/pacman)
# ============================================================================

# Colors
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
CYAN   := \033[0;36m
RESET  := \033[0m

# Use sudo only when not root
SUDO := $(shell [ "$$(id -u)" = "0" ] && echo "" || echo "sudo")

define log_info
	@printf '$(GREEN)[✓]$(RESET) %s\n' $(1)
endef

define log_warn
	@printf '$(YELLOW)[!]$(RESET) %s\n' $(1)
endef

define log_step
	@printf '$(CYAN)[→]$(RESET) %s\n' $(1)
endef

define finish_msg
	@echo ''
	@printf '$(GREEN)════════════════════════════════════════════════════$(RESET)\n'
	@printf '$(GREEN)  Installation complete!$(RESET)\n'
	@printf '$(GREEN)════════════════════════════════════════════════════$(RESET)\n'
	@echo ''
	@echo '  Next steps:'
	@echo '    1. Launch nvim — plugins auto-install on first run'
	@echo '    2. Run :Lazy to verify plugin status'
	@echo '    3. Run :Mason to verify LSP servers'
	@echo '    4. Run :checkhealth for full diagnostics'
	@echo ''
endef

# Detect Linux package manager
PKG_MGR := $(shell \
	if command -v apt-get >/dev/null 2>&1; then echo apt; \
	elif command -v dnf >/dev/null 2>&1; then echo dnf; \
	elif command -v pacman >/dev/null 2>&1; then echo pacman; \
	else echo unknown; fi)

# Detect pip command (some distros have pip3, some have pip, some need python3 -m pip)
PIP := $(shell \
	if command -v pip3 >/dev/null 2>&1; then echo pip3; \
	elif command -v pip >/dev/null 2>&1; then echo pip; \
	else echo "python3 -m pip"; fi)

# ============================================================================
# Main targets
# ============================================================================
macos: brew-deps neovim node-deps python-deps go-deps rust-deps lua-deps-brew shell-deps-brew fonts-brew terminal-macos nvim-plugins
	$(call finish_msg)

unix: ensure-local-bin apt-deps neovim node-deps python-deps go-deps rust-deps lua-deps-apt shell-deps-apt fonts-apt terminal-linux nvim-plugins
	$(call finish_msg)

# Ensure ~/.local/bin exists before anything tries to install there
ensure-local-bin:
	@mkdir -p "$$HOME/.local/bin"

# ============================================================================
# macOS — Homebrew
# ============================================================================
brew-deps:
	$(call log_step,"Installing Homebrew (if needed)...")
	@command -v brew >/dev/null 2>&1 || \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	$(call log_step,"Installing core dependencies via Homebrew...")
	@brew install neovim git ripgrep fd curl make cmake || true
	$(call log_info,"Homebrew dependencies installed")

# ============================================================================
# Linux — apt / dnf / pacman
# ============================================================================
apt-deps:
	$(call log_step,"Installing core dependencies via $(PKG_MGR)...")
ifeq ($(PKG_MGR),apt)
	@$(SUDO) apt-get update -qq
	@# Ubuntu apt ships old neovim — install from PPA for 0.10+
	@if ! nvim --version 2>/dev/null | head -1 | grep -qE '0\.(1[0-9]|[2-9][0-9])|[1-9]\.'; then \
		$(SUDO) apt-get install -y -qq software-properties-common >/dev/null; \
		$(SUDO) add-apt-repository -y ppa:neovim-ppa/unstable >/dev/null 2>&1; \
		$(SUDO) apt-get update -qq; \
	fi
	@$(SUDO) apt-get install -y -qq neovim git ripgrep fd-find curl build-essential cmake unzip wget python3 python3-pip python3-venv >/dev/null
	@if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then \
		$(SUDO) ln -sf $$(which fdfind) /usr/local/bin/fd; \
	fi
else ifeq ($(PKG_MGR),dnf)
	@$(SUDO) dnf install -y neovim git ripgrep fd-find curl gcc gcc-c++ make cmake unzip wget python3 python3-pip >/dev/null
else ifeq ($(PKG_MGR),pacman)
	@$(SUDO) pacman -Syu --noconfirm --needed neovim git ripgrep fd curl base-devel cmake unzip wget python python-pip >/dev/null
else
	$(call log_warn,"Unknown package manager. Please install manually: neovim git ripgrep fd curl cmake")
endif
	$(call log_info,"System dependencies installed")

# ============================================================================
# Neovim — verify version
# ============================================================================
neovim:
	$(call log_step,"Verifying Neovim version...")
	@nvim --version | head -1
	@nvim_ver=$$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1); \
	 major=$$(echo $$nvim_ver | cut -d. -f1); \
	 minor=$$(echo $$nvim_ver | cut -d. -f2); \
	 if [ "$$major" -lt 1 ] && [ "$$minor" -lt 10 ]; then \
		printf '$(RED)[✗] Neovim 0.10+ required. Current: %s$(RESET)\n' "$$nvim_ver"; \
		exit 1; \
	 fi
	$(call log_info,"Neovim version OK")

# ============================================================================
# Node.js — for LSP servers, markdown-preview
# ============================================================================
node-deps:
	$(call log_step,"Setting up Node.js...")
	@if ! command -v node >/dev/null 2>&1; then \
		if command -v brew >/dev/null 2>&1; then \
			brew install node; \
		elif command -v apt-get >/dev/null 2>&1; then \
			curl -fsSL https://deb.nodesource.com/setup_lts.x | $(SUDO) -E bash - && \
			$(SUDO) apt-get install -y -qq nodejs >/dev/null; \
		elif command -v dnf >/dev/null 2>&1; then \
			$(SUDO) dnf install -y nodejs npm >/dev/null; \
		elif command -v pacman >/dev/null 2>&1; then \
			$(SUDO) pacman -S --noconfirm --needed nodejs npm >/dev/null; \
		else \
			printf '$(RED)[✗]$(RESET) Cannot install Node.js — install manually\n'; \
		fi \
	fi
	$(call log_step,"Installing Node-based tools...")
	@npm list -g bash-language-server >/dev/null 2>&1 || npm install -g bash-language-server
	@npm list -g vscode-langservers-extracted >/dev/null 2>&1 || npm install -g vscode-langservers-extracted
	$(call log_info,"Node.js dependencies installed")

# ============================================================================
# Python — pyright, formatters, debugger
# ============================================================================
python-deps:
	$(call log_step,"Setting up Python tools...")
	@if ! command -v python3 >/dev/null 2>&1; then \
		if command -v brew >/dev/null 2>&1; then \
			brew install python; \
		elif command -v apt-get >/dev/null 2>&1; then \
			$(SUDO) apt-get install -y -qq python3 python3-pip python3-venv >/dev/null; \
		elif command -v dnf >/dev/null 2>&1; then \
			$(SUDO) dnf install -y python3 python3-pip >/dev/null; \
		elif command -v pacman >/dev/null 2>&1; then \
			$(SUDO) pacman -S --noconfirm --needed python python-pip >/dev/null; \
		fi \
	fi
	@$(PIP) install --user --break-system-packages pyright black ruff debugpy 2>/dev/null || \
		$(PIP) install --user pyright black ruff debugpy 2>/dev/null || \
		$(PIP) install pyright black ruff debugpy || true
	$(call log_info,"Python tools installed (pyright, black, ruff, debugpy)")

# ============================================================================
# Go — gopls, goimports, delve
# ============================================================================
go-deps:
	$(call log_step,"Setting up Go tools...")
	@if command -v go >/dev/null 2>&1; then \
		go install golang.org/x/tools/gopls@latest; \
		go install golang.org/x/tools/cmd/goimports@latest; \
		go install github.com/go-delve/delve/cmd/dlv@latest; \
		printf '$(GREEN)[✓]$(RESET) Go tools installed (gopls, goimports, dlv)\n'; \
	else \
		printf '$(YELLOW)[!]$(RESET) Go not found — skipping Go tools. Install via: https://go.dev/dl/\n'; \
	fi

# ============================================================================
# Rust — rust-analyzer, rustfmt
# ============================================================================
rust-deps:
	$(call log_step,"Setting up Rust tools...")
	@if command -v rustup >/dev/null 2>&1; then \
		rustup component add rust-analyzer rustfmt 2>/dev/null || true; \
		printf '$(GREEN)[✓]$(RESET) Rust tools installed (rust-analyzer, rustfmt)\n'; \
	else \
		printf '$(YELLOW)[!]$(RESET) Rust not found — skipping. Install via: curl --proto =https --tlsv1.2 -sSf https://sh.rustup.rs | sh\n'; \
	fi

# ============================================================================
# Lua — lua-language-server, stylua (platform-specific)
# ============================================================================
lua-deps-brew:
	$(call log_step,"Setting up Lua tools...")
	@brew install lua-language-server stylua || true
	$(call log_info,"Lua tools installed (lua-language-server, stylua)")

lua-deps-apt:
	$(call log_step,"Setting up Lua tools...")
	@mkdir -p "$$HOME/.local/bin"
	@# lua-language-server: download prebuilt from GitHub
	@if ! command -v lua-language-server >/dev/null 2>&1; then \
		LLS_VERSION=$$(curl -s https://api.github.com/repos/LuaLS/lua-language-server/releases/latest | grep '"tag_name"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'); \
		if [ -n "$$LLS_VERSION" ]; then \
			LLS_ARCH=$$(uname -m | sed 's/x86_64/x64/;s/aarch64/arm64/'); \
			LLS_URL="https://github.com/LuaLS/lua-language-server/releases/download/$$LLS_VERSION/lua-language-server-$$LLS_VERSION-linux-$$LLS_ARCH.tar.gz"; \
			mkdir -p "$$HOME/.local/lib/lua-language-server"; \
			curl -fsSL "$$LLS_URL" | tar xz -C "$$HOME/.local/lib/lua-language-server"; \
			ln -sf "$$HOME/.local/lib/lua-language-server/bin/lua-language-server" "$$HOME/.local/bin/lua-language-server"; \
			printf '$(GREEN)[✓]$(RESET) lua-language-server installed\n'; \
		else \
			printf '$(YELLOW)[!]$(RESET) Could not fetch lua-language-server version — install via Mason (:MasonInstall lua-language-server)\n'; \
		fi \
	else \
		printf '$(GREEN)[✓]$(RESET) lua-language-server already installed\n'; \
	fi
	@# stylua: download prebuilt from GitHub
	@if ! command -v stylua >/dev/null 2>&1; then \
		STYLUA_VERSION=$$(curl -s https://api.github.com/repos/JohnnyMorganz/StyLua/releases/latest | grep '"tag_name"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'); \
		if [ -n "$$STYLUA_VERSION" ]; then \
			STYLUA_ARCH=$$(uname -m | sed 's/x86_64/x86_64/;s/aarch64/aarch64/'); \
			STYLUA_URL="https://github.com/JohnnyMorganz/StyLua/releases/download/v$$STYLUA_VERSION/stylua-linux-$$STYLUA_ARCH.zip"; \
			curl -fsSL "$$STYLUA_URL" -o /tmp/stylua.zip && \
			unzip -oq /tmp/stylua.zip -d /tmp/stylua-bin && \
			chmod +x /tmp/stylua-bin/stylua && \
			mv /tmp/stylua-bin/stylua "$$HOME/.local/bin/stylua" && \
			rm -rf /tmp/stylua.zip /tmp/stylua-bin; \
			printf '$(GREEN)[✓]$(RESET) stylua installed\n'; \
		else \
			printf '$(YELLOW)[!]$(RESET) Could not fetch stylua version — install via: cargo install stylua\n'; \
		fi \
	else \
		printf '$(GREEN)[✓]$(RESET) stylua already installed\n'; \
	fi

# ============================================================================
# Shell — shfmt (platform-specific)
# ============================================================================
shell-deps-brew:
	$(call log_step,"Setting up Shell tools...")
	@brew install shfmt || true
	$(call log_info,"Shell tools installed (shfmt)")

shell-deps-apt:
	$(call log_step,"Setting up Shell tools...")
	@mkdir -p "$$HOME/.local/bin"
	@if ! command -v shfmt >/dev/null 2>&1; then \
		if command -v go >/dev/null 2>&1; then \
			go install mvdan.cc/sh/v3/cmd/shfmt@latest; \
		else \
			SHFMT_VERSION=$$(curl -s https://api.github.com/repos/mvdan/sh/releases/latest | grep '"tag_name"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'); \
			SHFMT_ARCH=$$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/'); \
			if [ -n "$$SHFMT_VERSION" ]; then \
				curl -fsSL -o "$$HOME/.local/bin/shfmt" \
					"https://github.com/mvdan/sh/releases/download/v$$SHFMT_VERSION/shfmt_v$${SHFMT_VERSION}_linux_$$SHFMT_ARCH" && \
				chmod +x "$$HOME/.local/bin/shfmt"; \
			fi; \
		fi \
	fi
	$(call log_info,"Shell tools installed (shfmt)")

# ============================================================================
# Nerd Fonts (platform-specific)
# ============================================================================
fonts-brew:
	$(call log_step,"Installing Nerd Fonts...")
	@brew install --cask font-hack-nerd-font 2>/dev/null || true
	$(call log_info,"Nerd Font installed (Hack Nerd Font)")

fonts-apt:
	$(call log_step,"Installing Nerd Fonts...")
	@if command -v fc-list >/dev/null 2>&1 && fc-list 2>/dev/null | grep -qi "Hack.*Nerd"; then \
		printf '$(GREEN)[✓]$(RESET) Hack Nerd Font already installed\n'; \
	else \
		FONT_DIR="$$HOME/.local/share/fonts"; \
		mkdir -p "$$FONT_DIR"; \
		FONT_VERSION=$$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep '"tag_name"' | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+'); \
		if [ -n "$$FONT_VERSION" ]; then \
			curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/$$FONT_VERSION/Hack.zip" -o /tmp/HackNerdFont.zip && \
			unzip -oq /tmp/HackNerdFont.zip -d "$$FONT_DIR" && \
			rm -f /tmp/HackNerdFont.zip && \
			fc-cache -f "$$FONT_DIR" 2>/dev/null || true; \
			printf '$(GREEN)[✓]$(RESET) Hack Nerd Font installed to %s\n' "$$FONT_DIR"; \
		else \
			printf '$(YELLOW)[!]$(RESET) Could not fetch Nerd Font version — download manually from https://www.nerdfonts.com\n'; \
		fi \
	fi

# ============================================================================
# Terminal — platform-specific
# ============================================================================
terminal-macos:
	$(call log_step,"Setting up terminal tools...")
	@brew install starship || true
	@if [ ! -d "$$HOME/.config/kitty" ]; then mkdir -p "$$HOME/.config/kitty"; fi
	@if [ -f kitty.conf ]; then \
		if [ -f "$$HOME/.config/kitty/kitty.conf" ]; then \
			printf '$(YELLOW)[!]$(RESET) kitty.conf already exists — skipping (backup: cp ~/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf.bak)\n'; \
		else \
			ln -sf "$$(pwd)/kitty.conf" "$$HOME/.config/kitty/kitty.conf"; \
			printf '$(GREEN)[✓]$(RESET) Linked kitty.conf\n'; \
		fi \
	fi
	@if [ -f starship.toml ]; then \
		if [ -f "$$HOME/.config/starship.toml" ]; then \
			printf '$(YELLOW)[!]$(RESET) starship.toml already exists — skipping\n'; \
		else \
			ln -sf "$$(pwd)/starship.toml" "$$HOME/.config/starship.toml"; \
			printf '$(GREEN)[✓]$(RESET) Linked starship.toml\n'; \
		fi \
	fi
	$(call log_info,"Terminal tools configured")

terminal-linux:
	$(call log_step,"Setting up terminal tools...")
	@# Install starship
	@if ! command -v starship >/dev/null 2>&1; then \
		curl -fsSL https://starship.rs/install.sh | sh -s -- -y >/dev/null 2>&1; \
	fi
	@# Link kitty.conf
	@if [ ! -d "$$HOME/.config/kitty" ]; then mkdir -p "$$HOME/.config/kitty"; fi
	@if [ -f kitty.conf ]; then \
		if [ -f "$$HOME/.config/kitty/kitty.conf" ]; then \
			printf '$(YELLOW)[!]$(RESET) kitty.conf already exists — skipping (backup: cp ~/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf.bak)\n'; \
		else \
			ln -sf "$$(pwd)/kitty.conf" "$$HOME/.config/kitty/kitty.conf"; \
			printf '$(GREEN)[✓]$(RESET) Linked kitty.conf\n'; \
		fi \
	fi
	@# Link starship.toml
	@if [ -f starship.toml ]; then \
		if [ -f "$$HOME/.config/starship.toml" ]; then \
			printf '$(YELLOW)[!]$(RESET) starship.toml already exists — skipping\n'; \
		else \
			ln -sf "$$(pwd)/starship.toml" "$$HOME/.config/starship.toml"; \
			printf '$(GREEN)[✓]$(RESET) Linked starship.toml\n'; \
		fi \
	fi
	@# Ensure ~/.local/bin is in PATH hint
	@if ! echo "$$PATH" | grep -q "$$HOME/.local/bin"; then \
		printf '$(YELLOW)[!]$(RESET) Add to your shell profile: export PATH="$$HOME/.local/bin:$$PATH"\n'; \
	fi
	$(call log_info,"Terminal tools configured")

# ============================================================================
# Neovim plugins — trigger lazy.nvim install
# ============================================================================
nvim-plugins:
	$(call log_step,"Installing Neovim plugins via lazy.nvim...")
	@nvim --headless '+Lazy! sync' +qa 2>/dev/null || true
	$(call log_step,"Installing Treesitter parsers...")
	@nvim --headless '+TSInstall all' +qa 2>/dev/null || true
	$(call log_info,"Neovim plugins and parsers installed")

# ============================================================================
# Health check
# ============================================================================
check:
	@echo ''
	@printf '$(CYAN)Checking installed tools...$(RESET)\n'
	@echo '─────────────────────────────────────────────'
	@printf '  %-20s ' 'neovim'; command -v nvim >/dev/null 2>&1 && printf '$(GREEN)✓$(RESET) %s\n' "$$(nvim --version | head -1)" || printf '$(RED)✗$(RESET) not found\n'
	@printf '  %-20s ' 'node'; command -v node >/dev/null 2>&1 && printf '$(GREEN)✓$(RESET) %s\n' "$$(node --version)" || printf '$(RED)✗$(RESET) not found\n'
	@printf '  %-20s ' 'python3'; command -v python3 >/dev/null 2>&1 && printf '$(GREEN)✓$(RESET) %s\n' "$$(python3 --version)" || printf '$(RED)✗$(RESET) not found\n'
	@printf '  %-20s ' 'go'; command -v go >/dev/null 2>&1 && printf '$(GREEN)✓$(RESET) %s\n' "$$(go version | cut -d' ' -f3)" || printf '$(YELLOW)○$(RESET) not found (optional)\n'
	@printf '  %-20s ' 'rustup'; command -v rustup >/dev/null 2>&1 && printf '$(GREEN)✓$(RESET) %s\n' "$$(rustup --version 2>/dev/null | head -1)" || printf '$(YELLOW)○$(RESET) not found (optional)\n'
	@printf '  %-20s ' 'ripgrep'; command -v rg >/dev/null 2>&1 && printf '$(GREEN)✓$(RESET) %s\n' "$$(rg --version | head -1)" || printf '$(RED)✗$(RESET) not found\n'
	@printf '  %-20s ' 'fd'; command -v fd >/dev/null 2>&1 && printf '$(GREEN)✓$(RESET) %s\n' "$$(fd --version)" || printf '$(YELLOW)○$(RESET) not found (optional)\n'
	@printf '  %-20s ' 'gopls'; command -v gopls >/dev/null 2>&1 && printf '$(GREEN)✓$(RESET) installed\n' || printf '$(YELLOW)○$(RESET) not found\n'
	@printf '  %-20s ' 'pyright'; command -v pyright >/dev/null 2>&1 && printf '$(GREEN)✓$(RESET) installed\n' || printf '$(YELLOW)○$(RESET) not found\n'
	@printf '  %-20s ' 'lua-language-server'; command -v lua-language-server >/dev/null 2>&1 && printf '$(GREEN)✓$(RESET) installed\n' || printf '$(YELLOW)○$(RESET) not found\n'
	@printf '  %-20s ' 'stylua'; command -v stylua >/dev/null 2>&1 && printf '$(GREEN)✓$(RESET) installed\n' || printf '$(YELLOW)○$(RESET) not found\n'
	@printf '  %-20s ' 'black'; command -v black >/dev/null 2>&1 && printf '$(GREEN)✓$(RESET) installed\n' || printf '$(YELLOW)○$(RESET) not found\n'
	@printf '  %-20s ' 'shfmt'; command -v shfmt >/dev/null 2>&1 && printf '$(GREEN)✓$(RESET) installed\n' || printf '$(YELLOW)○$(RESET) not found\n'
	@printf '  %-20s ' 'starship'; command -v starship >/dev/null 2>&1 && printf '$(GREEN)✓$(RESET) installed\n' || printf '$(YELLOW)○$(RESET) not found\n'
	@echo '─────────────────────────────────────────────'
	@echo ''

# ============================================================================
# Clean — remove generated/cached data
# ============================================================================
clean:
	$(call log_step,"Cleaning Neovim cache...")
	@rm -rf ~/.local/share/nvim/lazy
	@rm -rf ~/.local/state/nvim
	@rm -rf ~/.cache/nvim
	$(call log_info,"Neovim cache cleaned")

# ============================================================================
# Help
# ============================================================================
help:
	@echo ''
	@echo 'Neovim Configuration Installer'
	@echo '═══════════════════════════════'
	@echo ''
	@echo '  make macos        Install everything on macOS (Homebrew)'
	@echo '  make unix         Install everything on Linux (apt/dnf/pacman)'
	@echo '  make check        Verify all tools are installed'
	@echo '  make clean        Remove Neovim cache (plugins will re-download)'
	@echo ''
	@echo 'Individual targets:'
	@echo '  make brew-deps    [macOS] Core CLI tools via Homebrew'
	@echo '  make apt-deps     [Linux] Core CLI tools via apt/dnf/pacman'
	@echo '  make neovim       Verify Neovim version'
	@echo '  make node-deps    Node.js + LSP servers (bashls, jsonls)'
	@echo '  make python-deps  Python tools (pyright, black, ruff, debugpy)'
	@echo '  make go-deps      Go tools (gopls, goimports, dlv)'
	@echo '  make rust-deps    Rust tools (rust-analyzer, rustfmt)'
	@echo '  make lua-deps-brew  [macOS] Lua tools via Homebrew'
	@echo '  make lua-deps-apt   [Linux] Lua tools from GitHub releases'
	@echo '  make shell-deps-brew [macOS] shfmt via Homebrew'
	@echo '  make shell-deps-apt  [Linux] shfmt from GitHub releases'
	@echo '  make fonts-brew   [macOS] Nerd Fonts via Homebrew cask'
	@echo '  make fonts-apt    [Linux] Nerd Fonts from GitHub releases'
	@echo '  make terminal-macos [macOS] Kitty + Starship via Homebrew'
	@echo '  make terminal-linux [Linux] Kitty + Starship via install scripts'
	@echo '  make nvim-plugins Sync plugins via lazy.nvim'
	@echo ''
