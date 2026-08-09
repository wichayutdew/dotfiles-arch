#!/usr/bin/env bash
#
# monitor_layout.sh — mirrored external layout for Hyprland (0.55+ Lua).
#
# Behavior
#   * No external monitor     -> built-in panel (eDP-*) alone at its native
#                                preferred resolution.
#   * Any external monitor    -> the built-in becomes the SOURCE: it is driven
#                                at the external's own resolution (e.g.
#                                1920x1080) so the two logical views are
#                                IDENTICAL, and the external is a clean 1:1
#                                mirror of it. All workspaces live on the
#                                built-in, so both screens show the same UI at
#                                the same time, at the same resolution.
#
# Why this exact geometry
#   Hyprland mirrors render the SOURCE's image; if the mirror's resolution
#   differs from the source's, you get black letterbox areas + flickering.
#   Driving the panel at the external's native resolution makes the mirror
#   pixel-identical (no scaling, no artifact), while the external itself keeps
#   its full native resolution.
#
# Why unplug can never strand a workspace
#   The workspace owner is the built-in panel - the one output that is never
#   unplugged. The external is only a mirror: when it disappears, nothing needs
#   to move. (Workspaces parking on the fallback "?" happens only when the owner
#   is removed while all remaining outputs are mirrors - impossible here.)
#
# Subcommands
#   apply     compute desired layout from current monitors and apply it once
#             (no-op when already up to date).
#   dry-run   print the current state (read-only).
#   watch     daemon: poll and re-apply whenever the layout drifts; exits when
#             Hyprland is unreachable for a while. Single instance per user
#             via flock. Logs to a file.
#
# Env overrides
#   HYPR_MONITOR_INTERNAL_PATTERN    built-in name prefix (default "eDP-")
#   HYPR_MONITOR_POLL_INTERVAL_SECS  watch poll delay (default 1)
#   HYPR_MONITOR_LOG_FILE            watch log path
#                                    (default ${XDG_STATE_HOME:-$HOME/.local/state}/monitor_layout.log)
#
set -euo pipefail

INTERNAL_PATTERN="${HYPR_MONITOR_INTERNAL_PATTERN:-eDP-}"
POLL="${HYPR_MONITOR_POLL_INTERVAL_SECS:-1}"
HYPRCTL="${HYPRCTL:-hyprctl}"
LOG_FILE="${HYPR_MONITOR_LOG_FILE:-${XDG_STATE_HOME:-$HOME/.local/state}/monitor_layout.log}"

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

internal_name() {
    get_monitors | jq -r --arg p "$INTERNAL_PATTERN" "[ .[] | select(.name | startswith(\$p)) | .name ] | .[0] // \"\""
}
external_name() {
    get_monitors | jq -r --arg p "$INTERNAL_PATTERN" "[ .[] | select((.name | startswith(\$p)) | not) | .name ] | sort | .[0] // \"\""
}

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
    local monitors int ext state desired mode
    monitors="$(get_monitors)" || { log "hyprctl unreachable -- is Hyprland running?"; return 1; }
    [ -n "$monitors" ] || { log "no monitors reported"; return 1; }

    int="$(internal_name)"
    ext="$(external_name)"

    [ -n "$int" ] || { log "no built-in monitor matched \"$INTERNAL_PATTERN\""; return 1; }

    if [ -n "$ext" ]; then
        # the external's own resolution becomes the shared logical resolution
        mode="$(jq -r --arg n "$ext" '.[] | select(.name == $n) | "\(.width)x\(.height)"' <<< "$monitors")"
        desired=$(printf "%s\n" "$int=" "$ext=$int" | sort)
    else
        mode="preferred"
        desired="$int="
    fi
    state="$(current_state)"

    if [ "$state" = "$desired" ]; then
        if [ -n "$ext" ]; then
            # names match, but also require the panel to be at the shared size
            # and scale 1; otherwise re-apply (a stale scale shows up as
            # zoomed/black content on the external mirror). Numeric compare:
            # jq reports scale as 1.0 while the rule says 1.
            local intw ints extw okflag
            okflag="$(jq -r --arg i "$int" --arg e "$ext" '
                ([ .[] | select(.name == $e) | .width ] | first) as $ew
                | ([ .[] | select(.name == $i) ] | first) as $m
                | if ($m.scale == 1 and $m.width == $ew) then "ok" else "bad" end
            ' <<< "$monitors")"
            if [ "$okflag" = "ok" ]; then
                if [ "${LAST_UP_TO_DATE:-0}" != "1" ]; then
                    log "layout up to date (internal=$int external=$ext shared_mode=$mode)"
                    LAST_UP_TO_DATE=1
                fi
                return 0
            fi
            log "re-applying: panel mismatch (internal scale/wmode vs external)"
        else
            if [ "${LAST_UP_TO_DATE:-0}" != "1" ]; then
                log "layout up to date (internal=$int external=<none>)"
                LAST_UP_TO_DATE=1
            fi
            return 0
        fi
    else
        LAST_UP_TO_DATE=0
    fi

    log "applying layout: internal=$int external=${ext:-<none>} shared_mode=$mode"
    if [ -n "$ext" ] && [ -n "$mode" ]; then
        # order: make the external a mirror FIRST (mirrors don't occupy layout,
        # so no two-monitors-overlap warning), then size the built-in source to
        # the shared resolution.
        "$HYPRCTL" eval "hl.monitor({ output = \"$ext\", mode = \"preferred\", position = \"0x0\", scale = \"auto\", mirror = \"$int\" })"
        "$HYPRCTL" eval "hl.monitor({ output = \"$int\", mode = \"$mode\", position = \"0x0\", scale = \"1\" })"
        "$HYPRCTL" eval "hl.dsp.focus({ monitor = \"$int\" })"
    else
        "$HYPRCTL" eval "hl.monitor({ output = \"$int\", mode = \"preferred\", position = \"0x0\", scale = \"auto\" })"
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

    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
    exec 1>>"$LOG_FILE" 2>&1

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