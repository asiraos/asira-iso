#!/usr/bin/env bash
set -euo pipefail

airootfs="airootfs/etc"

# Ensure directory structure and copy grub config
mkdir -p "$airootfs/default"
if [ -f "/etc/default/grub" ]; then
    cp -f "/etc/default/grub" "$airootfs/default/"
fi

# os-release
if [ -f "/usr/lib/os-release" ]; then
    cp -f "/usr/lib/os-release" "$airootfs/"
    # change only NAME field
    sed -i 's/^NAME=.*/NAME="FlameOS Linux"/' "$airootfs/os-release"
fi

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

# Syslinux branding: change only menu labels (don't touch placeholders or options)
if compgen -G "syslinux/*.cfg" >/dev/null; then
    for f in syslinux/*.cfg; do
        # change common visible 'Arch Linux' menu labels safely
        sed -i '/^[[:space:]]*MENU LABEL/ s/Arch Linux/FlameOS Linux/g' "$f" || true
        sed -i '/^[[:space:]]*label[[:space:]]/ s/Arch Linux/FlameOS Linux/g' "$f" || true
        sed -i '/^[[:space:]]*DEFAULT/ s/Arch/FlameOS/g' "$f" || true
    done
fi


## Bluetooth
ln -sf "/usr/lib/systemd/system/bluetooth.service" "$airootfs/systemd/system/network-online.target.wants/bluetooth.service"

## Graphical target
ln -sf "/usr/lib/systemd/system/graphical.target" "$airootfs/systemd/system/default.target"

## SDDM
ln -sf "/usr/lib/systemd/system/sddm.service" "$airootfs/systemd/system/display-manager.service"

# SDDM conf
mkdir -p "$airootfs/sddm.conf.d"
if [ -f "/usr/lib/sddm/sddm.conf.d/default.conf" ]; then
    sed -n '1,35p' /usr/lib/sddm/sddm.conf.d/default.conf > "$airootfs/sddm.conf"
    sed -n '38,137p' /usr/lib/sddm/sddm.conf.d/default.conf > "$airootfs/sddm.conf.d/kde_settings.conf"
fi

# Desktop Environment (safe replace for Session line)
if grep -q "^Session=" "$airootfs/sddm.conf" 2>/dev/null; then
    sed -i 's/^Session=.*/Session=xfce.desktop/' "$airootfs/sddm.conf"
else
    echo "Session=xfce.desktop" >> "$airootfs/sddm.conf"
fi

# Display Server
if grep -q "^DisplayServer=" "$airootfs/sddm.conf" 2>/dev/null; then
    sed -i 's/^DisplayServer=.*/DisplayServer=wayland/' "$airootfs/sddm.conf"
else
    echo "DisplayServer=wayland" >> "$airootfs/sddm.conf"
fi

# Numlock
if grep -q "^Numlock=" "$airootfs/sddm.conf" 2>/dev/null; then
    sed -i 's/^Numlock=.*/Numlock=on/' "$airootfs/sddm.conf"
else
    echo "Numlock=on" >> "$airootfs/sddm.conf"
fi

# User
user="flame"
if grep -q "^User=" "$airootfs/sddm.conf" 2>/dev/null; then
    sed -i "s/^User=.*/User=$user/" "$airootfs/sddm.conf"
else
    echo "User=$user" >> "$airootfs/sddm.conf"
fi

# Hostname
mkdir -p "$(dirname "$airootfs/hostname")"
echo "flameos" > "$airootfs/hostname"

# Adding the new user to passwd
if [ -f "$airootfs/passwd" ]; then
    if grep -q "^$user:" "$airootfs/passwd" 2>/dev/null; then
        sed -i "s|^$user:.*|$user:x:1000:1000::/home/$user:/usr/bin/bash|" "$airootfs/passwd"
        echo "User entry replaced."
    else
        sed -i "1 a\\$user:x:1000:1000::/home/$user:/usr/bin/bash" "$airootfs/passwd"
        echo "User entry added."
    fi
fi

# Password 
hash_pd=$(openssl passwd -6 "flame")

if [ -f "$airootfs/shadow" ]; then
    if grep -q "^$user:" "$airootfs/shadow" 2>/dev/null; then 
        sed -i "s|^$user:.*|$user:$hash_pd:14871::::::|" "$airootfs/shadow"
        echo "Password entry replaced."
    else
        sed -i "1 a\\$user:$hash_pd:14871::::::" "$airootfs/shadow"
        echo "Password entry added."
    fi
fi

# passwordless sudo
mkdir -p "$airootfs/sudoers.d"
echo "$user ALL=(ALL) NOPASSWD: ALL" > "$airootfs/sudoers.d/00-$user-nopasswd"
echo "Password Less entry added."


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

# Grub cfg - perform only safe, tightly-scoped replacements
grubcfg="grub/grub.cfg"
if [ -f "$grubcfg" ]; then
    # Change the visible default label only (do not touch archisobasedir or UUID placeholders)
    sed -i 's/default=archlinux/default=flameos/' "$grubcfg" || true
    sed -i 's/timeout=15/timeout=10/' "$grubcfg" || true
    # Replace only menuentry titles that start with Arch (keeps options intact)
    sed -i '/^[[:space:]]*menuentry[[:space:]]"Arch/ s/Arch/FlameOS/' "$grubcfg" || true

    if ! grep -q 'archisosearchuuid=%ARCHISO_UUID% cow_spacesize=10G copytoram=n' "$grubcfg" 2> /dev/null; then
        sed -i 's/archisosearchuuid=%ARCHISO_UUID%/archisosearchuuid=%ARCHISO_UUID% cow_spacesize=10G copytoram=n/' "$grubcfg" || true
    fi

    if ! grep -q '#play' "$grubcfg" 2> /dev/null; then
        sed -i 's/play/#play/' "$grubcfg" || true
    fi
fi

# efiboot entries - change only title lines, keep placeholders intact
efiloader="efiboot/loader"
if [ -d "$efiloader/entries" ]; then
    # First entry
    if [ -f "$efiloader/entries/01-archiso-x86_64-linux.conf" ]; then
        sed -i 's/^title.*/title    FlameOS Linux install medium (x86_64, UEFI)/' "$efiloader/entries/01-archiso-x86_64-linux.conf"
    fi
    # Second entry
    if [ -f "$efiloader/entries/02-archiso-x86_64-speech-linux.conf" ]; then
        sed -i 's/^title.*/title    FlameOS Linux install medium (x86_64, UEFI) with speech/' "$efiloader/entries/02-archiso-x86_64-speech-linux.conf"
    fi
fi

# Loader config tweaks - safe substitutions only
if [ -f "$efiloader/loader.conf" ]; then
    sed -i 's/timeout 15/timeout 10/' "$efiloader/loader.conf" || true
    sed -i 's/beep on/beep off/' "$efiloader/loader.conf" || true
fi

echo "Branding fixes applied safely. Titles and visible labels updated, placeholders preserved."
