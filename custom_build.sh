#!/bin/bash

airootfs="airootfs/etc"

# Ensure directory structure and copy grub config
mkdir -p "$airootfs/default"
cp -f "/etc/default/grub" "$airootfs/default/"

# os-release
cp -f "/usr/lib/os-release" "$airootfs/"
sed -i 's/NAME=.*/NAME="FlameOS Linux"/' "$airootfs/os-release"

# wheel group
mkdir -p "$airootfs/sudoers.d"
echo "%wheel ALL=(ALL:ALL) ALL" > "$airootfs/sudoers.d/g_wheel"

# Symbolic Links
## NetworkManager
mkdir -p "$airootfs/systemd/system/multi-user.target.wants"
ln -sf "/usr/lib/systemd/system/NetworkManager.service" "$airootfs/systemd/system/multi-user.target.wants/NetworkManager.service"

mkdir -p "$airootfs/systemd/system/network-online.target.wants"
ln -sf "/usr/lib/systemd/system/NetworkManager-wait-online.service" "$airootfs/systemd/system/network-online.target.wants/NetworkManager-wait-online.service"
ln -sf "/usr/lib/systemd/system/NetworkManager-dispatcher.service" "$airootfs/systemd/system/dbus-org.freedesktop.dispatcher.service"

sed -i 's/Arch Linux/FlameOS Linux/g' syslinux/*.cfg


## Bluetooth
ln -sf "/usr/lib/systemd/system/bluetooth.service" "$airootfs/systemd/system/network-online.target.wants/bluetooth.service"

## Graphical target
ln -sf "/usr/lib/systemd/system/graphical.target" "$airootfs/systemd/system/default.target"

## SDDM
ln -sf "/usr/lib/systemd/system/sddm.service" "$airootfs/systemd/system/display-manager.service"

# SDDM conf
mkdir -p "$airootfs/sddm.conf.d"
sed -n '1,35p' /usr/lib/sddm/sddm.conf.d/default.conf > "$airootfs/sddm.conf"
sed -n '38,137p' /usr/lib/sddm/sddm.conf.d/default.conf > "$airootfs/sddm.conf.d/kde_settings.conf"

# Desktop Environment
if grep -q "^Session=" "$airootfs/sddm.conf"; then
    sed -i 's/^Session=.*/Session=xfce.desktop/' "$airootfs/sddm.conf"
else
    echo "Session=xfce.desktop" >> "$airootfs/sddm.conf"
fi
# For Kde
# if grep -q "^Session=" "$airootfs/sddm.conf"; then
#     sed -i 's/^Session=.*/Session=plasma.desktop/' "$airootfs/sddm.conf"
# else
#     echo "Session=plasma.desktop" >> "$airootfs/sddm.conf"
# fi


# Display Server
if grep -q "^DisplayServer=" "$airootfs/sddm.conf"; then
    sed -i 's/^DisplayServer=.*/DisplayServer=wayland/' "$airootfs/sddm.conf"
else
    echo "DisplayServer=wayland" >> "$airootfs/sddm.conf"
fi

# Numlock
if grep -q "^Numlock=" "$airootfs/sddm.conf"; then
    sed -i 's/^Numlock=.*/Numlock=on/' "$airootfs/sddm.conf"
else
    echo "Numlock=on" >> "$airootfs/sddm.conf"
fi

# User
user="flame"
if grep -q "^User=" "$airootfs/sddm.conf"; then
    sed -i "s/^User=.*/User=$user/" "$airootfs/sddm.conf"
else
    echo "User=$user" >> "$airootfs/sddm.conf"
fi

# Hostname
echo "flameos" > "$airootfs/hostname"

# Adding the new user to passwd
if grep -q "^$user:" "$airootfs/passwd" 2> /dev/null; then
    sed -i "s|^$user:.*|$user:x:1000:1000::/home/$user:/usr/bin/bash|" "$airootfs/passwd"
    echo -e "\nUser entry replaced."
else
    sed -i "1 a\\$user:x:1000:1000::/home/$user:/usr/bin/bash" "$airootfs/passwd"
    echo -e "\nUser entry added."
fi

# Password 
hash_pd=$(openssl passwd -6 "flame") 

if grep -q "^$user:" "$airootfs/shadow" 2> /dev/null; then 
    sed -i "s|^$user:.*|$user:$hash_pd:14871::::::|" "$airootfs/shadow"
    echo -e "\nPassword entry replaced."
else
    sed -i "1 a\\$user:$hash_pd:14871::::::" "$airootfs/shadow"
    echo -e "\nPassword entry added."
fi

# passwordless sudo
mkdir -p "$airootfs/sudoers.d"
echo "$user ALL=(ALL) NOPASSWD: ALL" > "$airootfs/sudoers.d/00-$user-nopasswd"
echo -e "\nPassword Less entry added."


# Group 
cat > "$airootfs/group" <<EOF
root:x:0:root
adm:x:4:$user
wheel:x:10:$user
uucp:x:14:$user
users:x:100:$user
$user:x:1000:$user
EOF

# gshadow
cat > "$airootfs/gshadow" <<EOF
root:!*:root
$user:!*:
EOF

# Grub cfg
grubcfg="grub/grub.cfg"
if [ -f "$grubcfg" ]; then
    sed -i 's/default=archlinux/default=flameos/' "$grubcfg"
    sed -i 's/timeout=15/timeout=10/' "$grubcfg"
    sed -i 's/menuentry "Arch/menuentry "FlameOS/' "$grubcfg"

    if ! grep -q 'archisosearchuuid=%ARCHISO_UUID% cow_spacesize=10G copytoram=n' "$grubcfg" 2> /dev/null; then
        sed -i 's/archisosearchuuid=%ARCHISO_UUID%/archisosearchuuid=%ARCHISO_UUID% cow_spacesize=10G copytoram=n/' "$grubcfg"
    fi

    if ! grep -q '#play' "$grubcfg" 2> /dev/null; then
        sed -i 's/play/#play/' "$grubcfg"
    fi
fi

# entries
efiloader="efiboot/loader"
sed -i 's/Arch/FlameOS/g' "$efiloader/entries/01-archiso-x86_64-linux.conf"
sed -i 's/Arch/FlameOS/g' "$efiloader/entries/02-archiso-x86_64-speech-linux.conf"
#Loader
sed -i 's/timeout 15/timeout 10/' "$efiloader/loader.conf"
sed -i 's/beep on/beep off/' "$efiloader/loader.conf"
