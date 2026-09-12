-- Prism PS2 Launcher - ui/loading.lua
-- The boot screen: the prism, the name, a progress bar with the step in progress
-- written inside it, the last steps of the journal underneath (yellow = exFAT drive,
-- cyan = USB), and the credits. Every step is written to the journal BEFORE it is
-- drawn, so a boot that never reaches the menu still says where it stopped.
--
-- API kept from before: load_step(text, kind), load_end(); LOAD_RES_X/Y for the views.

LOAD_RES_X, LOAD_RES_Y = 640, 448
LOAD_ON = false
LOAD_LINES, LOAD_KINDS = {}, {}
LOAD_MAX_LINES = 8
LOAD_EXPECTED = 30          -- steps a normal boot takes; the bar fills against this
LOAD_COUNT = 0
LOAD_MARK = "System/Medias/Default/prism-mark.png"

--- Where the program booted from, one short line. ------------------------------------
function origin_text()
	if BOOT_ES_ATA == true then return "Booted from the internal exFAT drive  ".. tostring(BOOT_DEV), "exfat" end
	if string.lower(string.sub(tostring(BOOT_DEV), 1, 4)) == "host" then return "Running under PCSX2  ".. tostring(BOOT_DEV), nil end
	return "Booted from USB  ".. tostring(BOOT_DEV), "usb"
end

--- Set up: video mode already chosen by system.lua. Fonts are made here, once. ------
function loading_init(res_x, res_y)
	LOAD_RES_X, LOAD_RES_Y = res_x, res_y
	gfx_init()
	gfx_set_screen(res_x, res_y)
	LOAD_ON = true
end

--- The prism, drawn with primitives when the picture is not there. -------------------
local function draw_prism(cx, cy)
	-- Rainbow beams coming in from the left, meeting the prism's left face.
	local beams = {
		Color.new(255, 60, 60), Color.new(255, 140, 40), Color.new(255, 220, 60),
		Color.new(80, 200, 90), Color.new(70, 140, 255), Color.new(150, 80, 220),
	}
	for i = 1, #beams do
		local y0 = cy - 30 + (i - 1) * 9
		Graphics.drawQuad(cx - 120, y0 + GFX.pal_y, cx - 34, cy - 6 + (i - 1) * 4 + GFX.pal_y,
			cx - 34, cy - 2 + (i - 1) * 4 + GFX.pal_y, cx - 120, y0 + 7 + GFX.pal_y,
			beams[i], beams[i], beams[i], beams[i])
	end
	-- White beam leaving on the right.
	local w = Color.new(255, 255, 255)
	Graphics.drawQuad(cx + 30, cy - 4 + GFX.pal_y, cx + 130, cy - 12 + GFX.pal_y,
		cx + 130, cy - 4 + GFX.pal_y, cx + 30, cy + 4 + GFX.pal_y, w, w, w, w)
	-- The prism: a white triangle with the background inside, so only the edges show.
	Graphics.drawTriangle(cx, cy - 46 + GFX.pal_y, cx - 46, cy + 34 + GFX.pal_y, cx + 46, cy + 34 + GFX.pal_y, w)
	Graphics.drawTriangle(cx, cy - 38 + GFX.pal_y, cx - 39, cy + 30 + GFX.pal_y, cx + 39, cy + 30 + GFX.pal_y, THEME.bg_top)
end

--- The people the launcher stands on, in equal slots across the width. Hard-coded x
--- positions were what pushed "wLaunchELF" off the right edge the moment the font
--- changed: the row measures itself now.
local CREDITS = {
	{ "Enceladus",  "DanielSant0s" },
	{ "Neutrino",   "Maximus32" },
	{ "POPStarter", "krHACKen" },
	{ "Ember",      "Gageformer" },
	{ "RetroArch",  "fjtrujy" },
	{ "OPL",        "ps2homebrew" },
	{ "wLaunchELF", "israpps" },
}

local function draw_credits_row(y)
	local size = THEME.size_small
	local left = THEME.pad
	local total = 640 - 2 * THEME.pad
	local slot = total / #CREDITS
	for i = 1, #CREDITS do
		local cx = left + (i - 1) * slot
		gfx_text(gfx_fit(CREDITS[i][1], size, slot - 4), cx, y, size, THEME.text_head)
		gfx_text(gfx_fit(CREDITS[i][2], size, slot - 4), cx, y + 11, size, THEME.text_dim)
	end
end

function load_paint()
	if LOAD_ON ~= true then return end
	gfx_background()

	-- The mark, then the name.
	if gfx_image_fit(LOAD_MARK, 240, 26, 160, 116) == false then
		draw_prism(320, 88)
	end
	gfx_text("PRISM", 0, 150, THEME.size_title, THEME.text_head, "center", 640)
	gfx_text("P S 2   L A U N C H E R", 0, 188, THEME.size_small, THEME.text_dim, "center", 640)
	gfx_text("Where every system converges.", 0, 206, THEME.size_small, THEME.exfat, "center", 640)

	-- Progress bar, the current step written inside it.
	local bx, by, bw, bh = 100, 228, 440, 18
	gfx_rect(bx, by, bw, bh, THEME.panel)
	gfx_frame(bx, by, bw, bh, THEME.selector_edge)
	local frac = LOAD_COUNT / LOAD_EXPECTED
	if frac > 1 then frac = 1 end
	gfx_rect(bx + 1, by + 1, math.floor((bw - 2) * frac), bh - 2, THEME.selector)
	-- The step in progress goes UNDER the bar, not inside it: a line of text across a
	-- filling bar is unreadable exactly when the bar is half full.
	local current = LOAD_LINES[#LOAD_LINES] or ""
	local y = by + bh + 8
	gfx_text(gfx_fit(current, THEME.size_text, 600), 0, y, THEME.size_text, THEME.text_head, "center", 640)
	y = y + 18

	-- The steps before it, most recent last, coloured by where they happened.
	local first = math.max(1, #LOAD_LINES - LOAD_MAX_LINES)
	for i = first, #LOAD_LINES - 1 do
		local col = THEME.text_dim
		if LOAD_KINDS[i] == "exfat" then col = THEME.exfat
		elseif LOAD_KINDS[i] == "usb" then col = THEME.usb
		elseif LOAD_KINDS[i] == true then col = THEME.ok end
		gfx_text(gfx_fit(LOAD_LINES[i], THEME.size_small, 400), 0, y, THEME.size_small, col, "center", 640)
		y = y + 11
	end

	-- Credits, along the bottom. Everything is measured against the safe margin, so a
	-- change of font moves the text but never posts it off the screen.
	local pad = THEME.pad
	local half = (640 - 2 * pad) / 2
	-- Pinned to the REAL bottom of the screen, not to the bottom of the 448-line
	-- layout: on PAL those are 32 pixels apart, and that gap under the credits is
	-- exactly the empty band that kept showing up in the screenshots.
	local foot_h = 112
	local fy = gfx_bottom() - foot_h
	gfx_rect(0, fy, 640, foot_h, THEME.panel)
	gfx_rect(0, fy, 640, 1, THEME.line)

	gfx_text("CREATED BY", pad, fy + 7, THEME.size_small, THEME.text_dim)
	gfx_text("soaresden", pad, fy + 19, THEME.size_head, THEME.text_head)

	local rx = pad + half
	gfx_text("SPECIAL THANKS", rx, fy + 7, THEME.size_small, THEME.text_dim, "right", half)
	gfx_text(gfx_fit("Boon - Spaghetticode", THEME.size_text, half), rx, fy + 19,
		THEME.size_text, THEME.exfat, "right", half)
	gfx_text(gfx_fit("original RETROLauncher, what this grew from", THEME.size_small, half),
		rx, fy + 35, THEME.size_small, THEME.text_dim, "right", half)

	draw_credits_row(fy + 56)

	gfx_text(gfx_fit("Inspired by EmulationStation - interface after PlayStation-X by pajarorrojo",
		THEME.size_small, half + 40), pad, fy + 84, THEME.size_small, THEME.text_dim)
	gfx_text("v1.0 - 2026 - Enceladus", rx, fy + 84, THEME.size_small, THEME.text_dim, "right", half)
	gfx_text(gfx_fit("Assets redrawn, not copied. Console names and logos belong to their owners.",
		THEME.size_small, 640 - 2 * pad), pad, fy + 96, THEME.size_small, THEME.text_dim)
end

--- One boot step: to the journal (flushed) and to the screen. ---------------------------
--- kind: "exfat", "usb", true (done, green) or nil.
function load_step(text, kind)
	if LOAD_ON ~= true then return end
	LOAD_LINES[#LOAD_LINES + 1] = tostring(text)
	LOAD_KINDS[#LOAD_LINES] = kind
	LOAD_COUNT = LOAD_COUNT + 1
	while #LOAD_LINES > LOAD_MAX_LINES + 1 do
		table.remove(LOAD_LINES, 1)
		table.remove(LOAD_KINDS, 1)
	end
	-- The journal may not exist yet: the splash now goes up in index.lua, before
	-- core/log.lua is loaded, precisely so that the drive probing and the wait for a
	-- slow disk happen on a lit screen instead of a black one. A boot screen that
	-- refuses to draw without a journal would defeat the whole point.
	if boot_log ~= nil then boot_log("CARGA  ".. tostring(text)) end
	if boot_flush ~= nil then boot_flush() end
	-- Both buffers, so the picture survives any flip done elsewhere.
	pcall(function()
		load_paint()
		Screen.flip()
		load_paint()
		Screen.flip()
	end)
end

--- The boot screen is over: the interface takes the screen. The fonts stay - they
--- are the interface's fonts too.
function load_end()
	LOAD_ON = false
	boot_log("BOOT   boot screen closed")
end
