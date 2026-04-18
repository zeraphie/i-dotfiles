-- ============================================================
-- wezterm.lua — WezTerm configuration
-- github.com/zeraphie/i-dotfiles
--
-- Platform: Windows (primary) / Linux fallback
-- On macOS, use Ghostty instead — see ghostty/config
-- ============================================================

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ── Shell ─────────────────────────────────────────────────────────────────────
-- On Windows, use Git Bash (Fish isn't natively available on Windows).
-- On Mac/Linux, use Fish from PATH.
if wezterm.target_triple == "x86_64-pc-windows-msvc" or wezterm.target_triple == "aarch64-pc-windows-msvc" then
	-- Git Bash — adjust path if Git is installed elsewhere
	config.default_prog = { "C:\\Program Files\\Git\\bin\\bash.exe", "-l" }
else
	config.default_prog = { "/usr/bin/env", "fish", "-l" }
end

-- ── Font ──────────────────────────────────────────────────────────────────────
config.font = wezterm.font_with_fallback({
	{ family = "3270 Nerd Font", weight = "Regular" },
	{ family = "3270NF", weight = "Regular" },
	{ family = "Courier New", weight = "Regular" },
})
config.font_size = 13.0
config.line_height = 1.15
config.cell_width = 1.0

-- Disable font ligatures (personal preference — remove if you like them)
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- ── Colour scheme (matches Ghostty #1D1F20 dark theme) ───────────────────────
config.colors = {
	foreground = "#c5c8c6",
	background = "#1d1f20",

	cursor_bg = "#c5c8c6",
	cursor_fg = "#1d1f20",
	cursor_border = "#c5c8c6",

	selection_fg = "#c5c8c6",
	selection_bg = "#373b41",

	-- Scrollbar handle colour
	scrollbar_thumb = "#373b41",

	-- Split divider
	split = "#4b4f52",

	ansi = {
		"#1d1f20", -- black
		"#cc6666", -- red
		"#b5bd68", -- green
		"#f0c674", -- yellow
		"#81a2be", -- blue
		"#b294bb", -- magenta
		"#8abeb7", -- cyan
		"#c5c8c6", -- white
	},

	brights = {
		"#4b4f52", -- bright black (grey)
		"#d54e53", -- bright red
		"#8ec07c", -- bright green
		"#e7c547", -- bright yellow
		"#7aa6da", -- bright blue
		"#c397d8", -- bright magenta
		"#70c0ba", -- bright cyan
		"#ffffff", -- bright white
	},

	tab_bar = {
		background = "#1d1f20",

		active_tab = {
			bg_color = "#1d1f20",
			fg_color = "#c5c8c6",
			intensity = "Bold",
			underline = "None",
			italic = false,
			strikethrough = false,
		},

		inactive_tab = {
			bg_color = "#151718",
			fg_color = "#6c7086",
			intensity = "Normal",
		},

		inactive_tab_hover = {
			bg_color = "#2a2d2f",
			fg_color = "#c5c8c6",
		},

		new_tab = {
			bg_color = "#1d1f20",
			fg_color = "#6c7086",
		},

		new_tab_hover = {
			bg_color = "#2a2d2f",
			fg_color = "#c5c8c6",
		},
	},
}

-- ── Cursor ────────────────────────────────────────────────────────────────────
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- ── Window ────────────────────────────────────────────────────────────────────
config.initial_cols = 220
config.initial_rows = 50

config.window_padding = {
	left = 12,
	right = 12,
	top = 10,
	bottom = 10,
}

-- Use the native window decorations
config.window_decorations = "TITLE|RESIZE"

-- Slightly transparent background (0.0 = fully transparent, 1.0 = opaque)
-- Set to 1.0 if you don't want transparency
config.window_background_opacity = 1.0

-- Blur the background behind the window (Windows/Mac only)
config.macos_window_background_blur = 20

-- Don't ask for confirmation when closing a window with active processes
config.window_close_confirmation = "NeverPrompt"

-- ── Tab bar ───────────────────────────────────────────────────────────────────
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.show_tab_index_in_tab_bar = true
config.tab_max_width = 32
config.hide_tab_bar_if_only_one_tab = false

-- ── Scrollback ────────────────────────────────────────────────────────────────
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- ── Performance ───────────────────────────────────────────────────────────────
config.max_fps = 120
config.animation_fps = 60
config.front_end = "WebGpu" -- GPU-accelerated; fall back to "OpenGL" if issues

-- ── Bell ──────────────────────────────────────────────────────────────────────
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_duration_ms = 75,
	fade_out_duration_ms = 75,
	target = "CursorColor",
}

-- ── Mouse ─────────────────────────────────────────────────────────────────────
config.hide_mouse_cursor_when_typing = true

-- ── Key bindings ──────────────────────────────────────────────────────────────
local act = wezterm.action

config.keys = {
	-- New tab
	{ key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },

	-- New window
	{ key = "n", mods = "CTRL", action = act.SpawnWindow },

	-- Tab navigation
	{ key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
	{ key = "LeftArrow",  mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

	-- Split panes (matching Ghostty binds)
	{ key = "d", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "e", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Move between panes (vim-style)
	{ key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },

	-- Font size
	{ key = "=",  mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "-",  mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0",  mods = "CTRL", action = act.ResetFontSize },

	-- Copy / paste
	{ key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

	-- Clear scrollback
	{
		key = "l",
		mods = "CTRL",
		action = act.Multiple({
			act.ClearScrollback("ScrollbackAndViewport"),
			act.SendKey({ key = "l", mods = "CTRL" }),
		}),
	},

	-- Search
	{ key = "f", mods = "CTRL|SHIFT", action = act.Search({ CaseSensitiveString = "" }) },

	-- Close current pane / tab
	{ key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },

	-- Rename tab
	{
		key = "r",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = "Rename tab:",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
}

-- ── Right-click paste (like a normal terminal) ────────────────────────────────
config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(act.ClearSelection, pane)
			else
				window:perform_action(act.PasteFrom("Clipboard"), pane)
			end
		end),
	},
}

-- ── Hyperlinks ────────────────────────────────────────────────────────────────
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Make GitHub and localhost links clickable
table.insert(config.hyperlink_rules, {
	regex = [[["]?([\w\d]{1}[-\w\d]+)(\/){1}([-\w\d\.]+)["]?]],
	format = "https://www.github.com/$1/$3",
})

-- ── Status bar ────────────────────────────────────────────────────────────────
wezterm.on("update-status", function(window, pane)
	local cwd_uri = pane:get_current_working_dir()
	local cwd = ""

	if cwd_uri then
		local path = cwd_uri.file_path or ""
		-- Shorten home directory to ~
		local home = wezterm.home_dir
		if path:sub(1, #home) == home then
			path = "~" .. path:sub(#home + 1)
		end
		cwd = path
	end

	local date = wezterm.strftime("%H:%M")

	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#6c7086" } },
		{ Text = cwd .. "  " .. date .. "  " },
	}))
end)

return config
