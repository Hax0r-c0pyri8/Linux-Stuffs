#!/bin/bash

# Colors
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;31m'
NC='\033[0m'

if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}[-] Run as normal user. Sudo will be called when needed.${NC}"
    exit 1
fi

echo -e "${BLUE}[+] Running lean install sequence...${NC}"

# Core utilities
sudo pacman -Syu --needed --noconfirm git curl wget btop fastfetch cool-retro-term kio-admin ark p7zip unrar unzip zip tar lzop cpio vlc ffmpeg aom libde265 libheif steam

# Yay AUR helper
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd - && rm -rf /tmp/yay-bin
fi

# AUR & Official script stack
yay -S --needed --noconfirm signal-desktop spotify notepadqq google-chrome caido-bin

if ! command -v brave &> /dev/null; then
    curl -fsS https://dl.brave.com/install.sh | FLAVOR=origin sh
fi

# Verification
echo -e "${BLUE}[+] Verifying installation stack...${NC}"
FAILED=()
for pkg in git curl wget btop fastfetch cool-retro-term kio-admin ark p7zip unrar unzip zip tar lzop cpio vlc steam signal-desktop spotify notepadqq google-chrome caido-bin; do
    base=$(echo "$pkg" | sed 's/-bin//')
    if ! pacman -Q "$pkg" &> /dev/null && ! pacman -Q "$base" &> /dev/null && ! command -v "$pkg" &> /dev/null; then
        FAILED+=("$pkg")
    fi
done

if [ ${#FAILED[@]} -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS] All systems operational.${NC}"
else
    echo -e "${RED}[WARNING] Missing: ${FAILED[*]}${NC}"
fi

# Scrub history traces
history -c; history -w; rm -f ~/.bash_history ~/.zsh_history
unset HISTFILE
