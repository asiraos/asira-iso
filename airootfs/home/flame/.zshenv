kitty -e bash -c "
  # Check if 1.1.1.1 is reachable
  if ping -c 1 1.1.1.1 &>/dev/null; then
    echo '1.1.1.1 is reachable, skipping nmtui';
  else
    echo '1.1.1.1 is not reachable, running nmtui';
    nmtui;
  fi;

  # Continue with the rest of the script
  echo 'Exited nmtui, cloning repo...';
  git clone https://github.com/flame-os/flameos-installer;
  cd flameos-installer || exit 1;
  sudo chmod +x install.sh;
  sudo ./install.sh
"

