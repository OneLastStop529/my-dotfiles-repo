# zinit
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# prompt/plugins
export STARSHIP_ZLE_DISABLE=1
zinit ice as"command" from"gh-r" \
  atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
  atpull"%atclone" src"init.zsh"
zinit light starship/starship
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab

# oh-my-zsh snippets
zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit snippet OMZ::plugins/docker/docker.plugin.zsh
zinit snippet OMZ::plugins/alias-finder/alias-finder.plugin.zsh

# completions
if [ -d "$HOME/.zsh/completions" ]; then
  fpath=("$HOME/.zsh/completions" $fpath)
fi
autoload -U compinit && compinit -d "$HOME/.zsh/.zcompdump"
for completion_script in "$HOME"/.zsh/completions/*.zsh(N); do
  source "$completion_script"
done

zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':omz:plugins:alias-finder' autoload yes
zstyle ':omz:plugins:alias-finder' longer yes
zstyle ':omz:plugins:alias-finder' exact yes
zstyle ':omz:plugins:alias-finder' cheaper yes

# history
HISTSIZE=5000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=5000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS

# keybindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# tools/hooks
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons'
  alias ll='eza -la --icons'
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
if [ -f "$HOME/.asdf/asdf.sh" ]; then
  . "$HOME/.asdf/asdf.sh"
fi

# utility functions
pretty() {
  local input
  if (( $# > 0 )); then
    input="$*"
  elif [[ ! -t 0 ]]; then
    input="$(command cat)"
  else
    echo "Usage: pretty '<json-or-text>' or cat file | pretty" >&2
    return 1
  fi

  if command -v jq >/dev/null 2>&1 && jq -e . >/dev/null 2>&1 <<<"$input"; then
    if command -v bat >/dev/null 2>&1; then
      jq --sort-keys --indent 2 . <<<"$input" | bat -p -l json --style=plain --paging=never
    else
      jq --sort-keys --indent 2 . <<<"$input"
    fi
  else
    if command -v bat >/dev/null 2>&1; then
      bat -p -l python --wrap=auto --style=grid <<<"$input"
    else
      printf '%s\n' "$input"
    fi
  fi
}

cat() {
  if (( $# == 0 )) && [[ -t 0 ]]; then
    command cat
    return
  fi

  if command -v bat >/dev/null 2>&1; then
    bat --paging=never "$@"
  else
    command cat "$@"
  fi
}

# PATH
export BUN_INSTALL="$HOME/.bun"
typeset -U path PATH
path=(
  "$HOME/.openclaw/bin"
  "/opt/homebrew/opt/postgresql@16/bin"
  "$BUN_INSTALL/bin"
  "$HOME/.cargo/bin"
  "$HOME/.nvm"
  $path
)
source $(brew --prefix nvm)/nvm.sh

# OpenClaw Completion
source "/Users/yizehu/.openclaw/completions/openclaw.zsh"
