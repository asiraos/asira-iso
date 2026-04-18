#!/bin/bash
set -e

echo "[*] Initializing pacman keyring..."
pacman-key --init
pacman-key --populate archlinux

echo "[*] Updating keyring..."
pacman -Sy --noconfirm archlinux-keyring

echo "=== Customization complete ==="
