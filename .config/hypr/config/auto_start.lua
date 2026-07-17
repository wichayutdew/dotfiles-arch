-- https://wiki.hypr.land/Configuring/Basics/Autostart/
-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("sleep 1 && waybar")
	hl.exec_cmd("vicinae server")
	-- hl.exec_cmd("hyprpolkitagent")
	-- hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
	hl.exec_cmd("1password")
end)
