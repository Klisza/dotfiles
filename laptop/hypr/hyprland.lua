------------------
---- MONITORS ----
------------------

hl.monitor({
	output = "eDP-1",
	mode = "2880x1800@120.00",
	position = "0x0",
	scale = 1.5,
})

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty"
local fileManager = "thunar"
local menu = "tofi-drun --drun-launch=true"
local browser = "librewolf"
local mainMod = "SUPER"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")
	hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("waybar")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- When launching Hyprland through UWSM, Hyprland recommends placing these
-- in ~/.config/uwsm/env and ~/.config/uwsm/env-hyprland instead.
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GTK_THEME", "Adwaita-dark")
hl.env("GTK_APPLICATION_PREFER_DARK_THEME", "1")
hl.env("MPD_HOST", "/home/kuba/.mpd/socket")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
	scale = 1.5,
})

hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 5,
		border_size = 3,

		col = {
			active_border = {
				colors = { "rgba(0d359caa)", "rgba(0d6a83ee)" },
				angle = 45,
			},
			inactive_border = "rgba(595959aa)",
		},

		resize_on_border = false,
		allow_tearing = false,
		layout = "master",
	},

	gestures = {
		workspace_swipe_distance = 250,
		workspace_swipe_cancel_ratio = 0.3,
		workspace_swipe_min_speed_to_force = 20,
	},

	decoration = {
		rounding = 3,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 0.8,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = 0xee1a1a1a,
		},

		blur = {
			enabled = true,
			size = 4,
			passes = 2,
			vibrancy = 0.4,
		},
	},

	animations = {
		enabled = true,
	},

	debug = {
		full_cm_proto = true,
	},

	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "slave",
	},

	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = false,
	},

	input = {
		kb_layout = "de,gb",
		kb_variant = "",
		kb_options = "grp:win_space_toggle",
		kb_model = "",
		kb_rules = "",
		follow_mouse = 1,
		accel_profile = "adaptive",
		sensitivity = 0,

		touchpad = {
			natural_scroll = true,
		},
	},

	binds = {
		workspace_back_and_forth = true,
	},

	xwayland = {
		force_zero_scaling = true,
	},
})

--------------------
---- ANIMATIONS ----
--------------------

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slidefade 100%" })
-- hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

---------------------
---- KEYBINDINGS ----
---------------------

-- Switch between the current and previously focused window.
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ last = true }))

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))

-- Move windows with Super+Shift+H/J/K/L.
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))

-- Move focus with arrow keys and H/J/K/L.
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))

-- Switch to workspaces 1-10 and move the active window with Shift.
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad).
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces.
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with Super + mouse buttons.
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshot.
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region"))

-- Volume and brightness keys: locked and repeat while held.
local function bindLockedRepeating(key, command)
	hl.bind(key, hl.dsp.exec_cmd(command), { locked = true, repeating = true })
end

bindLockedRepeating("XF86AudioRaiseVolume", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")
bindLockedRepeating("XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
bindLockedRepeating("XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
bindLockedRepeating("XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
bindLockedRepeating("XF86MonBrightnessUp", "brightnessctl -e4 -n2 set 5%+")
bindLockedRepeating("XF86MonBrightnessDown", "brightnessctl -e4 -n2 set 5%-")

-- Player controls: available while the screen is locked.
local function bindLocked(key, command)
	hl.bind(key, hl.dsp.exec_cmd(command), { locked = true })
end

bindLocked("XF86AudioNext", "playerctl next")
bindLocked("XF86AudioPause", "playerctl play-pause")
bindLocked("XF86AudioPlay", "playerctl play-pause")
bindLocked("XF86AudioPrev", "playerctl previous")

-- MPD controls. ALT is used as the modifier; ALT_L is a keysym, not a modifier name.
local musicMod = "SUPER + ALT"
hl.bind(musicMod .. " + P", hl.dsp.exec_cmd("mpc toggle"))
hl.bind(musicMod .. " + RIGHT", hl.dsp.exec_cmd("mpc next"))
hl.bind(musicMod .. " + LEFT", hl.dsp.exec_cmd("mpc prev"))
hl.bind(musicMod .. " + S", hl.dsp.exec_cmd("mpc stop"))
hl.bind(musicMod .. " + UP", hl.dsp.exec_cmd("mpc volume +5"))
hl.bind(musicMod .. " + DOWN", hl.dsp.exec_cmd("mpc volume -5"))
