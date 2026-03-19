#!/bin/bash
# ============================================
# Shell Functions
# ============================================

# mkdir + cd
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# quick find file
ff() {
    find . -name "*$1*" 2>/dev/null
}

# GPU memory usage summary
gpumem() {
    nvidia-smi --query-gpu=index,memory.used,memory.total --format=csv,noheader,nounits | \
    awk -F', ' '{printf "GPU %s: %s / %s MiB (%.1f%%)\n", $1, $2, $3, ($2/$3)*100}'
}

# quick extract
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# port check
port() {
    ss -tlnp 2>/dev/null | grep ":$1 " || echo "Port $1 is not in use"
}
