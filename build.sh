mkdir -p {out,work}
curl -sSL https://asiraos.github.io/core/asiraos-core.pubkey.asc | sudo pacman-key --add -
sudo mkarchiso -v -w work -o out .
