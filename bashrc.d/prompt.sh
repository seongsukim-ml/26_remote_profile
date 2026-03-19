#!/bin/bash
# ============================================
# Prompt (PS1) Configuration
# ============================================

# Colors
_RED='\[\033[0;31m\]'
_GREEN='\[\033[0;32m\]'
_YELLOW='\[\033[0;33m\]'
_BLUE='\[\033[0;34m\]'
_PURPLE='\[\033[0;35m\]'
_CYAN='\[\033[0;36m\]'
_WHITE='\[\033[0;37m\]'
_BOLD='\[\033[1m\]'
_RESET='\[\033[0m\]'

# Git branch in prompt
__git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null)
    if [ -n "$branch" ]; then
        echo " ($branch)"
    fi
}

# Conda env in prompt
__conda_env() {
    if [ -n "$CONDA_DEFAULT_ENV" ] && [ "$CONDA_DEFAULT_ENV" != "base" ]; then
        echo "($CONDA_DEFAULT_ENV) "
    fi
}

export PROMPT_COMMAND='__PS1_CONDA=$(__conda_env); __PS1_GIT=$(__git_branch)'

PS1='${__PS1_CONDA}'"${_BOLD}${_GREEN}\u${_RESET}:${_BOLD}${_BLUE}\w${_YELLOW}"'${__PS1_GIT}'"${_RESET}\$ "
