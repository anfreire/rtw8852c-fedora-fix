# RTW8852C Bluetooth Audio Fix for Fedora

> ⚠️ **WARNING**: This is NOT a solution, but a temporary workaround. Use at your own risk and consider this a stopgap measure until a proper fix is available through official Fedora updates.

This repository contains scripts to fix Bluetooth audio stuttering issues with RTW8852C chipsets on Fedora Linux, particularly when the issue occurs after kernel updates.

## Background

On Fedora, this issue appears after `dnf update` updates the kernel to versions that use different firmware versions (like rtw8852c_fw-1.bin or rtw8852c_fw-2.bin) instead of the known-working rtw8852c_fw.bin (version 0.27.56.14).

The issue was initially identified on Fedora 41 when updating from:
- Kernel 6.11.4-301.fc41.x86_64 (working) to
- Kernel 6.12.9-200.fc41.x86_64 (stuttering)

## Related Discussion

This issue is being tracked and discussed in the [Fedora Discussion Forum](https://discussion.fedoraproject.org/t/bluetooth-audio-stuttering-during-wifi-activity-on-rtl8852ce/). Please follow the discussion there for updates and to contribute your findings.

## Important Note About Kernel Updates

⚠️ If you notice the stuttering issue returns after a kernel update, this is normal - the update might have reverted to using a different firmware version. Simply run the fix script again to restore the working firmware link.

## Workaround

The fix script creates a backup of your current firmware and creates a symbolic link to the known-working version from Fedora 41's kernel 6.11.4.

## Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/anfreire/rtw8852c-fedora-fix.git
   cd rtw8852c-fedora-fix
   ```

2. Make the scripts executable:
   ```bash
   chmod +x rtw8852c_fix.sh rtw8852c_revert.sh
   ```

3. Run the fix:
   ```bash
   sudo ./rtw8852c_fix.sh
   ```

4. Reboot your system for changes to take effect.

## Reverting Changes

If you need to revert to the original firmware:

```bash
sudo ./rtw8852c_revert.sh
```

Then reboot your system.


## Files

- `rtw8852c_fix.sh`: Script to apply the fix
- `rtw8852c_revert.sh`: Script to revert changes
- `firmware/rtw8852c_fw.bin.xz`: Known-working firmware version (0.27.56.14) from kernel 6.11.4