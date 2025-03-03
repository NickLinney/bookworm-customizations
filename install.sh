#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Define primary user
SOURCE_USER="nrlin"
SOURCE_HOME="/home/$SOURCE_USER"
TARGET_USERS=$(getent passwd | awk -F: '$3 >= 1000 && $1 != "'$SOURCE_USER'" && $6 !~ /\/nonexistent/ {print $1}')

# Update system and install essential packages
apt update && apt upgrade -y
apt install -y git wget curl dbus-x11 lightdm slick-greeter gedit \
               plank epiphany-browser codium papirus-icon-theme unzip \
               dconf-cli gsettings-desktop-schemas

# Install Cinnamon minimal
apt install -y cinnamon-core

# Configure LightDM
if [[ -f /etc/lightdm/lightdm.conf ]]; then
    cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.bkup
fi
cat <<EOF > /etc/lightdm/lightdm.conf
[Seat:*]
greeter-session=slick-greeter
autologin-user=nrlin
EOF
systemctl enable --now lightdm

# Install and configure Plank
apt install -y plank
for user in $TARGET_USERS; do
    USER_HOME="/home/$user"
    AUTOSTART_DIR="$USER_HOME/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"
    cat <<EOF > "$AUTOSTART_DIR/plank.desktop"
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank
Comment=Dock for managing windows
EOF
    chown "$user:$user" "$AUTOSTART_DIR/plank.desktop"
done

# Final message
echo "System setup complete. Please reboot for all changes to take effect."
