# ============================================
# Performance-optimized Zsh Configuration
# Using Starship + Zinit (No Oh My Zsh)
# ============================================

# PATH setup
export PATH="$HOME/.local/bin:/Users/bytedance/flutter/flutter/bin:/opt/homebrew/bin:/opt/homebrew/opt/mysql-client/bin:$HOME/go/bin:$PATH"

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
export HISTTIMEFORMAT="%d/%m/%y %T "

# Basic zsh options
setopt AUTO_CD
setopt CORRECT
setopt INTERACTIVE_COMMENTS

# Enable colors for ls (macOS)
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Aliases
alias vim=nvim
alias ls='ls -G'

# g shell setup
[ -s "${HOME}/.g/env" ] && \. "${HOME}/.g/env"
unalias g 2>/dev/null

# ============================================
# Zinit Plugin Manager
# ============================================

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Defer compinit to speed up shell startup
zinit ice wait lucid atinit"
  autoload -Uz compinit
  if [[ -n \${HOME}/.cache/.zcompdump(#qN.mh+24) ]]; then
    compinit -d \"\${HOME}/.cache/.zcompdump\"
  else
    compinit -C -d \"\${HOME}/.cache/.zcompdump\"
  fi
"
zinit light zdharma-continuum/null

# Load plugins with turbo mode (deferred/lazy loading)
zinit ice wait lucid
zinit light zsh-users/zsh-completions

zinit ice wait lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

# Syntax highlighting (optional, uncomment if you want it)
# zinit ice wait lucid
# zinit light zsh-users/zsh-syntax-highlighting

### End of Zinit's installer chunk

# ============================================
# Completion Configuration
# ============================================

# Enable completion system options
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LSCOLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true

# Fuzzy matching of completions for when you mistype them
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Dart CLI completion
[[ -f /Users/bytedance/.dart-cli-completion/zsh-config.zsh ]] && . /Users/bytedance/.dart-cli-completion/zsh-config.zsh || true

# This speeds up pasting with autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# Custom keybindings
bindkey '^L' autosuggest-accept

# ============================================
# Starship Prompt
# ============================================

eval "$(starship init zsh)"
