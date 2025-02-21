#!/bin/bash

# Get the current firmware being used by the system
current_fw=$(sudo dmesg | grep rtw8852c | grep -Po '[^\s]*.bin')
current_fw_path="/lib/firmware/${current_fw}.xz"

# Check if backup exists
if [ ! -e "${current_fw_path}.bak" ]; then
    echo "No backup found at ${current_fw_path}.bak"
    exit 1
fi

# Restore original firmware
echo "Restoring original firmware..."
sudo rm "$current_fw_path"                          # Remove symlink
sudo mv "${current_fw_path}.bak" "$current_fw_path" # Restore backup
echo "Done! Please reboot your system for changes to take effect."
