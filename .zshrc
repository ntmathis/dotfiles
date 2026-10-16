# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"

plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
  history-substring-search
)

source $ZSH/oh-my-zsh.sh

# path
# PATH setup: Homebrew, ~/.local/bin, nvm, bun.

# Homebrew (Apple Silicon first, then Intel).
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="$PATH:$HOME/.local/bin"

# NVM loads slowly; keep it here so anything later can call `nvm use`.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# aliases
# Modern CLI aliases and interactive shell tweaks.

alias reload='source ~/.zshrc'
alias '/clear'='clear'
alias cat='bat --paging never -p'
alias neofetch='fastfetch -c neofetch.jsonc'
alias helix='hx'

alias ls='lsd --group-dirs first'
alias l='lsd -l --group-dirs first'
alias la='lsd -a --group-dirs first'
alias lla='lsd -la --group-dirs first'
alias lt='lsd --tree --group-dirs first'

alias img='chafa --scale 1.0'
alias img-ansi='chafa -f symbols --scale 1.0'
alias {img-ansi,chafa-ansi,chafa-ios,img-ios}='chafa -f symbols --scale 1.0'

alias lg='lazygit'
alias list_ports='lsof -nP +c 15 | grep LISTEN'

# fzf setup:
source <(fzf --zsh)

# keys & history
# fish-style: Up/Down search history for what you've typed (substring); Right accepts the suggestion
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
bindkey '^[[A' history-substring-search-up;   bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down; bindkey '^[OB' history-substring-search-down

# Force steady block cursor (overrides oh-my-zsh and Ghostty shell integration).
_fix_cursor() { echo -ne '\e[2 q'; }
precmd_functions+=(_fix_cursor)
autoload -Uz add-zle-hook-widget
add-zle-hook-widget line-init _fix_cursor

# git
# Add a git checkout fallback between main and master: when the requested
# default branch does not exist locally, try the other common name.
git() {
  if [[ $1 == "checkout" && $# -eq 2 && ( $2 == "main" || $2 == "master" ) ]]; then
    # Attempt checkout of the requested branch, hiding errors for now
    if command git checkout "$2" 2>/dev/null; then
      return 0
    else
      # Checkout failed - see if the branch actually exists
      if command git rev-parse --verify --quiet "$2" >/dev/null 2>&1; then
        # Branch exists, so failure was due to something else (e.g., local changes)
        # Re-run checkout without suppressing output to show the real error
        command git checkout "$2"
        return $?
      else
        # Branch doesn't exist - try the other common default branch
        local other
        if [[ $2 == "main" ]]; then
          other="master"
        else
          other="main"
        fi
        echo "Branch '$2' not found, trying '$other'..."
        command git checkout "$other"
        return $?
      fi
    fi
  else
    # For any other git command, just pass through
    command git "$@"
  fi
}

# tmux
# tmux helpers.
# https://tmux.info/docs/advanced

# tmuxa/tmux~a - attach to last used session (no arg), or a named session (with arg).
tmuxa() {
  if [ -n "$1" ]; then
    tmux attach-session -t "$1"
  else
    local last_session
    last_session=$(tmux list-sessions -F "#{session_created} #{session_name}" 2>/dev/null | sort -rn | head -1 | cut -d" " -f2)
    if [ -n "$last_session" ]; then
      tmux attach-session -t "$last_session"
    else
      tmux new-session -s src
    fi
  fi
}
alias tmux~a=tmuxa

# tmuxn/tmuxs - create a new tmux session with a given name and attach.
tmuxn() {
  if [ -n "$1" ]; then
    tmux new-session -s "$1"
  else
    tmux new-session
  fi
}
alias tmuxs=tmuxn

# plans (Rust CLI: ~/.cargo/bin/plans)
alias plansl='plans --list'
alias plansa='plans --status all'

# Powerlevel10k.
source $ZSH_CUSTOM/themes/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
RPROMPT=''

# Machine-local overrides and secrets (never exported).
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
