check_internet() {
    ping -c 1 -W 1 8.8.8.8 &> /dev/null
}

if check_internet; then
    echo "󰖩 Internet: Connected"
else
    echo "󰖪 Internet: Offline"
    nmtui
fi

sudo pacman -Sy asira-installer --noconfirm 
asira-installer
