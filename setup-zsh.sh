#!/bin/bash
# =============================================================================
# ZSH SETUP SCRIPT
# Installs ZSH, Oh My Zsh, plugins, themes and sets as default
# =============================================================================
set -e

echo "========================================="
echo "  ZSH SETUP - Complete Installation"
echo "========================================="

# ---- 1. Check/Install ZSH ----
echo "[1/6] Checking ZSH installation..."
if ! command -v zsh &> /dev/null; then
    echo "ZSH not found. Installing..."
    echo "NOTE: This requires sudo. If you don't have sudo, install ZSH first."
    sudo apt update
    sudo apt install -y zsh
else
    echo "✓ ZSH already installed: $(zsh --version)"
fi

# ---- 2. Install Oh My Zsh ----
echo "[2/6] Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✓ Oh My Zsh installed"
else
    echo "✓ Oh My Zsh already installed"
fi

# ---- 3. Install ZSH Plugins ----
echo "[3/6] Installing ZSH plugins..."
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

plugins=(
    "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
    "zsh-completions:https://github.com/zsh-users/zsh-completions"
    "zsh-history-substring-search:https://github.com/zsh-users/zsh-history-substring-search"
    "you-should-use:https://github.com/MichaelAquilina/zsh-you-should-use"
)

for plugin in "${plugins[@]}"; do
    IFS=':' read -r name url <<< "$plugin"
    if [ ! -d "${ZSH_CUSTOM}/plugins/${name}" ]; then
        echo "  Installing ${name}..."
        git clone --depth=1 "$url" "${ZSH_CUSTOM}/plugins/${name}" 2>/dev/null || true
    else
        echo "  ✓ ${name} already installed"
    fi
done

# ---- 4. Install Powerlevel10k Theme ----
echo "[4/6] Installing Powerlevel10k theme..."
if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k
    echo "✓ Powerlevel10k installed"
else
    echo "✓ Powerlevel10k already installed"
fi

# ---- 5. Restore ZSH Config ----
echo "[5/6] Restoring ZSH configuration..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "$SCRIPT_DIR/zsh" ]; then
    cp "$SCRIPT_DIR/zsh/.zshrc" ~/.zshrc
    cp "$SCRIPT_DIR/zsh/.p10k.zsh" ~/.p10k.zsh 2>/dev/null || true
    cp "$SCRIPT_DIR/zsh/.zshenv" ~/.zshenv 2>/dev/null || true
    cp "$SCRIPT_DIR/zsh/.zprofile" ~/.zprofile 2>/dev/null || true
    echo "✓ ZSH configs restored"
else
    echo "⚠ ZSH config directory not found in backup"
fi

# Restore ZSH history
if [ -f "$SCRIPT_DIR/.zsh_history" ]; then
    cp "$SCRIPT_DIR/.zsh_history" ~/.zsh_history
    echo "✓ ZSH history restored"
elif [ -f "$HOME/Downloads/.zsh_history" ]; then
    cp "$HOME/Downloads/.zsh_history" ~/.zsh_history
    echo "✓ ZSH history restored from Downloads"
fi

# ---- 6. Set ZSH as Default Shell ----
echo "[6/6] Setting ZSH as default shell..."
ZSH_PATH=$(which zsh)
CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)

if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    echo "Changing default shell from $CURRENT_SHELL to $ZSH_PATH"
    chsh -s "$ZSH_PATH"
    echo "✓ ZSH set as default shell"
    echo ""
    echo "NOTE: You need to log out and log back in for this to take effect."
    echo "      Or run: exec zsh"
else
    echo "✓ ZSH is already your default shell"
fi

echo ""
echo "========================================="
echo "  ZSH SETUP COMPLETE!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Run: exec zsh  (or logout and login)"
echo "  2. Run: p10k configure  (to setup Powerlevel10k theme)"
echo "  3. Restart your terminal"
echo ""
echo "Installed:"
echo "  ✓ ZSH: $(zsh --version)"
echo "  ✓ Oh My Zsh"
echo "  ✓ Plugins: autosuggestions, syntax-highlighting, completions, history-substring-search, you-should-use"
echo "  ✓ Theme: Powerlevel10k"
echo "  ✓ Default shell: ZSH"
echo ""
