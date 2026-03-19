#!/bin/bash
# ============================================
# Aliases
# ============================================

# ls
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# git
alias gs='git status'
alias gl='git log --oneline --graph -20'
alias gd='git diff'
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gp='git push'
alias gpull='git pull'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias data='cd /home1/irteam/data-vol1'

# safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# nvidia
alias nv='nvidia-smi'
alias nvw='watch -n 1 nvidia-smi'
alias watch-gpu='watch -d -n 0.5 nvidia-smi'

# tmux
alias tmux-kill='tmux kill-session -t '
alias tmux-gpu='tmux at -t GPU'
alias tmux-jupyter='tmux at -t jupyter'

# python
alias py='python'
alias ipy='ipython'
alias jl='jupyter lab'

# conda
alias ca='conda activate'
alias cda='conda deactivate'
alias cel='conda env list'
