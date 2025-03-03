# Debian 12 Cinnamon Setup

This setup provides a minimal **Cinnamon desktop environment** with essential applications and customizations.

## Installed Packages
- `cinnamon-core`
- `lightdm` (with `slick-greeter`)
- `papirus-icon-theme`
- `codium`
- `plank`
- `epiphany-browser`
- `gedit`
- Other essential tools (`git`, `wget`, `curl`, `dbus-x11`, etc.)

## Installation
Run this command to set up the system:
```bash
wget -O - https://raw.githubusercontent.com/NickLinney/bookworm-customizations/main/install.sh | bash
```
This installs Cinnamon, configures LightDM, downloads the wallpaper, and sets up Plank.

## Apply User Settings
After logging in and customizing your desktop, run the following to apply settings for all users:
```bash
wget -O - https://raw.githubusercontent.com/NickLinney/bookworm-customizations/main/apply_user_settings.sh | bash
```
This script lets you select a user to copy settings from and applies them system-wide.

## Summary of Scripts
| Script | Purpose |
|--------|---------|
| `install.sh` | Installs packages, configures LightDM, and downloads wallpaper |
| `apply_user_settings.sh` | Copies settings and applies wallpaper for all users |

🚀 The system is now ready for use with a minimal and clean Cinnamon desktop setup.
