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
    if [[ "$scheme" == *"dark"* ]]; then
        hyprctl hyprpaper wallpaper ",$WALLPAPER_DIM"
    else
        hyprctl hyprpaper wallpaper ",$WALLPAPER_NORMAL"
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
