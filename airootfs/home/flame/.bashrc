kitty -e bash -c "
  swww img /home/flame/flameos-wallpaper.png;
  nmtui;
  echo 'Exited nmtui, cloning repo...';
  git clone https://github.com/flame-os/flameos-installer;
  cd flameos-installer || exit 1;
  sudo chmod +x install.sh;
  sudo ./install.sh
"

