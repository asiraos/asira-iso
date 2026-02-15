check_internet() {
    ping -c 1 -W 1 8.8.8.8 &> /dev/null
}

if check_internet; then
    echo "󰖩 Internet: Connected"
else
    echo "󰖪 Internet: Offline"
    nmtui
fi

# Install if missing (safe way, no -Sy)
if ! command -v asira-installer &> /dev/null; then
    sudo pacman -S --noconfirm asira-installer
fi

# Force restart instantly if closed
while true; do
    asira-installer
done

