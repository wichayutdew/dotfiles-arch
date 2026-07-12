-- https://wiki.hypr.land/Configuring/Basics/Binds
---------------------
---- KEYBINDINGS ----
---------------------
---- APPS ----
local spotlight = "vicinae toggle"
local terminal = "ghostty"
local browser = "firefox"
local pwdManager = "1password"
local notes = "zennotes"
local music = "spotify"

local cmd = "ALT"
local opt = "SUPER"

---- BASIC COMMAND ----
hl.bind(cmd .. " + Q", hl.dsp.window.close())
hl.bind(cmd .. " + W", hl.dsp.window.close())
hl.bind(cmd .. " + Space", hl.dsp.exec_cmd(spotlight))
hl.bind(cmd .. " + grave", hl.dsp.exec_cmd("hyprctl switchxkblayout all next")) -- language switch

---- SCREENSHOT ----
local script = os.getenv("HOME") .. "/.config/hypr/script"
-- Full screen capture
hl.bind(cmd .. " + SHIFT + H", hl.dsp.exec_cmd(script .. "/screenshot.sh full"))
-- Region selection + annotate
hl.bind(cmd .. " + SHIFT + F", hl.dsp.exec_cmd(script .. "/screenshot.sh region"))
-- Focused window capture
hl.bind(cmd .. " + SHIFT + G", hl.dsp.exec_cmd(script .. "/screenshot.sh window"))

---- SCREEN LOCK ----
hl.bind("CTRL + ALT + Q", hl.dsp.exec_cmd("sh -c 'hyprlock --immediate-render'"))
hl.bind("CTRL + ALT + SHIFT + Q", hl.dsp.exec_cmd("wlogout -b 4"))
hl.bind(
	"switch:on:Lid Switch",
	hl.dsp.exec_cmd("sh -c 'hyprlock --immediate-render & sleep 1 && systemctl suspend'"),
	{ locked = true }
)

---- APP LAUNCHER ----
hl.define_submap("🚀", function()
	hl.bind("C", hl.dsp.exec_cmd(terminal))
	hl.bind("B", hl.dsp.exec_cmd(browser))
	hl.bind("P", hl.dsp.exec_cmd(pwdManager))
	hl.bind("N", hl.dsp.exec_cmd(notes))
	hl.bind("M", hl.dsp.exec_cmd(music))
	hl.bind("catchall", hl.dsp.submap("reset"))
end)
hl.bind(opt .. " + A", hl.dsp.submap("🚀"))

---- WINDOW MANAGEMENT ----
hl.define_submap("🪟", function()
	hl.bind("H", hl.dsp.focus({ direction = "left" }))
	hl.bind("L", hl.dsp.focus({ direction = "right" }))
	hl.bind("K", hl.dsp.focus({ direction = "up" }))
	hl.bind("J", hl.dsp.focus({ direction = "down" }))
	hl.bind("SHIFT + H", hl.dsp.window.move({ direction = "left" }))
	hl.bind("SHIFT + L", hl.dsp.window.move({ direction = "right" }))
	hl.bind("SHIFT + K", hl.dsp.window.move({ direction = "up" }))
	hl.bind("SHIFT + J", hl.dsp.window.move({ direction = "down" }))
	hl.bind("T", hl.dsp.window.float({ action = "toggle" }))
	hl.bind("F", hl.dsp.window.fullscreen({ action = "toggle" }))
	hl.bind("Q", hl.dsp.submap("reset"))
end)
hl.bind(opt .. " + B", hl.dsp.submap("🪟"))

---- WORKSPACE ----
hl.bind(opt .. " + S", hl.dsp.focus({ workspace = 1 }))
hl.bind(opt .. " + D", hl.dsp.focus({ workspace = 2 }))
hl.bind(opt .. " + F", hl.dsp.focus({ workspace = 3 }))
hl.bind(opt .. " + G", hl.dsp.focus({ workspace = 4 }))
hl.bind(opt .. " + SHIFT + S", hl.dsp.window.move({ workspace = 1 }))
hl.bind(opt .. " + SHIFT + D", hl.dsp.window.move({ workspace = 2 }))
hl.bind(opt .. " + SHIFT + F", hl.dsp.window.move({ workspace = 3 }))
hl.bind(opt .. " + SHIFT + G", hl.dsp.window.move({ workspace = 4 }))

---- MOUSE ----
hl.bind(opt .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(opt .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

---- SYSTEM ----
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("F7", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
