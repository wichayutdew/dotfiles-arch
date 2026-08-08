-- https://wiki.hypr.land/Configuring/Basics/Monitors
------------------
---- MONITORS ----
------------------

-- Built-in laptop panel: primary when no external monitor is connected.
hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "0x0",
	scale = "auto",
})

-- External displays: become the MAIN monitor when connected. The built-in is
-- switched to a mirror of the external by script/monitor_layout.sh (a static
-- `mirror` rule cannot work here because the external connects AFTER eDP-1
-- exists, so the mirror must be applied at runtime by the watch daemon).
hl.monitor({
	output = "", -- Your external display
	mode = "preferred",
	position = "auto",
	scale = "auto",
})