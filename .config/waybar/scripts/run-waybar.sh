#!/usr/bin/env bash
# Self-healing waybar launcher.
#
# Waybar's hyprland/workspaces (and submap) modules permanently disable
# themselves if their Hyprland IPC connect fails at startup (e.g. during a
# compositor restart race, or when the shell's HYPRLAND_INSTANCE_SIGNATURE
# points at a dead instance). This wrapper:
#   1. picks the newest live Hyprland instance socket on every iteration,
#   2. (re)starts waybar with that signature,
#   3. restarts waybar if the instance signature changes (old compositor died),
#   4. watches waybar's stderr and restarts the bar if a module permanently
#      disables itself (hyprland/workspaces does this on an IPC JSON parse
#      error that can happen during monitor hotplug/unplug transitions).
set -u

RT="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
LOG="${WAYBAR_LOG:-/tmp/waybar.log}"
last_sig=""
# only scan stderr lines written after we started, so old disable messages
# (e.g. from a previous session) don't trigger a pointless boot-time restart
last_log_lines=$(wc -l < "$LOG" 2>/dev/null || echo 0)

# Wait until the Hyprland instance serves valid IPC JSON. Waybar permanently
# disables its hyprland/workspaces module if its startup query returns empty
# (the IPC socket exists before the compositor is ready to answer).
wait_ready() {
    local sig="$1" i
    for i in $(seq 1 60); do
        if HYPRLAND_INSTANCE_SIGNATURE="$sig" hyprctl -j workspaces 2>/dev/null | jq -e . >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.5
    done
    return 1
}

# restarts the bar so a freshly disabled module is brought back (same instance)
respawn() {
    pkill -x waybar 2>/dev/null
    last_sig=""
}

while true; do
    # --- module-death watchdog: hyprland/workspaces permanently disables itself
    # on an IPC JSON parse error (empty reply during hotplug transitions) while
    # the process keeps running; respawn on the fatal line.
    cur_lines=$(wc -l < "$LOG" 2>/dev/null || echo 0)
    if [ "$cur_lines" -lt "$last_log_lines" ]; then
        last_log_lines=0   # log was truncated/rotated
    fi
    if [ "$cur_lines" -gt "$last_log_lines" ] && \
       tail -n +$((last_log_lines + 1)) "$LOG" 2>/dev/null | grep -q "Disabling module"; then
        echo "[run-waybar] a waybar module disabled itself (IPC error), restarting bar" >> "$LOG"
        respawn
        last_log_lines=$cur_lines
        sleep 1
        continue
    fi
    last_log_lines=$cur_lines

    sig="$(ls -1 "$RT/hypr" 2>/dev/null | sort | tail -n 1 || true)"

    if [ -n "$sig" ] && [ -S "$RT/hypr/$sig/.socket.sock" ]; then
        # (re)start when the instance changed or when the bar is missing (crash)
        if [ "$sig" != "$last_sig" ] || ! pgrep -x waybar >/dev/null 2>&1; then
            if ! wait_ready "$sig"; then
                echo "[run-waybar] instance $sig not serving IPC yet, retrying" >> "$LOG"
                last_sig=""
                sleep 2
                continue
            fi
            respawn
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
