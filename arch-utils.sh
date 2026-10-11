#!/bin/bash

# Colors
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;31m'
NC='\033[0m'

# Root check
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}[-] Run as normal user. Sudo will be called when needed.${NC}"
    exit 1
fi

set -e

echo -e "${BLUE}[+] Running lean Arch installation sequence...${NC}"

# Tier 1: System prerequisites
echo -e "${BLUE}[+] Installing system prerequisites...${NC}"
sudo pacman -Syu --needed base-devel fakeroot git curl wget

# Tier 2: AUR helper (yay-bin)
if ! command -v yay &>/dev/null; then
    echo -e "${BLUE}[+] Building and installing yay-bin...${NC}"
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
    (
        cd "$tmpdir/yay-bin"
        makepkg -si --noconfirm --needed
    )
    rm -rf "$tmpdir"
fi

# Tier 3: Core utilities and archive tools
echo -e "${BLUE}[+] Installing core utilities...${NC}"
sudo pacman -S --needed \
    btop fastfetch \
    tar p7zip unrar unzip zip lzop cpio

# Tier 4: KDE desktop and file management
echo -e "${BLUE}[+] Installing KDE utilities...${NC}"
sudo pacman -S --needed dolphin ark kio-admin

# Tier 5: Multimedia and codecs
echo -e "${BLUE}[+] Installing multimedia tools...${NC}"
sudo pacman -S --needed \
    vlc ffmpeg aom libde265 libheif

# Tier 6: AUR Applications
echo -e "${BLUE}[+] Installing AUR applications...${NC}"
yay -S --needed --noconfirm \
    cool-retro-term signal-desktop spotify \
    notepadqq google-chrome caido-bin

# Tier 7: Brave Origin (Safe execution)
if ! command -v brave &>/dev/null; then
    echo -e "${BLUE}[+] Installing Brave Origin...${NC}"
    brave_installer=$(mktemp)
    curl -fsS https://dl.brave.com/install.sh -o "$brave_installer"
    FLAVOR=origin sh "$brave_installer"
    rm -f "$brave_installer"
fi

echo -e "${GREEN}[SUCCESS] Installation sequence completed.${NC}"
