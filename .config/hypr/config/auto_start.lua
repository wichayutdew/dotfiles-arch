-- https://wiki.hypr.land/Configuring/Basics/Autostart/
-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("sleep 1 && waybar")
	hl.exec_cmd("vicinae server")
end)
