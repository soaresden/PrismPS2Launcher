-- Prism PS2 Launcher - views/gamelist.lua
-- The detailed game list: systems on the left, games in the middle, everything known
-- about the selected game on the right - screenshot, cover, what the scraper found,
-- and the line that matters most, how this particular game is going to be run.
--
-- A title is coloured by where the file lives: cyan on the USB stick, yellow on the
-- internal drive, red when nothing on the console can open it. That is one glance
-- instead of one menu.

GAMELIST = { system = nil, list = nil, menu = nil }

--- Marks at the right of a row. ---------------------------------------------------------
local MARK_FAV  = "*"
local MARK_TODO = "+"

--- The three picture slots of the game column, and what can go in them. ---------------
--- A is the square beside the title, B and C the pair underneath. Everything is drawn
--- from Roms/<system>/media/<kind>/, so a slot is just the name of a folder.
ART_SLOTS  = { "a", "b", "c" }
ART_KINDS  = { "cartridges", "covers", "screenshots", "wheels", "none" }
ART_LABELS = { "Cartridge", "Box art", "Screenshot", "Wheel", "Nothing" }

function slot_art(g, slot)
	local kind = prefs_get("art_".. slot)
	if kind == nil or kind == "none" then return nil end
	return library_art(g, kind)
end

function slot_label(slot)
	local kind = prefs_get("art_".. slot)
	for i = 1, #ART_KINDS do
		if ART_KINDS[i] == kind then return ART_LABELS[i] end
	end
	return "?"
end

--- Where this game's saves live, and which memory card it will use. -------------------
--- Two lines at the foot of the column, because it is the question nobody thinks to
--- ask until a save is missing, and by then it is too late to ask it.
function game_saves_info(g)
	if g.kind == "psx" then
		local id = prefs_backend(g)
		if id == "ember" and g.ember ~= nil then
			local root = ember_game(g.ember)
			return "Ember shared card", (root or "Ember") .."/MC1.vmc"
		end
		if g.vcd ~= nil then
			local drive = POPS_DE(g.file)
			return "POPStarter card", drive .."/POPS/".. g.stem .."/SLOT0.VMC"
		end
		return "Memory card", "created on first run"
	elseif g.kind == "ps2" then
		local drive = string.match(g.dir or "", "^[^:]+:") or "mass0:"
		local arg = nil
		if vmc_auto ~= nil then
			local ok, v = pcall(vmc_auto, g.file, drive)
			if ok then arg = v end
		end
		if arg ~= nil then
			return "Memory card", string.gsub(arg, "^%-mc0=", "")
		end
		return "Memory card", "real card in slot 1"
	end
	-- Everything libretro: RetroArch is pointed at these two, per system.
	return "Saves", "Saves/".. g.kind .."/  and SaveStates/".. g.kind .."/"
end

function gamelist_open(system)
	if system == nil then return end
	GAMELIST.system = system
	local rows = math.floor((view_list_bottom() - view_list_top() - 26) / THEME.row_h)
	if GAMELIST.list == nil then GAMELIST.list = list_new(system.games, rows) end
	GAMELIST.list.rows = rows
	list_set(GAMELIST.list, system.games)
	GAMELIST.list.sel, GAMELIST.list.top = 1, 1
	VIEW = "gamelist"
	if system.virtual ~= true and prefs_get("last_system") ~= system.folder then
		prefs_set("last_system", system.folder)
	end
	input_flush()
end

function gamelist_current()
	if GAMELIST.list == nil then return nil end
	return list_current(GAMELIST.list)
end

--- L1 / R1: the previous or next system that has games, without leaving the list. ------
local function step_system(dir)
	local l = SYSTEMS_VIEW.list
	local n = #l.items
	if n == 0 then return end
	for _try = 1, n do
		l.sel = l.sel + dir
		if l.sel < 1 then l.sel = n end
		if l.sel > n then l.sel = 1 end
		if #l.items[l.sel].games > 0 then break end
	end
	list_scroll(l)
	gamelist_open(list_current(l))
end

--- How a game will run: the backend's name, its id, and the colour to write it in. -----
function gamelist_backend_text(game)
	local sys = SYSTEMS[game.kind]
	if game.warn == "chd" then return "CHD - no emulator on the PS2 reads this", nil, THEME.warn end
	if game.warn == "loose" then return "No PS2 emulator reads this - make a .VCD", nil, THEME.warn end
	local id = prefs_backend(game)
	if game.kind == "psx" then
		-- POPStarter reads a .VCD and nothing else; Ember reads a .cue/.bin folder and
		-- nothing else. So the file decides, and a stored choice that the file cannot
		-- honour is quietly corrected rather than obeyed into a black screen.
		if id == "ember" and game.ember == nil then id = "pops" end
		if id == "pops" and game.vcd == nil then id = "ember" end
		if id == "ember" then return "Ember", id, THEME.ember end
		return "POPStarter", "pops", THEME.pops
	end
	if sys ~= nil then
		for i = 1, #sys.backends do
			if sys.backends[i].id == id then return sys.backends[i].name, id, THEME.text end
		end
		local b = backends_for(game.kind, game.file)
		if #b > 0 then return b[1].name, b[1].id, THEME.text end
	end
	return "no emulator", nil, THEME.warn
end

--- Input -----------------------------------------------------------------------------------
function gamelist_input()
	if GAMELIST.menu ~= nil then
		local r = menu_input(GAMELIST.menu)
		if r == "close" or r == "launch" then
			if r == "close" then play_sfx(S_CANCELAR) end
			GAMELIST.menu = nil
			input_flush()
		elseif r == "changed" or r == "action" then
			play_sfx(S_MOVER)
		end
		return
	end
	local l = GAMELIST.list
	if list_input(l, true) then play_sfx(S_MOVER) end
	if input_pressed("l1") then
		play_sfx(S_NETX); step_system(-1)
	elseif input_pressed("r1") then
		play_sfx(S_NETX); step_system(1)
	elseif input_pressed("select") then
		local g = list_current(l)
		if g ~= nil then
			play_sfx(S_NETX)
			collections_toggle_fav(g)
			-- Inside the Favourites list, un-favouriting removes the row under the bar.
			if GAMELIST.system.virtual == true then
				GAMELIST.system = LIBRARY.by_folder[GAMELIST.system.folder]
				list_set(l, GAMELIST.system.games)
			end
		end
	elseif input_pressed("circle") then
		play_sfx(S_CANCELAR)
		VIEW = "systems"
		input_flush()
	elseif input_pressed("cross") then
		local g = list_current(l)
		if g ~= nil then
			play_sfx(S_EJECUTAR)
			launch_view_open(g)
		end
	elseif input_pressed("triangle") then
		local g = list_current(l)
		if g ~= nil then
			play_sfx(S_EJECUTAR)
			GAMELIST.menu = game_menu_new(g)
			input_flush()
		end
	elseif input_pressed("square") then
		-- The pictures, full screen. The memory card kept this button for a while and
		-- has gone back to the game menu, where the rest of a game's settings live.
		local g = list_current(l)
		if g ~= nil and viewer_open(g) then
			play_sfx(S_EJECUTAR)
		else
			play_sfx(S_CANCELAR)
		end
	elseif input_pressed("start") then
		play_sfx(S_EJECUTAR)
		main_menu_open()
	end
end

--- One line of the facts block: dim label, then the value. -----------------------------
local function fact(x, y, w, label, value)
	if value == nil or value == "" then return y end
	local size = THEME.size_small
	gfx_text(label, x, y, size, THEME.text_dim)
	local lw = 58
	gfx_text(gfx_fit(tostring(value), size, w - lw), x + lw, y, size, THEME.text)
	return y + 12
end

function gamelist_draw()
	local s = GAMELIST.system
	local right = s.name
	if s.virtual ~= true then right = system_maker(s) .." - ".. system_short_name(s) end
	draw_header(right)
	draw_systems_column(false)

	local L = THEME.list
	local top = view_list_top() + 4

	-- The list's own title line: which system, how many games.
	gfx_text_scroll(system_label(s), L.x, top, THEME.size_text, THEME.text_head, L.w - 60)
	gfx_text(games_count(#s.games), L.x, top + 2, THEME.size_small, THEME.text_dim, "right", L.w)

	-- The games. Colour says where the file is; the marks say what you decided about it.
	local ly = top + 20
	local l = GAMELIST.list
	local size = THEME.size_text
	for r = 0, l.rows - 1 do
		local i = l.top + r
		local g = l.items[i]
		if g == nil then break end
		local ry = ly + r * THEME.row_h
		local _w, color = library_where(g)
		if g.warn ~= nil then color = THEME.warn end
		if i == l.sel then
			gfx_rect(L.x, ry, L.w, THEME.row_h, THEME.selector)
			gfx_rect(L.x, ry, 3, THEME.row_h, THEME.selector_edge)
		end
		local marks = ""
		if collections_is_fav(g) then marks = MARK_FAV end
		if collections_is_todo(g) then marks = marks .. MARK_TODO end
		local room = L.w - 16 - gfx_text_w(marks, size)
		local ty = ry + (THEME.row_h - size) / 2
		if i == l.sel then
			-- Only the row under the bar scrolls. A whole list in motion is unreadable,
			-- and the one you are looking at is the one whose full name you want.
			gfx_text_scroll(g.title, L.x + 8, ty, size, color, room)
		else
			gfx_text(gfx_fit(g.title, size, room), L.x + 8, ty, size, color)
		end
		if marks ~= "" then
			gfx_text(marks, L.x, ry + (THEME.row_h - size) / 2, size, THEME.exfat, "right", L.w - 6)
		end
	end
	if #l.items > l.rows then
		local small = THEME.size_small
		if l.top > 1 then gfx_text("^", L.x + L.w - 10, ly - small - 1, small, THEME.text_dim) end
		if l.top + l.rows - 1 < #l.items then
			gfx_text("v", L.x + L.w - 10, ly + l.rows * THEME.row_h, small, THEME.text_dim)
		end
	end

	-- The selected game, in four bands.
	local g = gamelist_current()
	local D = THEME.detail
	if g ~= nil then
		local small, text = THEME.size_small, THEME.size_text
		local y = top

		local function rule(ry)
			gfx_rect(D.x, ry, D.w, 1, THEME.line)
		end
		local function picture(px, py, pw, ph, path, slot)
			gfx_rect(px, py, pw, ph, THEME.panel)
			if gfx_image_fit(path, px + 2, py + 2, pw - 4, ph - 4) == false then
				gfx_text(string.lower(slot_label(slot)), px, py + ph / 2 - 5, small,
					THEME.text_dim, "center", pw)
			end
		end

		-- A | the name of the game.
		local a = THEME.art_a
		picture(D.x, y, a, a, slot_art(g, "a"), "a")
		local nx = D.x + a + 8
		local nw = D.w - a - 8
		gfx_text_scroll(g.title, nx, y + 2, text, THEME.text_head, nw)
		local sub = system_short_name(GAMELIST.system)
		if GAMELIST.system.virtual == true then sub = SYSTEM_INFO[g.kind] and SYSTEM_INFO[g.kind].short or g.kind end
		if g.year ~= nil then sub = sub .."   ".. g.year end
		gfx_text(gfx_fit(sub, small, nw), nx, y + 20, small, THEME.text_dim)
		local where, wcol = library_where(g)
		gfx_text(where, nx, y + 34, small, wcol)
		local how, _id, hcol = gamelist_backend_text(g)
		gfx_text(gfx_fit(how, small, nw - 58), nx + 56, y + 34, small, hcol)
		local marks = ""
		if collections_is_fav(g) then marks = "favourite" end
		if collections_is_todo(g) then
			if marks ~= "" then marks = marks .."  -  " end
			marks = marks .."to finish"
		end
		if marks ~= "" then
			gfx_text(gfx_fit(marks, small, nw), nx, y + 46, small, THEME.exfat)
		end
		y = y + a + 6
		rule(y)
		y = y + 6

		-- B | C.
		local half = (D.w - 6) / 2
		picture(D.x, y, half, THEME.art_row, slot_art(g, "b"), "b")
		picture(D.x + half + 6, y, half, THEME.art_row, slot_art(g, "c"), "c")
		y = y + THEME.art_row + 6
		rule(y)
		y = y + 6

		-- The saves band is measured from the bottom, so the description knows exactly
		-- how much room is left and never runs into it.
		local saves_y = view_list_bottom() - THEME.saves_h
		if g.desc ~= nil then
			local room = math.floor((saves_y - 8 - y) / 11)
			local lines = gfx_wrap(g.desc, small, D.w, room)
			for i = 1, #lines do
				gfx_text(lines[i], D.x, y, small, THEME.text)
				y = y + 11
			end
		else
			gfx_text("No gamelist.xml for this system yet.", D.x, y, small, THEME.text_dim)
			gfx_text("Scrape Roms/".. g.kind .."/ with ARRM or", D.x, y + 12, small, THEME.text_dim)
			gfx_text("Skraper, or run HelperScripts/BatoceraGamelistandMediaCopier.py.", D.x, y + 24, small, THEME.text_dim)
		end

		-- Where the saves go, and which memory card. The line that matters tomorrow.
		rule(saves_y)
		local label, path = game_saves_info(g)
		gfx_text(label, D.x, saves_y + 6, small, THEME.text_dim)
		gfx_text_scroll(path, D.x, saves_y + 18, small, THEME.text, D.w)
		gfx_text_scroll(g.file, D.x, saves_y + 31, small, THEME.text_dim, D.w)
	end

	local hints = { {"cross", "play"}, {"triangle", "game menu"}, {"square", "pictures"} }
	hints[#hints + 1] = {"select", "favourite"}
	hints[#hints + 1] = {"l1", ""}
	hints[#hints + 1] = {"r1", "system"}
	hints[#hints + 1] = {"circle", "back"}
	draw_footer(hints)

	if GAMELIST.menu ~= nil then
		dim_screen()
		menu_draw(GAMELIST.menu)
	end
end

--- The PlayStation memory card, on its own (square). ----------------------------------
--- PS2 keeps a file per game under VMC/ and it is chosen here. PS1 has no such choice:
--- POPStarter writes SLOT0.VMC inside the game's own folder and Ember shares one card
--- for everything, so what decides where a PS1 save lands is which of the two runs it -
--- and that is the option this menu offers instead. Saying so is more use than an
--- empty box.
function card_menu_new(g)
	local opts = {}
	local label, path = game_saves_info(g)
	opts[#opts + 1] = { label = label, kind = "info", get = function() return path end }

	if g.kind == "psx" then
		local values, ids = {}, {}
		if g.vcd ~= nil then values[#values + 1] = "POPStarter"; ids[#ids + 1] = "pops" end
		if g.ember ~= nil then values[#values + 1] = "Ember"; ids[#ids + 1] = "ember" end
		if #values > 1 then
			opts[#opts + 1] = { label = "Play with", kind = "choice", values = values,
				get = function()
					local cur = prefs_backend(g)
					for i = 1, #ids do if ids[i] == cur then return i end end
					return 1
				end,
				set = function(v) prefs_set_backend(g, ids[v]) end }
			opts[#opts + 1] = { label = "", kind = "info",
				get = function() return "each keeps its own save" end }
		else
			opts[#opts + 1] = { label = "", kind = "info",
				get = function() return "made for you on first run" end }
		end
	else
		local n = #opts
		ps2_card_options(g, opts)
		if #opts == n then
			opts[#opts + 1] = { label = "", kind = "info",
				get = function() return "no game ID in the file name" end }
		end
	end
	return menu_new(gfx_fit(g.title, THEME.size_head, 400), opts)
end

--- The PS2 card choice, shared by the card menu and the full game menu. ---------------
function ps2_card_options(g, opts)
	if vmc_id == nil then return end
	local id = vmc_id(g.file)
	if id == nil then return end
	vmc_cfg_load()
	local cards, own = vmc_candidates(id)
	local values, choices = {}, {}
	for i = 1, #cards do
		local label = string.match(cards[i], "([^/]+)$") or cards[i]
		if i <= own then label = "* ".. label end
		values[#values + 1] = label
		choices[#choices + 1] = cards[i]
	end
	values[#values + 1] = "Real card (slot 1)"; choices[#choices + 1] = "none"
	opts[#opts + 1] = { label = "Memory card", kind = "choice", values = values,
		get = function()
			local cur = VMC_GAMES[id]
			if cur == nil then
				if own >= 1 then return 1 end
				return #choices
			end
			for i = 1, #choices do if choices[i] == cur then return i end end
			return #choices
		end,
		set = function(v)
			VMC_GAMES[id] = choices[v]
			if log_event ~= nil then log_event("VMC", id .." -> ".. tostring(choices[v])) end
			vmc_cfg_save()
		end }

	local drive = string.match(g.dir or "", "^[^:]+:") or "mass0:"
	local n = 1
	local new_name = vmc_new_name(g.file, n)
	while new_name ~= nil and doesFileExist(drive .."/VMC/".. new_name) and n < 20 do
		n = n + 1
		new_name = vmc_new_name(g.file, n)
	end
	if new_name ~= nil then
		opts[#opts + 1] = { label = "Create a card", kind = "action", action = function()
			local created = vmc_create(drive, new_name)
			if created == nil then
				if log_event ~= nil then log_event("VMC", "could not create ".. new_name) end
				return "close"
			end
			VMC_GAMES[id] = created
			vmc_cfg_save()
			table.insert(choices, 1, created)
			table.insert(values, 1, "* ".. new_name)
			own = own + 1
			return nil
		end }
	end
end

--- The game menu (triangle) --------------------------------------------------------------
function game_menu_new(g)
	local opts = {}
	local sys = SYSTEMS[g.kind]
	opts[#opts + 1] = { label = "File", kind = "info",
		get = function() return g.file end }
	opts[#opts + 1] = { label = "Where", kind = "info",
		get = function()
			local w = library_where(g)
			return w .."   ".. tostring(g.dir)
		end }

	if g.kind == "psx" then
		local values, ids = {}, {}
		if g.vcd ~= nil then values[#values + 1] = "POPStarter"; ids[#ids + 1] = "pops" end
		if g.ember ~= nil then values[#values + 1] = "Ember"; ids[#ids + 1] = "ember" end
		if #values >= 1 then
			opts[#opts + 1] = { label = "Play with", kind = "choice", values = values,
				get = function()
					local cur = prefs_backend(g)
					for i = 1, #ids do if ids[i] == cur then return i end end
					return 1
				end,
				set = function(v) prefs_set_backend(g, ids[v]) end }
		end
	elseif sys ~= nil then
		local b = backends_for(g.kind, g.file)
		if #b > 1 then
			local values, ids = {}, {}
			for i = 1, #b do values[#values + 1] = b[i].name; ids[#ids + 1] = b[i].id end
			opts[#opts + 1] = { label = "Emulator / core", kind = "choice", values = values,
				get = function()
					local cur = prefs_backend(g)
					for i = 1, #ids do if ids[i] == cur then return i end end
					return 1
				end,
				set = function(v) prefs_set_backend(g, ids[v]) end }
		end
	end

	if g.kind == "ps2" then
		ps2_card_options(g, opts)
	end

	opts[#opts + 1] = { label = "Favourite", kind = "toggle",
		get = function() return collections_is_fav(g) end,
		set = function(_v) collections_toggle_fav(g) end }
	opts[#opts + 1] = { label = "To finish", kind = "toggle",
		get = function() return collections_is_todo(g) end,
		set = function(_v) collections_toggle_todo(g) end }
	opts[#opts + 1] = { label = "Launch", kind = "action", action = function()
		launch_view_open(g)
		return "launch"
	end }
	return menu_new(g.title, opts)
end
