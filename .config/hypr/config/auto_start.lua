-- https://wiki.hypr.land/Configuring/Basics/Autostart/
-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("while ! hyprctl hyprpaper listactive >/dev/null 2>&1; do sleep 0.1; done && ~/.config/hypr/script/wallpaper.sh")
	hl.exec_cmd("~/.config/waybar/scripts/run-waybar.sh")
	hl.exec_cmd("vicinae server")
	hl.exec_cmd("~/.config/hypr/script/monitor_layout.sh watch")
	hl.exec_cmd("/usr/lib/hyprpolkitagent")
end)
