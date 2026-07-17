---------------
---- INPUT ----
---------------
hl.config({
	input = {
		kb_layout = "us,th",
		kb_variant = ",",
		kb_options = "",
		kb_model = "",
		kb_rules = "",
		repeat_delay = 300,
		follow_mouse = 1,
		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
		touchpad = {
			natural_scroll = true,
			scroll_factor = 0.5,
		},
	},
})

-- Target ONLY the laptop hardware for the custom triangular bindings
local laptop_keyboard = "at-translated-set-2-keyboard"
hl.device({
	name = laptop_keyboard,
	kb_options = "caps:backspace",
})
hl.bind(
	"Backspace",
	hl.dsp.send_shortcut({ mods = "", key = "Escape" }),
	{ device = { inclusive = true, list = { laptop_keyboard } } }
)

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
-- hl.device({
-- 	name = "epic-mouse-v1",
-- 	sensitivity = -0.5,
-- })
