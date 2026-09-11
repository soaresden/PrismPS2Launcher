-- Prism PS2 Launcher - views/systems.lua
-- The systems view: the column of systems on the left, what is known about the selected
-- one on the right. The column is shared with the gamelist view (drawn dimmed there),
-- so it lives here, and so do the header, the footer and the colour legend.

SYSTEMS_VIEW = { list = nil }

--- The band the interface lives in: from the real top edge to the real bottom one.
--- On NTSC that is 0..448, on PAL -32..480. Everything vertical measures against
--- these, so nothing floats with a strip of background under it.
function view_top()    return gfx_top() end
function view_bottom() return gfx_bottom() end
function view_list_top()    return gfx_top() + THEME.header_h end
function view_list_bottom() return gfx_bottom() - THEME.footer_h end

function systems_view_init()
	local rows = math.floor((view_list_bottom() - view_list_top() - 8) / THEME.row_h)
	SYSTEMS_VIEW.list = list_new(LIBRARY.systems, rows)
end

function systems_view_current()
	return list_current(SYSTEMS_VIEW.list)
end

--- Header, on every view. ---------------------------------------------------------------
function draw_header(right_text)
	local top = view_top()
	gfx_rect(0, top, 640, THEME.header_h, THEME.panel_hi)
	gfx_rect(0, top + THEME.header_h - 1, 640, 1, THEME.line)
	gfx_text("PRISM", THEME.pad, top + 5, THEME.size_head, THEME.text_head)
	if right_text ~= nil then
		-- Right-aligned inside the band, never past the safe margin.
		gfx_text(gfx_fit(right_text, THEME.size_small, 400), 230, top + 8, THEME.size_small,
			THEME.text_dim, "right", 640 - 230 - THEME.pad)
	end
end

--- Footer. hints: array of { button, label }. ------------------------------------------
function draw_footer(hints)
	local y = gfx_bottom() - THEME.footer_h
	gfx_rect(0, y, 640, THEME.footer_h, THEME.panel)
	gfx_rect(0, y, 640, 1, THEME.line)
	local x = THEME.pad
	for i = 1, #hints do
		x = gfx_hint(x, y + 4, hints[i][1], hints[i][2])
	end
	return x
end

--- The colour legend: what yellow, cyan and red mean in a game list. -------------------
--- Drawn once, where there is room, because a colour that has to be explained in a
--- manual is a colour that failed.
function draw_legend(x, y)
	local size = THEME.size_small
	local function box(cx, color, label)
		gfx_rect(cx, y + 1, 8, 8, color)
		gfx_text(label, cx + 12, y, size, THEME.text_dim)
		return cx + 12 + gfx_text_w(label, size) + 14
	end
	local cx = x
	cx = box(cx, THEME.usb, "on USB")
	cx = box(cx, THEME.exfat, "on the internal drive")
	cx = box(cx, THEME.warn, "nothing can open it")
	return cx
end

--- The systems column. focused = false dims the bar (the gamelist has the focus). -----
function draw_systems_column(focused)
	local col = THEME.systems_col
	local top = view_list_top() + 4
	local h = view_list_bottom() - view_list_top()
	gfx_rect(col.x, view_list_top(), col.w, h, THEME.panel)
	gfx_rect(col.x + col.w - 1, view_list_top(), 1, h, THEME.line)

	local l = SYSTEMS_VIEW.list
	local size = THEME.size_text
	local ico = THEME.icon
	for r = 0, l.rows - 1 do
		local i = l.top + r
		local s = l.items[i]
		if s == nil then break end
		local ry = top + r * THEME.row_h
		local color = THEME.text
		if s.virtual == true then color = THEME.text_head end
		if i == l.sel then
			local bar = THEME.selector
			if focused == false then bar = THEME.panel_hi end
			gfx_rect(col.x, ry, col.w - 1, THEME.row_h, bar)
			gfx_rect(col.x, ry, 3, THEME.row_h, THEME.selector_edge)
			color = THEME.text_sel
		end
		-- A manufacturer colour, not a logo. A console logo squeezed into twenty pixels
		-- is a smudge you cannot name; a red bar means Nintendo from across the room,
		-- and it groups the column the way the eye already wants to group it. The real
		-- logo is in the panel on the right, at a size where it is worth looking at.
		local tx = col.x + 8
		local ty = ry + (THEME.row_h - size) / 2
		if s.virtual == true then
			local mark = "*"
			if s.folder == "@recent" then mark = "." end
			gfx_text(mark, tx + 2, ty, size, THEME.exfat)
		else
			gfx_rect(tx, ry + 5, 4, THEME.row_h - 10, system_color(s))
		end
		tx = tx + 12
		-- "megadrive - Sega Mega Drive" does not fit in a 170 pixel column, and the half
		-- that gets cut is the half that names the machine. The selected line walks past
		-- instead; the others keep still, or the whole column would be in motion.
		local room = col.w - 20 - 12
		if i == l.sel then
			gfx_text_scroll(system_label(s), tx, ty, size, color, room)
		else
			gfx_text(gfx_fit(system_label(s), size, room), tx, ty, size, color)
		end
	end

	if #l.items > l.rows then
		local small = THEME.size_small
		if l.top > 1 then gfx_text("^", col.x + col.w - 12, top - small - 1, small, THEME.text_dim) end
		if l.top + l.rows - 1 < #l.items then
			gfx_text("v", col.x + col.w - 12, top + l.rows * THEME.row_h, small, THEME.text_dim)
		end
	end
end

--- Input ---------------------------------------------------------------------------------
function systems_view_input()
	local l = SYSTEMS_VIEW.list
	if list_input(l, true) then play_sfx(S_MOVER) end
	if input_pressed("cross") then
		local s = list_current(l)
		if s ~= nil and #s.games > 0 then
			play_sfx(S_EJECUTAR)
			gamelist_open(s)
		else
			play_sfx(S_CANCELAR)
		end
	elseif input_pressed("select") then
		play_sfx(S_NETX)
		systems_next_sort()
	elseif input_pressed("start") then
		play_sfx(S_EJECUTAR)
		main_menu_open()
	end
end

--- Cycles folder -> manufacturer -> year, keeping the selected system selected. --------
function systems_next_sort()
	local cur = prefs_get("sort")
	local n = 1
	for i = 1, #SORT_MODES do if SORT_MODES[i] == cur then n = i end end
	n = n + 1
	if n > #SORT_MODES then n = 1 end
	systems_set_sort(SORT_MODES[n])
end

function systems_set_sort(mode)
	local l = SYSTEMS_VIEW.list
	local keep = list_current(l)
	prefs_set("sort", mode)
	collections_sort_systems(mode)
	list_set(l, LIBRARY.systems)
	if keep ~= nil then
		for i = 1, #LIBRARY.systems do
			if LIBRARY.systems[i].folder == keep.folder then l.sel = i end
		end
		list_scroll(l)
	end
end

function sort_label()
	local cur = prefs_get("sort")
	for i = 1, #SORT_MODES do if SORT_MODES[i] == cur then return SORT_LABELS[i] end end
	return SORT_LABELS[1]
end

--- Draw -----------------------------------------------------------------------------------
function systems_view_draw()
	local total = 0
	for i = 1, #LIBRARY.systems do
		if LIBRARY.systems[i].virtual ~= true then total = total + #LIBRARY.systems[i].games end
	end
	local real = 0
	for i = 1, #LIBRARY.systems do
		if LIBRARY.systems[i].virtual ~= true then real = real + 1 end
	end
	trace("systems: header")
	draw_header(real .." systems   ".. total .." games   -   sorted by ".. string.lower(sort_label()))
	trace("systems: column")
	draw_systems_column(true)

	local s = systems_view_current()
	trace("systems: panel ".. tostring(s and s.folder))
	local dx = THEME.list.x
	local dw = 640 - dx - THEME.pad
	local y = view_list_top() + THEME.pad

	if s == nil then
		gfx_text("No games found.", dx, y, THEME.size_head, THEME.text_head)
		gfx_text("Roms/<system>/ for cartridges, POPS/ for PlayStation 1 .VCD,", dx, y + 26, THEME.size_small, THEME.text_dim)
		gfx_text("Ember/games/<Game>/ for .cue, DVD/ and CD/ for PlayStation 2.", dx, y + 38, THEME.size_small, THEME.text_dim)
		draw_footer({ {"cross", "open"}, {"select", "sort"}, {"start", "menu"} })
		return
	end

	if s.virtual == true then
		gfx_text(s.name, dx, y, THEME.size_head, THEME.text_head)
		y = y + 26
		gfx_text(s.note or "", dx, y, THEME.size_small, THEME.text_dim)
		y = y + 22
		gfx_text(#s.games .." games", dx, y, THEME.size_text, THEME.text)
		y = y + 30
		if #s.games == 0 and s.folder == "@todo" then
			gfx_text("Nothing here yet. Open a game list, press triangle on a game", dx, y, THEME.size_small, THEME.text_dim)
			gfx_text("you mean to finish, and pick \"To finish\".", dx, y + 13, THEME.size_small, THEME.text_dim)
			y = y + 34
		end
	else
		-- The machine, not its games: a picture of the console, its logo, and the few
		-- facts worth knowing about it. The PlayStation-X theme does this, and it is
		-- the right idea - a system screen should be about the system.
		local small, text = THEME.size_small, THEME.size_text
		local photo_w, photo_h = 210, 150
		local px = 640 - THEME.pad - photo_w
		trace("systems: photo ".. tostring(system_photo(s)))
		if gfx_image_fit(system_photo(s), px, y, photo_w, photo_h) == false then
			trace("systems: no photo, trying the logo")
			-- No photograph: the console's own logo takes the space instead, and if
			-- there is not even that, a plain plate in the manufacturer's colour.
			if gfx_image_fit(system_logo(s), px, y + 40, photo_w, 70) == false then
				gfx_rect(px, y + 30, photo_w, 90, THEME.panel)
				gfx_rect(px, y + 30, 4, 90, system_color(s))
				gfx_text(system_short_name(s), px, y + 68, text, THEME.text_dim, "center", photo_w)
			end
		end
		trace("systems: picture done")

		local tw = px - dx - 14                      -- text column, left of the photo
		gfx_text(gfx_fit(system_short_name(s), THEME.size_head, tw), dx, y, THEME.size_head, THEME.text_head)
		y = y + 24
		gfx_rect(dx, y, 28, 3, system_color(s))
		y = y + 10
		local line = system_maker(s)
		if system_year(s) ~= nil then line = line .."   ".. system_year(s) end
		gfx_text(line, dx, y, small, THEME.text_dim)
		y = y + 14

		local about = SYSTEM_ABOUT[s.folder]
		if about ~= nil then
			if about.cpu ~= nil then
				gfx_text(gfx_fit(about.cpu, small, tw), dx, y, small, THEME.text)
				y = y + 12
			end
			if about.units ~= nil then
				gfx_text(gfx_fit(about.units .." sold", small, tw), dx, y, small, THEME.text_dim)
				y = y + 12
			end
		end
		y = y + 6
		gfx_text("Roms/".. s.folder .."/", dx, y, small, THEME.text_dim)
		y = y + 18

		-- Where its games are, in the colours the lists use.
		local ata, usb, warn = 0, 0, 0
		for i = 1, #s.games do
			local g = s.games[i]
			if g.ata then ata = ata + 1 else usb = usb + 1 end
			if g.warn ~= nil then warn = warn + 1 end
		end
		gfx_text(#s.games .." games", dx, y, text, THEME.text_head)
		y = y + 18
		if usb > 0 then
			gfx_text(usb .." on USB", dx, y, small, THEME.usb)
			y = y + 12
		end
		if ata > 0 then
			gfx_text(ata .." on the internal drive", dx, y, small, THEME.exfat)
			y = y + 12
		end
		if warn > 0 then
			gfx_text(warn .." unplayable", dx, y, small, THEME.warn)
			y = y + 12
		end

		-- Below both columns: what runs it here, then the console's own story.
		y = math.max(y, view_list_top() + THEME.pad + photo_h) + 12
		local sys = SYSTEMS[s.folder]
		if sys ~= nil then
			local names = {}
			for i = 1, #sys.backends do names[#names + 1] = sys.backends[i].name end
			gfx_text(gfx_fit("Runs with ".. table.concat(names, ", "), small, dw),
				dx, y, small, THEME.ok)
			y = y + 18
		end
		if about ~= nil and about.desc ~= nil then
			local bottom = view_list_bottom() - 22
			local lines = gfx_wrap(about.desc, small, dw, math.floor((bottom - y) / 12))
			for i = 1, #lines do
				gfx_text(lines[i], dx, y, small, THEME.text)
				y = y + 12
			end
		end
	end

	trace("systems: legend")
	draw_legend(dx, view_list_bottom() - 14)
	trace("systems: footer")
	draw_footer({ {"cross", "open"}, {"select", "sort"}, {"start", "menu"} })
	trace("systems: done")
end
