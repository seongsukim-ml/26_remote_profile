#!/bin/bash
# ============================================
# Package Installer
# Installs packages via conda, pip, and other methods
# ============================================

set -e

# ---- 1. Conda packages ----
CONDA_PACKAGES=(
    tmux
    htop
    tree
    vim
)

echo "[install] Checking conda packages..."

for pkg in "${CONDA_PACKAGES[@]}"; do
    if command -v "$pkg" &>/dev/null; then
        echo "  ✓ $pkg (already installed)"
    else
        echo "  ↓ Installing $pkg..."
        conda install -y -c conda-forge "$pkg" 2>&1 | tail -1
        echo "  ✓ $pkg (installed)"
    fi
done

# ---- 2. Pip packages ----
PIP_PACKAGES=(
    gpustat
    wandb
)

echo "[install] Checking pip packages..."

for pkg in "${PIP_PACKAGES[@]}"; do
    if python -c "import $pkg" 2>/dev/null || command -v "$pkg" &>/dev/null; then
        echo "  ✓ $pkg (already installed)"
    else
        echo "  ↓ Installing $pkg..."
        pip install -q "$pkg"
        echo "  ✓ $pkg (installed)"
    fi
done

# ---- 3. Google Drive (gdrive) ----
PROFILE_ROOT="/home1/irteam/data-vol1/profile"
echo "[install] Checking gdrive..."
if command -v gdrive &>/dev/null; then
    echo "  ✓ gdrive ($(gdrive version 2>/dev/null | head -1))"
else
    echo "  ↓ Installing gdrive..."
    curl -fsSL -o /tmp/gdrive.tar.gz https://github.com/glotlabs/gdrive/releases/download/3.9.1/gdrive_linux-x64.tar.gz
    tar -xzf /tmp/gdrive.tar.gz -C "$PROFILE_ROOT/bin/" gdrive
    chmod +x "$PROFILE_ROOT/bin/gdrive"
    rm -f /tmp/gdrive.tar.gz
    echo "  ✓ gdrive (installed)"
fi

# Restore gdrive account if not already imported
GDRIVE_EXPORT="$PROFILE_ROOT/gdrive/gdrive_export.tar"
if [ -f "$GDRIVE_EXPORT" ]; then
    if "$PROFILE_ROOT/bin/gdrive" account list 2>/dev/null | grep -q '@'; then
        echo "  ✓ gdrive account already imported"
    else
        "$PROFILE_ROOT/bin/gdrive" account import "$GDRIVE_EXPORT"
        echo "  ✓ gdrive account imported"
    fi
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
