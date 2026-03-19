#!/bin/bash
# ============================================
# Environment Variables
# ============================================

# Profile root
export PROFILE_ROOT="/home1/irteam/data-vol1/profile"

# Custom bin
export PATH="$PROFILE_ROOT/bin:$HOME/.local/bin:$PATH"

# History settings
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT="%F %T "

# Editor
export EDITOR=vim
export VISUAL=vim

# Language / Locale
export LANG=en_US.UTF-8
# export LC_ALL=en_US.UTF-8  # uncomment if locale is installed

# CUDA (uncomment and adjust as needed)
# export CUDA_HOME=/usr/local/cuda
# export PATH=$CUDA_HOME/bin:$PATH
# export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
