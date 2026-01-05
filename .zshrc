# Set the directory for where zinit and plugins will be installed
#
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

# Downlaod and install zinit if it is not already installed
if [ ! -d "${ZINIT_HOME}" ]; then
  mkdir -p "$(dirname "${ZINIT_HOME}")"
  git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}"
fi

# Load zinit
source "${ZINIT_HOME}/zinit.zsh"


export STARSHIP_ZLE_DISABLE=1


# Example plugins to install with zinit
#
# starship prompt
zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"

zinit light starship/starship

# syntax highlighting
zinit light zsh-users/zsh-syntax-highlighting

# autosuggestions
zinit light zsh-users/zsh-autosuggestions

# autocompletions
zinit light zsh-users/zsh-completions

# fzf_tab
zinit light Aloxaf/fzf-tab

# Load completions & styling
autoload -U compinit && compinit

zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

#alias finder
zstyle ':omz:plugins:alias-finder' autoload yes # disabled by default
zstyle ':omz:plugins:alias-finder' longer yes # disabled by default
zstyle ':omz:plugins:alias-finder' exact yes # disabled by default
zstyle ':omz:plugins:alias-finder' cheaper yes # disabled by default

### Add-in snippets ###
zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit snippet OMZ::plugins/docker/docker.plugin.zsh
zinit snippet OMZ::plugins/alias-finder/alias-finder.plugin.zsh

# History settings
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=5000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS


# Keybindings
# history search with up/down arrows
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward


### eza ###
# Use eza (a modern replacement for ls) if installed
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons'
  alias ll='eza -la --icons'
fi
  
##### ZOXIDE #####
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
fi

##### DIRENV #####
if command -v direnv >/dev/null; then
  eval "$(direnv hook zsh)"
fi

##### ASDF #####
if [ -f "$HOME/.asdf/asdf.sh" ]; then
  . "$HOME/.asdf/asdf.sh"
fi


pretty() {
  local input
  input="$(cat)"

  if jq -e . >/dev/null 2>&1 <<<"$input"; then
    jq . <<<"$input" | bat -p -l json --style=grid
  else
    bat -p -l python --wrap=auto --style=grid <<<"$input"
  fi
}


### Flink HOME ###
# Set FLINK_HOME if flink is installed
export FLINK_HOME="$(brew --prefix apache-flink)/libexec"

export FLINK1_HOME="$(brew --prefix apache-flink@1)/libexec"
export PATH="/opt/homebrew/opt/apache-flink@1/bin:$PATH"
