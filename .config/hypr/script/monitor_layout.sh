#!/usr/bin/env bash
#
# monitor_layout.sh — "external = main, laptop = mirror" layout manager for Hyprland.
#
# Behavior
#   * No external monitor     -> built-in panel (eDP-*) is the normal primary.
#   * Any external monitor    -> that monitor becomes the MAIN monitor at its full
#                                (preferred) resolution; the built-in panel becomes
#                                a MIRROR of it. Hyprland renders the mirror scaled
#                                to fit, aspect preserved, centered.
#
# Subcommands
#   apply     compute desired layout from current monitors and apply it once
#             (no-op when already up to date).
#   dry-run   print the current state (read-only).
#   watch     daemon: poll and re-apply whenever the layout drifts; exits when
#             Hyprland is gone. Single instance per user (flock).
#
# Env overrides
#   HYPR_MONITOR_INTERNAL_PATTERN    built-in name prefix (default "eDP-")
#   HYPR_MONITOR_LAPTOP_MODE         "mirror" (default) or "off" (disable panel)
#   HYPR_MONITOR_POLL_INTERVAL_SECS  watch poll delay (default 1)
#
set -euo pipefail

INTERNAL_PATTERN="${HYPR_MONITOR_INTERNAL_PATTERN:-eDP-}"
LAPTOP_MODE="${HYPR_MONITOR_LAPTOP_MODE:-mirror}"
POLL="${HYPR_MONITOR_POLL_INTERVAL_SECS:-1}"
HYPRCTL="${HYPRCTL:-hyprctl}"

log() { printf "[monitor_layout] %s %s\n" "$(date +%H:%M:%S)" "$*" >&2; }

# Re-bind to the newest live Hyprland instance socket so this daemon
# survives compositor restarts (the env signature at spawn goes stale).
refresh_sig() {
    local dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr" sig
    sig="$(ls -1 "$dir" 2>/dev/null | sort | tail -n 1 || true)"
    if [ -n "$sig" ] && [ -S "$dir/$sig/.socket.sock" ]; then
        export HYPRLAND_INSTANCE_SIGNATURE="$sig"
        return 0
    fi
    return 1
}
get_monitors() { "$HYPRCTL" -j monitors all 2>/dev/null; }

# enabled monitors as "name=mirrorName" lines, sorted
current_state() {
    get_monitors | jq -r "
        ([ .[] | { (.id | tostring): .name } ] | add) as \$ids
        | .[]
        | select(.disabled == false)
        | \"\(.name)=\(if ((\"\\(.mirrorOf)\" == \"none\") or (.mirrorOf == null)) then \"\" else (\$ids[\"\\(.mirrorOf)\"] // \"unknown\") end)\"
    " | sort
}

apply_layout() {
    local monitors int ext state desired
    monitors="$(get_monitors)" || { log "hyprctl unreachable -- is Hyprland running?"; return 1; }
    [ -n "$monitors" ] || { log "no monitors reported"; return 1; }

    int="$(printf "%s" "$monitors" | jq -r --arg p "$INTERNAL_PATTERN" "[ .[] | select(.name | startswith(\$p)) | .name ] | .[0] // \"\"")"
    ext="$(printf "%s" "$monitors" | jq -r --arg p "$INTERNAL_PATTERN" "[ .[] | select((.name | startswith(\$p)) | not) | .name ] | sort | .[0] // \"\"")"

    [ -n "$int" ] || { log "no built-in monitor matched \"$INTERNAL_PATTERN\""; return 1; }

    if [ -n "$ext" ] && [ "$LAPTOP_MODE" = "mirror" ]; then
        desired=$(printf "%s\n" "$ext=" "$int=$ext" | sort)
    elif [ -n "$ext" ]; then
        desired="$ext="
    else
        desired="$int="
    fi
    state="$(current_state)"

    if [ "$state" = "$desired" ]; then
        if [ "${LAST_UP_TO_DATE:-0}" != "1" ]; then
            log "layout up to date (internal=$int external=${ext:-<none>} mode=$LAPTOP_MODE)"
            LAST_UP_TO_DATE=1
        fi
        return 0
    fi

    LAST_UP_TO_DATE=0

    log "applying layout: internal=$int external=${ext:-<none>} mode=$LAPTOP_MODE"
    if [ -z "$ext" ]; then
        "$HYPRCTL" eval "hl.monitor({ output = \"$int\", mode = \"preferred\", position = \"0x0\", scale = \"auto\", mirror = \"\" })"
    elif [ "$LAPTOP_MODE" = "mirror" ]; then
        # Order matters: mirror eDP-1 FIRST so it leaves the layout before DP-1
        # moves to 0x0. Doing it the other way around briefly puts both monitors
        # at 0x0 (two layout monitors overlapping) -> hyprland overlap warning.
        "$HYPRCTL" eval "hl.monitor({ output = \"$int\", mode = \"preferred\", position = \"0x0\", scale = \"auto\", mirror = \"$ext\" })"
        "$HYPRCTL" eval "hl.monitor({ output = \"$ext\", mode = \"preferred\", position = \"0x0\", scale = \"auto\" })"
        "$HYPRCTL" eval "hl.dsp.focus({ monitor = \"$ext\" })"
    else
        "$HYPRCTL" eval "hl.monitor({ output = \"$ext\", mode = \"preferred\", position = \"0x0\", scale = \"auto\" })"
        "$HYPRCTL" eval "hl.monitor({ output = \"$int\", disabled = true })"
    fi
}

cmd_dry_run() {
    printf "monitors reported:\n%s\n" "$(current_state)"
}

cmd_watch() {
    local lock
    lock="${TMPDIR:-/tmp}/monitor_layout_${UID}.lock"
    exec 9>"$lock" || return 1
    flock -n 9 || { log "another watch instance is running"; return 1; }
    local failures=0
    while :; do
        if ! refresh_sig || ! get_monitors >/dev/null 2>&1; then
            failures=$((failures + 1))
            if [ "$failures" -ge 30 ]; then
                log "no live Hyprland instance for 30s, exiting"
                exit 0
            fi
            [ "$failures" -eq 1 ] && log "Hyprland unreachable, retrying"
            LAST_UP_TO_DATE=0
            sleep "$POLL"
            continue
        fi
        failures=0
        apply_layout || true
        sleep "$POLL"
    done
}

case "${1:-}" in
    apply)   refresh_sig && apply_layout ;;
    dry-run) refresh_sig && cmd_dry_run ;;
    watch)   cmd_watch ;;
    *) printf "usage: %s {watch|apply|dry-run}\n" "$0" >&2; exit 64 ;;
esac