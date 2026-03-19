#!/bin/bash
# ============================================
# Profile Bootstrap Script
# Run this once when a new container starts:
#   source /home1/irteam/data-vol1/profile/setup.sh
# ============================================

PROFILE_ROOT="/home1/irteam/data-vol1/profile"
MARKER="# >>> data-vol1 profile >>>"

echo "[setup] Bootstrapping profile from $PROFILE_ROOT"

# ---- 1. Link gitconfig ----
if [ -f "$PROFILE_ROOT/gitconfig" ]; then
    ln -sf "$PROFILE_ROOT/gitconfig" "$HOME/.gitconfig"
    echo "[setup] ✓ gitconfig linked"
fi

# ---- 2. Link tmux.conf ----
if [ -f "$PROFILE_ROOT/tmux.conf" ]; then
    ln -sf "$PROFILE_ROOT/tmux.conf" "$HOME/.tmux.conf"
    echo "[setup] ✓ tmux.conf linked"
fi

# ---- 3. Link vimrc ----
if [ -f "$PROFILE_ROOT/vimrc" ]; then
    ln -sf "$PROFILE_ROOT/vimrc" "$HOME/.vimrc"
    echo "[setup] ✓ vimrc linked"
fi

# ---- 4. Inject bashrc loader into ~/.bashrc ----
if ! grep -q "$MARKER" "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" << 'BASHRC_BLOCK'

# >>> data-vol1 profile >>>
if [ -d "/home1/irteam/data-vol1/profile/bashrc.d" ]; then
    for f in /home1/irteam/data-vol1/profile/bashrc.d/*.sh; do
        [ -r "$f" ] && source "$f"
    done
    unset f
fi
# <<< data-vol1 profile <<<
BASHRC_BLOCK
    echo "[setup] ✓ bashrc loader injected"
else
    echo "[setup] ✓ bashrc loader already present"
fi

# ---- 5. Install packages ----
if [ -f "$PROFILE_ROOT/install.sh" ]; then
    echo "[setup] Running install.sh..."
    bash "$PROFILE_ROOT/install.sh"
fi

# ---- 6. Load profile into current session ----
for f in "$PROFILE_ROOT"/bashrc.d/*.sh; do
    [ -r "$f" ] && source "$f"
done
unset f

echo ""
echo "[setup] ✅ Profile applied. New shells will auto-load."
echo "[setup] To manually reload: source ~/.bashrc"
