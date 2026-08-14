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

-- Workspaces 1-4 are pinned to the built-in so a docking output can never
-- claim them (an external that connects only as a mirror would otherwise grab
-- the first free workspace name "1" and shadow it, making SUPER+1 unreachable).
hl.workspace_rule({ workspace = "1", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "2", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "3", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "4", monitor = "eDP-1" })

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
