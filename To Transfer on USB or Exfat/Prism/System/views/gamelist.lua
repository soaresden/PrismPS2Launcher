-- Prism PS2 Launcher - views/gamelist.lua
-- The detailed game list of one system: list in the middle, cover and screenshot on the
-- right, where the file lives and how it will run underneath. L1/R1 change system
-- without leaving the view. Triangle opens the game menu; cross launches.

GAMELIST = { system = nil, list = nil, menu = nil }

function gamelist_open(system)
	if system == nil then return end
	GAMELIST.system = system
	local rows = math.floor((448 - THEME.header_h - 30 - THEME.footer_h - 28) / THEME.row_h)
	if GAMELIST.list == nil then GAMELIST.list = list_new(system.games, rows) end
	list_set(GAMELIST.list, system.games)
	GAMELIST.list.sel, GAMELIST.list.top = 1, 1
	VIEW = "gamelist"
	if prefs_get("last_system") ~= system.folder then prefs_set("last_system", system.folder) end
	input_flush()
end

function gamelist_current()
	if GAMELIST.list == nil then return nil end
	return list_current(GAMELIST.list)
end

--- Switch to the previous/next system that has games, staying in the list. -----------
local function step_system(dir)
	local l = SYSTEMS_VIEW.list
	local n = #l.items
	if n == 0 then return end
	l.sel = l.sel + dir
	if l.sel < 1 then l.sel = n end
	if l.sel > n then l.sel = 1 end
	list_scroll(l)
	gamelist_open(list_current(l))
end

--- How a game will run: backend name, and whether a choice exists. -------------------
--- Returns display text, the backend id, and the colour of the text.
function gamelist_backend_text(game)
	local sys = SYSTEMS[game.kind]
	if game.warn == "chd" then return "CHD: no emulator on PS2 reads this", nil, THEME.warn end
	local id = prefs_backend(game)
	if game.kind == "psx" then
		if id == "ember" and game.ember == nil then id = "pops" end
		if id == "pops" and game.vcd == nil then id = "ember" end
		if id == "ember" then return "Ember", id, THEME.text end
		return "POPStarter", "pops", THEME.text
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
	elseif input_pressed("start") then
		play_sfx(S_EJECUTAR)
		main_menu_open()
	end
end

function gamelist_draw()
	local s = GAMELIST.system
	draw_header(s.name)
	draw_systems_column(false)

	local d = THEME.detail
	local lx, lw = d.x, THEME.list_w
	local top = THEME.header_h + 6
	-- Title strip above the list.
	gfx_text(gfx_fit(s.name, THEME.size_text, lw), lx, top, THEME.size_text, THEME.text_head)
	gfx_text(#s.games .." games", lx, top + 2, THEME.size_small, THEME.text_dim, "right", lw)
	local ly = top + 24
	list_draw(GAMELIST.list, lx, ly, lw, THEME.row_h, function(g)
		local col = THEME.text
		if g.warn ~= nil then col = THEME.warn end
		return g.title, col
	end, true)

	-- Right panel: artwork and facts about the selected game.
	local g = gamelist_current()
	local px = lx + lw + 12
	local pw = 640 - px - 12
	if g ~= nil then
		local cy = top
		local cw = math.min(THEME.cover.w, pw)
		gfx_rect(px, cy, cw, THEME.cover.h, THEME.panel)
		if gfx_image_fit(library_art(g, "covers"), px + 3, cy + 3, cw - 6, THEME.cover.h - 6) == false then
			gfx_text("no cover", px, cy + THEME.cover.h / 2 - 5, THEME.size_small, THEME.text_dim, "center", cw)
		end
		local sy = cy + THEME.cover.h + 6
		gfx_rect(px, sy, cw, THEME.screenshot.h, THEME.panel)
		if gfx_image_fit(library_art(g, "screenshots"), px + 3, sy + 3, cw - 6, THEME.screenshot.h - 6) == false then
			gfx_text("no screenshot", px, sy + THEME.screenshot.h / 2 - 5, THEME.size_small, THEME.text_dim, "center", cw)
		end
		-- From gamelist.xml, when a scraper has been through: facts, then the description.
		local ty = sy + THEME.screenshot.h + 6
		local small = THEME.size_small
		local facts = {}
		if g.year ~= nil then facts[#facts + 1] = g.year end
		if g.developer ~= nil then facts[#facts + 1] = g.developer end
		if g.players ~= nil then facts[#facts + 1] = g.players .." player(s)" end
		if #facts > 0 then
			gfx_text(gfx_fit(table.concat(facts, "  "), small, cw), px, ty, small, THEME.text_dim)
			ty = ty + 12
		end
		if g.genre ~= nil then
			gfx_text(gfx_fit(g.genre, small, cw), px, ty, small, THEME.text_dim)
			ty = ty + 12
		end
		if g.desc ~= nil then
			local limit = 448 - THEME.footer_h - 4
			local max_lines = math.floor((limit - ty) / 11)
			local lines = gfx_wrap(g.desc, small, cw, max_lines)
			for i = 1, #lines do
				gfx_text(lines[i], px, ty, small, THEME.text)
				ty = ty + 11
			end
		end
		-- Facts, under the list: file, where, how.
		local fy = 448 - THEME.footer_h - 26
		local where, wcol = library_where(g)
		gfx_text(where, lx, fy, THEME.size_small, wcol)
		local how, _id, hcol = gamelist_backend_text(g)
		gfx_text(how, lx + 60, fy, THEME.size_small, hcol)
		gfx_text(gfx_fit(g.file, THEME.size_small, 640 - lx - 24), lx, fy + 12, THEME.size_small, THEME.text_dim)
	end

	draw_footer({ {"cross", "launch"}, {"triangle", "options"}, {"circle", "back"}, {"L1", ""}, {"R1", "system"} })

	if GAMELIST.menu ~= nil then
		dim_screen()
		menu_draw(GAMELIST.menu)
	end
end

--- The per-game menu (triangle): how to run it, then launch. --------------------------
function game_menu_new(g)
	local opts = {}
	local sys = SYSTEMS[g.kind]
	opts[#opts + 1] = { label = "File", kind = "info", get = function() return gfx_fit(g.file, THEME.size_text, 190) end }
	local where = library_where(g)
	opts[#opts + 1] = { label = "Drive", kind = "info", get = function() return where end }

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
	if g.kind == "ps2" and vmc_id ~= nil then
		-- Memory card: every VMC on every drive (this game's first), a real card, or a
		-- new file. The choice is Denis's VMC.cfg (emu/ps2.lua), keyed by game ID.
		local id = vmc_id(g.file)
		if id ~= nil then
			vmc_cfg_load()
			local cards, own = vmc_candidates(id)
			local values, choices = {}, {}
			for i = 1, #cards do
				local label = string.match(cards[i], "([^/]+)$") or cards[i]
				if i <= own then label = "* ".. label end
				values[#values + 1] = gfx_fit(label, THEME.size_text, 180)
				choices[#choices + 1] = cards[i]
			end
			values[#values + 1] = "Real card (slot 1)"; choices[#choices + 1] = "none"
			opts[#opts + 1] = { label = "Memory card", kind = "choice", values = values,
				get = function()
					local cur = VMC_GAMES[id]
					if cur == nil then
						-- Automatic: the first card of this game, else a real card.
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
			-- Creating a card is a deliberate act (8 MB written), so it is its own entry,
			-- not a value one can land on by cycling.
			local drive = string.match(g.dir or "", "^[^:]+:") or "mass0:"
			local n = 1
			local new_name = vmc_new_name(g.file, n)
			while new_name ~= nil and doesFileExist(drive .."/VMC/".. new_name) and n < 20 do
				n = n + 1
				new_name = vmc_new_name(g.file, n)
			end
			if new_name ~= nil then
				opts[#opts + 1] = { label = "Create card", kind = "action", action = function()
					local created = vmc_create(drive, new_name)
					if created == nil then
						if log_event ~= nil then log_event("VMC", "could not create ".. new_name .." (Bios/vmc-template.bin present?)") end
						return "close"
					end
					VMC_GAMES[id] = created
					vmc_cfg_save()
					if log_event ~= nil then log_event("VMC", "created ".. created) end
					-- The new card goes first in the list and becomes the selection.
					table.insert(choices, 1, created)
					table.insert(values, 1, "* ".. gfx_fit(new_name, THEME.size_text, 176))
					own = own + 1
					return nil
				end }
				opts[#opts + 1] = { label = "  new file", kind = "info", get = function() return gfx_fit(new_name, THEME.size_text, 190) end }
			end
		end
	end
	opts[#opts + 1] = { label = "Launch", kind = "action", action = function()
		launch_view_open(g)
		return "launch"
	end }
	return menu_new(gfx_fit(g.title, THEME.size_head, 420), opts)
end
