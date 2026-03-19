#!/bin/bash
# ============================================
# Profile Bootstrap Script
# Run this once when a new container starts:
#   source /home1/irteam/data-vol1/profile/setup.sh
# ============================================

PROFILE_ROOT="/home1/irteam/data-vol1/profile"
CONDA_ROOT="/home1/irteam/data-vol1/conda"
MARKER="# >>> data-vol1 profile >>>"

echo "[setup] Bootstrapping profile from $PROFILE_ROOT"

# ---- 0. Initialize persistent conda ----
if [ -d "$CONDA_ROOT" ]; then
    eval "$("$CONDA_ROOT/bin/conda" shell.bash hook)"
    echo "[setup] ✓ persistent conda initialized ($CONDA_ROOT)"
else
    echo "[setup] ✗ persistent conda not found at $CONDA_ROOT"
fi

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

# ---- 4. Link condarc ----
if [ -f "$PROFILE_ROOT/condarc" ]; then
    ln -sf "$PROFILE_ROOT/condarc" "$HOME/.condarc"
    echo "[setup] ✓ condarc linked (persistent envs_dirs/pkgs_dirs)"
fi

# ---- 5. Inject bashrc loader into ~/.bashrc ----
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

# ---- 6. Link rclone config ----
RCLONE_CONF_BACKUP="$PROFILE_ROOT/rclone/rclone.conf"
if [ -f "$RCLONE_CONF_BACKUP" ]; then
    mkdir -p "$HOME/.config/rclone"
    if [ ! -f "$HOME/.config/rclone/rclone.conf" ]; then
        cp "$RCLONE_CONF_BACKUP" "$HOME/.config/rclone/rclone.conf"
        echo "[setup] ✓ rclone config restored"
    else
        echo "[setup] ✓ rclone config already present"
    fi
fi

# ---- 7. Restore netrc (wandb, etc.) ----
if [ -f "$PROFILE_ROOT/secrets/netrc" ] && [ ! -f "$HOME/.netrc" ]; then
    cp "$PROFILE_ROOT/secrets/netrc" "$HOME/.netrc"
    chmod 600 "$HOME/.netrc"
    echo "[setup] ✓ netrc restored (wandb credentials)"
elif [ -f "$HOME/.netrc" ]; then
    echo "[setup] ✓ netrc already present"
fi

# ---- 8. Link Claude Code commands ----
if [ -d "$PROFILE_ROOT/.claude/commands" ]; then
    mkdir -p "$HOME/.claude/commands"
    for cmd in "$PROFILE_ROOT"/.claude/commands/*.md; do
        [ -f "$cmd" ] && ln -sf "$cmd" "$HOME/.claude/commands/$(basename "$cmd")"
    done
    echo "[setup] ✓ Claude Code commands linked"
fi

# ---- 9. Install packages ----
if [ -f "$PROFILE_ROOT/install.sh" ]; then
    echo "[setup] Running install.sh..."
    bash "$PROFILE_ROOT/install.sh"
fi

# ---- 10. Load profile into current session ----
for f in "$PROFILE_ROOT"/bashrc.d/*.sh; do
    [ -r "$f" ] && source "$f"
done
unset f

echo ""
echo "[setup] ✅ Profile applied. New shells will auto-load."
echo "[setup] To manually reload: source ~/.bashrc"
