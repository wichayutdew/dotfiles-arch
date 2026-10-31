#!/bin/bash
# Switch wallpaper based on GNOME color-scheme (dark/light)

WALLPAPER_NORMAL="$HOME/Pictures/wallpaper.jpg"
WALLPAPER_DIM="$HOME/Pictures/wallpaper-dim.jpg"

get_scheme() {
    gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null
}

apply_wallpaper() {
    local scheme
    scheme=$(get_scheme)
    # Preload both wallpapers (hyprpaper requires preload before setting)
    hyprctl hyprpaper preload "$WALLPAPER_NORMAL" >/dev/null 2>&1
    hyprctl hyprpaper preload "$WALLPAPER_DIM" >/dev/null 2>&1
    # Get primary monitor
    local monitor
    monitor=$(hyprctl monitors -j | jq -r '.[0].name')
    if [[ "$scheme" == *"dark"* ]]; then
        hyprctl hyprpaper wallpaper "$monitor,$WALLPAPER_DIM"
    else
        hyprctl hyprpaper wallpaper "$monitor,$WALLPAPER_NORMAL"
    fi
}

# Initial apply
apply_wallpaper

# Watch for changes
dbus-monitor --session "type='signal',interface='org.freedesktop.portal.Settings',member='SettingChanged'" 2>/dev/null |
while read -r line; do
    if echo "$line" | grep -q "color-scheme"; then
        # Small debounce
        sleep 0.3
        apply_wallpaper
    fi
done
