#!/bin/bash

# Path to the known-working firmware version
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
WORKING_FW="$THIS_DIR/firmware/rtw8852c_fw.bin.xz"  # Local copy of working firmware

# Check if working firmware exists
if [ ! -e "$WORKING_FW" ]; then
    echo "Error: Working firmware not found at $WORKING_FW"
    exit 1
fi

# Get the current firmware being used by the system
current_fw=$(sudo dmesg | grep rtw8852c | grep -Po '[^\s]*.bin')
current_fw_path="/lib/firmware/${current_fw}.xz"

# CHeck if the current firmware exists
if [ ! -e "$current_fw_path" ]; then
    echo "Error: Current firmware not found at $current_fw_path"
    exit 1
fi

# Check if current firmware is already linked to working version
if [ "$(sudo readlink "$current_fw_path")" = "$WORKING_FW" ]; then
    echo "System is already using the working firmware. No changes needed."
    exit 0
fi

# Backup current firmware and create symlink to working version
echo "Switching to working firmware version..."
sudo mv "$current_fw_path" "${current_fw_path}.bak"
sudo ln -s "$WORKING_FW" "$current_fw_path"
echo "Done! Please reboot your system for changes to take effect."