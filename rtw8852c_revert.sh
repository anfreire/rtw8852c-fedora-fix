#!/bin/bash

# Get the first firmware that the system tries to load
current_fw=$(sudo dmesg | grep rtw8852c | grep -Po '[^\s]*.bin' | head -n 1)
current_fw_path="/lib/firmware/${current_fw}.xz"

# Check if backup exists
if [ ! -e "${current_fw_path}.bak" ]; then
    echo "No backup found at ${current_fw_path}.bak"
    exit 1
fi

# Confirm with user before restoring firmware
echo "About to restore original firmware from ${current_fw_path}.bak"
read -p "Do you want to proceed? (y/N): " confirm
confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')
if [ "$confirm" != "y" ] && [ "$confirm" != "yes" ]; then
    echo "Operation cancelled by user"
    exit 0
fi

# Restore original firmware
echo "Restoring original firmware..."
sudo rm "$current_fw_path"                          # Remove symlink
sudo mv "${current_fw_path}.bak" "$current_fw_path" # Restore backup
echo "Done! Please reboot your system for changes to take effect."
