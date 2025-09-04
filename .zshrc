
# Open finder in current directory
finder(){ 
    open . 
}
zle -N finder
bindkey '^f' finder

# PATH exports
export ZSH="$HOME/.oh-my-zsh"

# Aliases
alias vim=nvim
alias vi="nvim"
alias cenv="python3 -m venv .venv"
alias venv="source .venv/bin/activate"

ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

