[README.md](https://github.com/user-attachments/files/34171057/README.md)
# Disable Double Tap To Wake — Redmi Note 11 (spes/spesn)

A fix for "Double Tap to Wake" on custom ROMs (e.g. Realme UI ports)
where the ROM's own toggle does not actually turn it off.

## The problem

On ported ROMs (e.g. Realme UI 7 on Redmi Note 11 / spes / spesn), the
"Double-tap to turn on/off screen" setting in the ROM's lock-screen
settings writes to an Oplus-specific control node that does not exist
on this device's kernel. The touch driver (Focaltech FTS, LCT variant)
keeps its own gesture state in `/proc/tp_gesture`, which the ROM
setting never touches — so double-tap-to-wake stays on even after you
turn the setting off.

## The fix

A tiny background loop that writes `0` to `/proc/tp_gesture` on boot,
and keeps re-forcing it every 3 seconds in case the ROM or an app
re-enables it on screen-off.

## Device compatibility

- Tested on: **Redmi Note 11 (spes / spesn)** running a Realme UI 7
  Android 16 kernel port (KernelSU Next).
- Requires: a Focaltech FTS "LCT" touch driver exposing
  `/proc/tp_gesture`. Check first:
  ```
  adb shell su -c "cat /proc/tp_gesture"
  ```
  If this file doesn't exist on your device, neither install method
  below will do anything (harmlessly).

## Install — Option A: no module, just a root script (recommended, no manager app needed)

This drops a single script into KernelSU/Magisk's `service.d` folder.
It is **not** a flashable module and won't show up in your root
manager's Modules list — it just runs on every boot as long as root
is present.

1. Connect your phone via `adb` (USB debugging on) and get a root
   shell:
   ```
   adb shell
   su
   ```
2. Inside the root shell, run:
   ```
   mkdir -p /data/adb/service.d
   cat > /data/adb/service.d/disable_dt2w.sh << 'EOF'
   #!/system/bin/sh
   until [ "$(getprop sys.boot_completed)" = "1" ]; do
       sleep 1
   done
   sleep 10
   NODE=/proc/tp_gesture
   [ -e "$NODE" ] || exit 0
   while true; do
       [ "$(cat $NODE 2>/dev/null | tr -d '[:space:]')" != "0" ] && echo 0 > $NODE
       sleep 3
   done &
   EOF
   chmod 755 /data/adb/service.d/disable_dt2w.sh
   ```
   (Or just push the [`disable_dt2w.sh`](disable_dt2w.sh) file from
   this repo to `/data/adb/service.d/` and `chmod 755` it.)
3. Reboot:
   ```
   reboot
   ```

### Verify

Wait 20-30 seconds after boot, then:
```
adb shell su -c "cat /proc/tp_gesture"
```
Should read `0`.

### Remove

```
adb shell su -c "rm /data/adb/service.d/disable_dt2w.sh"
```

## Install — Option B: flashable module (via root manager app)

If you'd rather manage this like any other module (enable/disable
toggle in your manager app), use the flashable zip instead — see the
[Releases](../../releases) page for `disable_dt2w_spes-v1.0.zip`.
Flash it from KernelSU Next / Magisk Manager → Modules → Install, then
reboot.

Both options do exactly the same thing; pick whichever fits your
workflow.

## Disclaimer

Provided as-is. Tested only on the device/ROM combination above. Use
at your own risk.
