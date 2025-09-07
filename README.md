# FlameOS ISO

A modern Arch Linux-based live ISO featuring Hyprland wayland compositor with a beautiful, minimal desktop experience.

## Features

- **Hyprland Wayland Compositor** - Dynamic tiling window manager
- **Auto-login** - Boots directly to desktop as `flame` user
- **Modern Applications** - Firefox, Dolphin, Kitty terminal, MPV player
- **GPU Support** - NVIDIA, Intel, and AMD drivers included
- **VM Ready** - VMware and QEMU/KVM support
- **Development Tools** - Arch install scripts, GParted, system utilities

## System Requirements

- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 8GB for live session
- **Architecture**: x86_64 only
- **UEFI/BIOS**: Both supported

## Quick Start

### Building the ISO

```bash
# Clone the repository
git clone <repository-url>
cd flameos-iso

# Build the ISO
./build.sh

# Clean build files (optional)
./clean.sh
```

### Booting

1. Flash the ISO to USB drive using `dd`, Rufus, or Balena Etcher
2. Boot from USB
3. FlameOS will auto-login and start Hyprland

## Default Credentials

- **Username**: `flame`
- **Password**: No password (auto-login enabled)
- **Root**: No password set

## Key Bindings

| Shortcut              | Action                      |
| --------------------- | --------------------------- |
| `Super + T`           | Open terminal (Kitty)       |
| `Super + E`           | File manager (Dolphin)      |
| `Super + A`           | Application launcher (Wofi) |
| `Super + Q`           | Close window                |
| `Super + W`           | Toggle floating             |
| `Super + 1-9`         | Switch workspace            |
| `Super + Shift + 1-9` | Move window to workspace    |
| `Alt + Return`        | Toggle fullscreen           |
| `Print`               | Screenshot                  |

## Included Software

### Desktop Environment

- **Hyprland** - Wayland compositor
- **Waybar** - Status bar
- **SDDM** - Display manager
- **Wofi** - Application launcher

### Applications

- **Firefox** - Web browser
- **Kitty** - Terminal emulator
- **Dolphin** - File manager
- **MPV** - Media player
- **GParted** - Partition editor
- **Gwenview** - Image viewer

### System Tools

- **Fastfetch** - System information
- **Htop/Nvtop** - Process monitors
- **Arch Install Scripts** - System installation
- **Reflector** - Mirror management

## Customization

### Wallpaper

Default wallpaper located at: `/home/flame/flameos-wallpaper.png`

### Hyprland Config

Configuration files in: `/home/flame/.config/hypr/`

### Waybar Config

Status bar config in: `/home/flame/.config/waybar/`

## Installation to Hard Drive

FlameOS includes `archinstall` for easy system installation:

```bash
# Run the installer
sudo archinstall

# Or use manual installation
# Follow Arch Linux installation guide
```

## Troubleshooting

### Hyprland Won't Start

- Check GPU drivers are loaded: `lspci -k`
- Verify Wayland session: `echo $XDG_SESSION_TYPE`
- Check logs: `journalctl -u sddm`

### No Network

```bash
# Enable NetworkManager
sudo systemctl enable --now NetworkManager

# Or use iwctl for WiFi
iwctl station wlan0 connect "SSID"
```

### Display Issues

- Try different kernel parameters in GRUB
- Check monitor configuration in Hyprland config
- Use `xrandr` for X11 fallback if needed

## Development

### File Structure

```
flameos-iso/
├── airootfs/          # Root filesystem overlay
├── grub/              # GRUB bootloader config
├── syslinux/          # Syslinux bootloader config
├── efiboot/           # EFI boot files
├── packages.x86_64    # Package list
├── profiledef.sh      # ISO profile settings
├── build.sh           # Build script
└── clean.sh           # Cleanup script
```

### Adding Packages

Edit `packages.x86_64` and add package names:

```
# Your packages
package-name
another-package
```

### Custom Files

Place custom files in `airootfs/` directory following the root filesystem structure.

## Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature-name`
3. Make changes and test
4. Submit pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- **Arch Linux** - Base distribution
- **Hyprland** - Wayland compositor
- **Archiso** - ISO building framework

---

**FlameOS** - _Ignite your desktop experience_ 🔥
