#!/bin/bash
# ============================================
# Package Installer
# Uses persistent conda at /home1/irteam/data-vol1/conda
# Packages persist across container restarts
# ============================================

set -e

CONDA_ROOT="/home1/irteam/data-vol1/conda"
CONDA="$CONDA_ROOT/bin/conda"
PIP="$CONDA_ROOT/bin/pip"

# ---- 1. Conda packages ----
CONDA_PACKAGES=(
    tmux
    htop
    tree
    vim
    openssh
)

echo "[install] Checking conda packages (persistent)..."

for pkg in "${CONDA_PACKAGES[@]}"; do
    if "$CONDA_ROOT/bin/$pkg" --version &>/dev/null 2>&1 || "$CONDA" list "$pkg" 2>/dev/null | grep -q "^$pkg "; then
        echo "  ✓ $pkg (already installed)"
    else
        echo "  ↓ Installing $pkg..."
        "$CONDA" install -y -c conda-forge "$pkg" 2>&1 | tail -1
        echo "  ✓ $pkg (installed)"
    fi
done

# ---- 2. Pip packages ----
PIP_PACKAGES=(
    gpustat
    wandb
)

echo "[install] Checking pip packages (persistent)..."

for pkg in "${PIP_PACKAGES[@]}"; do
    if "$CONDA_ROOT/bin/python" -c "import $pkg" 2>/dev/null || "$CONDA_ROOT/bin/$pkg" --version &>/dev/null 2>&1; then
        echo "  ✓ $pkg (already installed)"
    else
        echo "  ↓ Installing $pkg..."
        "$PIP" install -q "$pkg"
        echo "  ✓ $pkg (installed)"
    fi
done

# ---- 3. rclone (Google Drive + cloud storage) ----
PROFILE_ROOT="/home1/irteam/data-vol1/profile"
RCLONE_BIN="$PROFILE_ROOT/bin/rclone"
RCLONE_CONF_BACKUP="$PROFILE_ROOT/rclone/rclone.conf"

echo "[install] Checking rclone..."
if [ -x "$RCLONE_BIN" ]; then
    echo "  ✓ rclone ($("$RCLONE_BIN" version 2>/dev/null | head -1))"
else
    echo "  ↓ Installing rclone..."
    curl -fsSL -o /tmp/rclone.zip https://downloads.rclone.org/rclone-current-linux-amd64.zip
    unzip -o /tmp/rclone.zip -d /tmp/
    cp /tmp/rclone-*-linux-amd64/rclone "$RCLONE_BIN"
    chmod +x "$RCLONE_BIN"
    rm -rf /tmp/rclone.zip /tmp/rclone-*-linux-amd64
    echo "  ✓ rclone (installed)"
fi

# Restore rclone config from persistent backup
mkdir -p "$HOME/.config/rclone"
if [ -f "$RCLONE_CONF_BACKUP" ] && [ ! -f "$HOME/.config/rclone/rclone.conf" ]; then
    cp "$RCLONE_CONF_BACKUP" "$HOME/.config/rclone/rclone.conf"
    echo "  ✓ rclone config restored from backup"
elif [ -f "$HOME/.config/rclone/rclone.conf" ]; then
    echo "  ✓ rclone config already present"
fi

# ---- 4. Claude Code ----
echo "[install] Checking Claude Code..."
if command -v claude &>/dev/null; then
    echo "  ✓ claude ($(claude --version 2>/dev/null))"
else
    echo "  ↓ Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
    echo "  ✓ claude (installed)"
fi

echo "[install] Done."
