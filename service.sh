#!/system/bin/sh
# Disable double-tap-to-wake on spes (Focaltech/LCT driver)
until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 2; done
sleep 10
NODE=/proc/tp_gesture
[ -e "$NODE" ] || exit 0
# ROM settings can re-enable it on screen-off, so keep forcing 0
while true; do
  if [ "$(cat $NODE 2>/dev/null | tr -d '[:space:]')" != "0" ]; then
    echo 0 > $NODE
  fi
  sleep 3
done
