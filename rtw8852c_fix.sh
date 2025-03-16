#!/bin/bash

# Path to the known-working firmware version
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
GIT_WORKING_FW="$THIS_DIR/firmware/rtw8852c_fw.bin.xz" # Local copy from git repo

# Check if the system has the base firmware which is usually working
SYSTEM_WORKING_FW="/lib/firmware/rtw89/rtw8852c_fw.bin.xz"

# Determine which working firmware to use
if [ -e "$SYSTEM_WORKING_FW" ]; then
    echo "Found system base firmware at $SYSTEM_WORKING_FW"
    WORKING_FW="$SYSTEM_WORKING_FW"
elif [ -e "$GIT_WORKING_FW" ]; then
    echo "Using working firmware from git repository at $GIT_WORKING_FW"
    WORKING_FW="$GIT_WORKING_FW"
else
    echo "Error: Could not find working firmware at either $SYSTEM_WORKING_FW or $GIT_WORKING_FW"
    exit 1
fi

# Get the current firmware being used by the system
current_fw=$(sudo dmesg | grep rtw8852c | grep -Po '([^\s]*.bin)' | head -n 1)

# Debug output to help troubleshoot
echo "Detected current firmware from dmesg: '$current_fw'"

# If the grep returned empty, try a fallback method
if [ -z "$current_fw" ]; then
    echo "Warning: Could not detect firmware from dmesg. Using fallback path."
    # Fallback to a common firmware path
    current_fw="rtw89/rtw8852c_fw-1.bin"
    echo "Using fallback firmware path: $current_fw"
fi

# Check if the current firmware is the correct file ( == rtw89/rtw8852c_fw.bin)
if [ "$current_fw" == "rtw89/rtw8852c_fw.bin" ]; then
    echo "System is already using the working firmware. No changes needed."
    exit 0
fi

current_fw_path="/lib/firmware/${current_fw}.xz"
echo "Full path to current firmware: $current_fw_path"

# Check if the current firmware exists
if [ ! -e "$current_fw_path" ]; then
    echo "Error: Current firmware not found at $current_fw_path"
    echo "This may happen if dmesg output doesn't match the actual firmware location."
    echo "Manual intervention required. Possible location to check:"
    echo "  - /lib/firmware/rtw89/rtw8852c_fw-1.bin.xz"
    exit 1
fi

# Check if current firmware is already linked to working version
if [ -L "$current_fw_path" ]; then
    linked_to=$(sudo readlink "$current_fw_path")
    if [ "$linked_to" = "$WORKING_FW" ]; then
        echo "System is already using the working firmware. No changes needed."
        exit 0
    else
        echo "Current firmware is a symlink but points to $linked_to"
        echo "This might be from a previous fix attempt using the firmware provided in this repository."
        echo "Will update to point to the system base working firmware."
    fi
fi

# Confirm with user before replacing firmware
echo "About to replace firmware at $current_fw_path with $WORKING_FW"
read -p "Do you want to proceed? (y/N): " confirm
confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')
if [ "$confirm" != "y" ] && [ "$confirm" != "yes" ]; then
    echo "Operation cancelled by user"
    exit 0
fi

# Backup current firmware and create symlink to working version
echo "Switching to working firmware version..."
sudo mv "$current_fw_path" "${current_fw_path}.bak"
echo "Backup created at ${current_fw_path}.bak"
sudo ln -s "$WORKING_FW" "$current_fw_path"
echo "Symlink created from $current_fw_path to $WORKING_FW"
echo "Done! Please reboot your system for changes to take effect."