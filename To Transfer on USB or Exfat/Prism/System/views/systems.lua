-- Prism PS2 Launcher - views/systems.lua
-- The systems view: a column of systems on the left, the selected system on the right.
-- The column is shared with the gamelist view (drawn dimmed there), so it lives here.

SYSTEMS_VIEW = { list = nil }

--- What the column shows. The libretro names are long ("Nintendo - Super Nintendo
--- Entertainment System"); the column wants the name people use. Anything not here
--- loses its maker prefix.
SHORT_NAMES = {
	snes = "Super Nintendo", nes = "NES", gb = "Game Boy", gbc = "Game Boy Color",
	gba = "Game Boy Advance", n64 = "Nintendo 64", nds = "Nintendo DS", fds = "Famicom Disk",
	megadrive = "Mega Drive", mastersystem = "Master System", gamegear = "Game Gear",
	sg1000 = "SG-1000", segacd = "Mega-CD", sega32x = "32X", saturn = "Saturn",
	psx = "PlayStation", ps2 = "PlayStation 2", psp = "PSP",
	atari2600 = "Atari 2600", atari7800 = "Atari 7800", lynx = "Atari Lynx", jaguar = "Jaguar",
	ngp = "Neo Geo Pocket", ngpc = "Neo Geo Pocket Color", neogeo = "Neo Geo",
	pcengine = "PC Engine", supergrafx = "SuperGrafx", wswan = "WonderSwan", wswanc = "WonderSwan Color",
	arcade = "Arcade", mame = "Arcade", fbneo = "Arcade (FBNeo)", dos = "DOS", scummvm = "ScummVM",
	c64 = "Commodore 64", amiga = "Amiga", amstradcpc = "Amstrad CPC", zxspectrum = "ZX Spectrum",
	msx = "MSX", colecovision = "ColecoVision", intellivision = "Intellivision", vectrex = "Vectrex",
	virtualboy = "Virtual Boy", pokemini = "Pokemon Mini", gamecube = "GameCube", channelf = "Channel F",
}

function system_short_name(s)
	if SHORT_NAMES[s.folder] ~= nil then return SHORT_NAMES[s.folder] end
	local rest = string.match(s.name, "^.-%s%-%s(.+)$")
	return rest or s.name
end

function systems_view_init()
	local rows = math.floor((448 - THEME.header_h - THEME.footer_h - 8) / THEME.row_h)
	SYSTEMS_VIEW.list = list_new(LIBRARY.systems, rows)
end

function systems_view_current()
	return list_current(SYSTEMS_VIEW.list)
end

--- Header bar, common to every view. ---------------------------------------------------
function draw_header(right_text)
	gfx_rect(0, 0, 640, THEME.header_h, THEME.panel_hi)
	gfx_rect(0, THEME.header_h - 1, 640, 1, THEME.line)
	gfx_text("PRISM", 14, 9, THEME.size_head, THEME.text_head)
	if right_text ~= nil then
		gfx_text(right_text, 300, 12, THEME.size_small, THEME.text_dim, "right", 326)
	end
end

--- Footer with button hints. hints: array of { button, label }. ------------------------
function draw_footer(hints)
	local y = 448 - THEME.footer_h
	gfx_rect(0, y, 640, THEME.footer_h, THEME.panel)
	gfx_rect(0, y, 640, 1, THEME.line)
	local x = 14
	for i = 1, #hints do
		x = gfx_hint(x, y + 7, hints[i][1], hints[i][2])
	end
end

--- The systems column. focused=false dims the bar (gamelist has the focus). -----------
function draw_systems_column(focused)
	local col = THEME.systems_col
	local y = THEME.header_h + 4
	gfx_rect(col.x, THEME.header_h, col.w, 448 - THEME.header_h - THEME.footer_h, THEME.panel)
	gfx_rect(col.x + col.w - 1, THEME.header_h, 1, 448 - THEME.header_h - THEME.footer_h, THEME.line)
	list_draw(SYSTEMS_VIEW.list, col.x, y, col.w - 1, THEME.row_h, function(s)
		return system_short_name(s), THEME.text
	end, focused)
end

--- Short name for the detail panel: "Sony - PlayStation" -> maker "Sony", name "PlayStation".
local function split_name(name)
	local maker, rest = string.match(name, "^(.-)%s%-%s(.+)$")
	if maker == nil then return nil, name end
	return maker, rest
end

function systems_view_input()
	local l = SYSTEMS_VIEW.list
	if list_input(l, true) then play_sfx(S_MOVER) end
	if input_pressed("cross") then
		play_sfx(S_EJECUTAR)
		gamelist_open(list_current(l))
	elseif input_pressed("start") then
		play_sfx(S_EJECUTAR)
		main_menu_open()
	end
end

function systems_view_draw()
	local total = 0
	for i = 1, #LIBRARY.systems do total = total + #LIBRARY.systems[i].games end
	draw_header(#LIBRARY.systems .." systems   ".. total .." games")
	draw_systems_column(true)

	local s = systems_view_current()
	local d = THEME.detail
	if s ~= nil then
		local maker, long = split_name(s.name)
		local y = THEME.header_h + 18
		if maker ~= nil then
			gfx_text(maker, d.x, y, THEME.size_small, THEME.text_dim)
			y = y + 14
		end
		gfx_text(gfx_fit(system_short_name(s), THEME.size_head, d.w), d.x, y, THEME.size_head, THEME.text_head)
		y = y + 22
		if long ~= system_short_name(s) then
			gfx_text(gfx_fit(long, THEME.size_small, d.w), d.x, y, THEME.size_small, THEME.text_dim)
			y = y + 14
		end
		y = y + 6
		local ata, usb, warn = 0, 0, 0
		for i = 1, #s.games do
			local g = s.games[i]
			if g.ata then ata = ata + 1 else usb = usb + 1 end
			if g.warn ~= nil then warn = warn + 1 end
		end
		gfx_text(#s.games .." games", d.x, y, THEME.size_text, THEME.text)
		y = y + 20
		local x = d.x
		if ata > 0 then
			gfx_text(ata .." on exFAT", x, y, THEME.size_small, THEME.exfat)
			x = x + gfx_text_w(ata .." on exFAT   ", THEME.size_small)
		end
		if usb > 0 then
			gfx_text(usb .." on USB", x, y, THEME.size_small, THEME.usb)
			x = x + gfx_text_w(usb .." on USB   ", THEME.size_small)
		end
		if warn > 0 then
			gfx_text(warn .." cannot run", x, y, THEME.size_small, THEME.warn)
		end
		y = y + 22
		-- Backends of the system, from systems.lua.
		local sys = SYSTEMS[s.folder]
		if sys ~= nil then
			local names = {}
			for i = 1, #sys.backends do names[#names + 1] = sys.backends[i].name end
			gfx_text(gfx_fit("via ".. table.concat(names, ", "), THEME.size_small, d.w), d.x, y, THEME.size_small, THEME.text_dim)
			y = y + 26
		end
		-- A strip of covers: the first games that have one.
		local shown, gx = 0, d.x
		local box = 96
		for i = 1, math.min(#s.games, 40) do
			if shown >= 4 then break end
			local art = library_art(s.games[i], "covers")
			if art ~= nil then
				gfx_rect(gx, y, box, box, THEME.panel)
				gfx_image_fit(art, gx + 3, y + 3, box - 6, box - 6)
				gx = gx + box + 10
				shown = shown + 1
			end
		end
		if shown == 0 then
			gfx_text("No artwork yet: Roms/".. s.folder .."/media/covers/", d.x, y, THEME.size_small, THEME.text_dim)
		end
	else
		gfx_text("No games found.", d.x, THEME.header_h + 30, THEME.size_text, THEME.text)
		gfx_text("Put ROMs in Roms/<system>/, PS1 in POPS/ or Ember/games/, PS2 in DVD/ or CD/.",
			d.x, THEME.header_h + 56, THEME.size_small, THEME.text_dim)
	end

	draw_footer({ {"cross", "open"}, {"START", "menu"} })
end
