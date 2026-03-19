#!/bin/bash
# ============================================
# Package Installer
# Installs packages via conda if not present
# ============================================

set -e

PACKAGES=(
    tmux
    htop
    tree
)

echo "[install] Checking packages..."

for pkg in "${PACKAGES[@]}"; do
    if command -v "$pkg" &>/dev/null; then
        echo "  ✓ $pkg (already installed)"
    else
        echo "  ↓ Installing $pkg..."
        conda install -y -c conda-forge "$pkg" 2>&1 | tail -1
        echo "  ✓ $pkg (installed)"
    fi
done

echo "[install] Done."
