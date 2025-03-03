#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Get valid non-system users (UID >= 1000, exclude 'nobody')
AVAILABLE_USERS=$(getent passwd | awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}')

# Ensure there is at least one valid user
if [[ -z "$AVAILABLE_USERS" ]]; then
    echo "Error: No valid non-system users found. Please create a user before running this script."
    exit 1
fi

# Prompt user selection in a loop until a valid entry is provided
echo "Available non-system users:"
echo "$AVAILABLE_USERS"
while true; do
    read -p "Enter the username to configure: " TARGET_USER </dev/tty
    if echo "$AVAILABLE_USERS" | grep -qw "$TARGET_USER"; then
        break
    else
        echo "Invalid selection. Please choose from the list above."
    fi
done

TARGET_HOME="/home/$TARGET_USER"

# Update system and install essential packages
apt update && apt upgrade -y
apt install -y git wget curl dbus-x11 lightdm slick-greeter gedit extrepo unzip \
               dconf-cli gsettings-desktop-schemas

# Install Cinnamon minimal
apt install -y cinnamon-core

# Install additional themes and applications after Cinnamon-core
apt install -y papirus-icon-theme plank epiphany-browser codium

# Configure LightDM
if [[ -f /etc/lightdm/lightdm.conf ]]; then
    cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.bkup
fi
cat <<EOF > /etc/lightdm/lightdm.conf
[Seat:*]
greeter-session=slick-greeter
autologin-user=$TARGET_USER
EOF
systemctl enable --now lightdm

# Download and set up wallpaper directory
WALLPAPER_DIR="$TARGET_HOME/Pictures/Wallpaper"
mkdir -p "$WALLPAPER_DIR"
wget -O "$WALLPAPER_DIR/wallpaper_lake.jpg" "https://github.com/NickLinney/bookworm-customizations/blob/main/wallpaper_lake_oregon.jpeg"
chown -R "$TARGET_USER:$TARGET_USER" "$WALLPAPER_DIR"

# Set wallpaper using gsettings
sudo -u "$TARGET_USER" dbus-launch gsettings set org.cinnamon.desktop.background picture-uri "file://$WALLPAPER_DIR/wallpaper_lake.jpg"

# Install and configure Plank
mkdir -p "$TARGET_HOME/.config/autostart"
cat <<EOF > "$TARGET_HOME/.config/autostart/plank.desktop"
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank
Comment=Dock for managing windows
EOF
chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/autostart/plank.desktop"

# Final message
echo "System setup complete. Please log out and log back in for all changes to take effect."
echo "After logging in as '$TARGET_USER', manually configure the desktop, then run the user settings script separately."
