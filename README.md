# Disable Double Tap To Wake — Redmi Note 11 (spes/spesn)

A KernelSU / Magisk module that force-disables "Double Tap to Wake" on
custom ROMs (e.g. Realme UI ports) where the ROM's own toggle does not
actually turn it off.

## The problem

On ported ROMs (e.g. Realme UI 7 on Redmi Note 11 / spes / spesn), the
"Double-tap to turn on/off screen" setting in the ROM's lock-screen
settings writes to an Oplus-specific control node that does not exist
on this device's kernel. The touch driver (Focaltech FTS, LCT variant)
keeps its own gesture state in `/proc/tp_gesture`, which the ROM
setting never touches — so double-tap-to-wake stays on even after you
turn the setting off.

## What this module does

A background service script that:
1. Waits for boot to complete.
2. Writes `0` to `/proc/tp_gesture` to disable the gesture.
3. Keeps checking every 3 seconds and re-forces it to `0`, in case the
   ROM or app re-enables it on screen-off.

## Device compatibility

- Tested on: **Redmi Note 11 (spes / spesn)** running a Realme UI 7
  Android 16 kernel port (KernelSU Next).
- Requires: a Focaltech FTS "LCT" touch driver exposing
  `/proc/tp_gesture`. Other devices/kernels may use a different node
  name — check with:
  ```
  adb shell su -c "cat /proc/tp_gesture"
  ```
  If this file doesn't exist on your device, this module will do
  nothing (harmlessly).

## Install

1. Root required (KernelSU / Magisk).
2. Download the module zip from [Releases](../../releases).
3. Flash it from your root manager app (Modules → Install).
4. Reboot.

## Verify

```
adb shell su -c "cat /proc/tp_gesture"
```
Should read `0`. Double-tap on lock screen should no longer wake the
display.

## Uninstall

Remove the module from your root manager's Modules list, or manually:
```
rm -rf /data/adb/modules/disable_dt2w
```

## Disclaimer

Provided as-is. Tested only on the device/ROM combination above. Use
at your own risk.
