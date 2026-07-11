-- https://wiki.hypr.land/Configuring/Basics/Monitors
------------------
---- MONITORS ----
------------------

hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "0x0",
	scale = "auto",
})

hl.monitor({
	output = "", -- Your external display
	mode = "preferred",
	position = "auto",
	scale = "auto",
	mirror = "eDP-1",
})

