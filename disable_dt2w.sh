#!/system/bin/sh
# Disable double-tap-to-wake on spes/spesn (Focaltech FTS "LCT" touch driver)
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
