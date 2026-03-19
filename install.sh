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

# ---- 3. Claude Code ----
echo "[install] Checking Claude Code..."
if command -v claude &>/dev/null; then
    echo "  ✓ claude ($(claude --version 2>/dev/null))"
else
    echo "  ↓ Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
    echo "  ✓ claude (installed)"
fi

echo "[install] Done."
