#!/bin/bash

# Add GPG keys during ISO build

 curl -sSL https://asiraos.github.io/core/asiraos-core.pubkey.asc | sudo pacman-key --add -
