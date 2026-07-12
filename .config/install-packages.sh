#!/usr/bin/env bash
set -euo pipefail

# Arch Linux package installer
# Requires: yay (AUR helper)

if ! command -v yay &>/dev/null; then
  echo "ERROR: yay not found. Install yay first."
  echo "  git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si"
  exit 1
fi

PACKAGES=(
  # Fonts
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  ttf-jetbrains-mono

  # Bluetooth
  bluez
  bluez-utils

  # Media/Audio
  pipewire
  pipewire-alsa
  pipewire-pulse
  pipewire-jack
  wireplumber
  easyeffects
  gst-plugin-pipewire
  calf
  lsp-plugins
  zam-plugins-lv2
  mda.lv2
  playerctl
  mpv
  brightnessctl

  # Screenshot
  grim
  slurp
  satty

  # GUI Apps
  ghostty
  onlyoffice-bin
  spotify
  zennotes
  firefox

  # Hyprland
  hypridle
  hyprlock
  hyprpaper
  waybar

  # Terminal Essentials
  yazi
  7zip
  unzip
  fish
  eza
  fzf
  jq
  lazygit
  neovim
  ripgrep
  starship
  tmux
  zoxide

  # AI
  pi-coding-agent

  # Code version manager
  mise

  # Misc
  power-profiles-daemon
  tree-sitter-cli
  matugen-bin
  swaync
  trash-cli
  openssh
)

echo "Installing ${#PACKAGES[@]} packages..."
yay -S --needed --noconfirm "${PACKAGES[@]}"

echo "Done."
