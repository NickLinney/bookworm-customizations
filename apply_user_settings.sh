#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# List available users and prompt for the source user
echo "Available non-system users:"
getent passwd | awk -F: '$3 >= 1000 {print $1}'
read -p "Enter the username to use as the source for settings: " SOURCE_USER

# Verify the selected user exists
if ! id "$SOURCE_USER" &>/dev/null; then
    echo "Error: User '$SOURCE_USER' does not exist. Exiting."
    exit 1
fi

SOURCE_HOME="/home/$SOURCE_USER"
WALLPAPER_URL="https://github.com/NickLinney/bookworm-customizations/blob/main/wallpaper_lake_oregon.jpeg"
WALLPAPER_SRC="$SOURCE_HOME/Pictures/Wallpaper/wallpaper_lake.jpg"

# Ensure the source user's wallpaper directory exists
mkdir -p "$SOURCE_HOME/Pictures/Wallpaper"

# Download wallpaper if it doesn't exist
if [[ ! -f "$WALLPAPER_SRC" ]]; then
    echo "Downloading wallpaper..."
    wget -O "$WALLPAPER_SRC" "$WALLPAPER_URL"
    chown "$SOURCE_USER:$SOURCE_USER" "$WALLPAPER_SRC"
fi

TARGET_USERS=$(getent passwd | awk -F: '$3 >= 1000 && $1 != "$SOURCE_USER" && $6 !~ /\/nonexistent/ {print $1}')

# Copy and set wallpaper
for user in $TARGET_USERS; do
    USER_HOME="/home/$user"
    echo "Applying settings to $user..."
    
    mkdir -p "$USER_HOME/.config/dconf"
    chown -R "$user:$user" "$USER_HOME/.config/dconf"
    
    WALLPAPER_DEST="$USER_HOME/Pictures/Wallpaper/wallpaper_lake.jpg"
    mkdir -p "$USER_HOME/Pictures/Wallpaper"
    cp "$WALLPAPER_SRC" "$WALLPAPER_DEST"
    chown "$user:$user" "$WALLPAPER_DEST"
    
    sudo -u "$user" dbus-launch gsettings set org.cinnamon.desktop.background picture-uri "file://$WALLPAPER_DEST"

done

echo "User settings and wallpaper copied successfully."
