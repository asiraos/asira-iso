#!/bin/bash
set -e

echo "[*] Initializing pacman keyring..."
pacman-key --init
pacman-key --populate archlinux

echo "[*] Adding AsiraOS core repository key..."
curl -sSL https://asiraos.github.io/core/asiraos-core.pubkey.asc | pacman-key --add -
pacman-key --lsign-key DD90A9CDD96977DDD9CEA9491C4AEDE69936E27C

echo "[*] Refreshing pacman keys..."
pacman-key --refresh-keys

echo "=== Customization complete ==="
