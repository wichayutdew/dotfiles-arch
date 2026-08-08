#!/usr/bin/env bash
# Self-healing waybar launcher.
#
# Waybar's hyprland/workspaces (and submap) modules permanently disable
# themselves if their Hyprland IPC connect fails at startup (e.g. during a
# compositor restart race, or when the shell's HYPRLAND_INSTANCE_SIGNATURE
# points at a dead instance). This wrapper:
#   1. picks the newest live Hyprland instance socket on every iteration,
#   2. (re)starts waybar with that signature,
#   3. restarts waybar if the instance signature changes (old compositor died).
set -u

RT="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
LOG="${WAYBAR_LOG:-/tmp/waybar.log}"
last_sig=""

while true; do
    sig="$(ls -1 "$RT/hypr" 2>/dev/null | sort | tail -n 1 || true)"

    if [ -n "$sig" ] && [ -S "$RT/hypr/$sig/.socket.sock" ]; then
        # (re)start when the instance changed or when the bar is missing (crash)
        if [ "$sig" != "$last_sig" ] || ! pgrep -x waybar >/dev/null 2>&1; then
            pkill -x waybar 2>/dev/null
            sleep 1
            last_sig="$sig"
            echo "[run-waybar] starting waybar on instance $sig" >> "$LOG"
            HYPRLAND_INSTANCE_SIGNATURE="$sig" setsid waybar >> "$LOG" 2>&1 &
        fi
    else
        # no live compositor: drop the bar until one appears
        if [ -n "$last_sig" ] || pgrep -x waybar >/dev/null 2>&1; then
            echo "[run-waybar] no live Hyprland instance, stopping bar" >> "$LOG"
            pkill -x waybar 2>/dev/null
        fi
        last_sig=""
    fi

    sleep 3
done
