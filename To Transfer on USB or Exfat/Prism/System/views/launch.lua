-- Prism PS2 Launcher - views/launch.lua
-- "Ready to launch": before anything runs, one screen says exactly what is about to
-- happen - emulator, file with its full path, memory card with its full path - and
-- waits for cross. Then the progress screen: one line per step, written to the journal
-- too, so a black screen after loadELF still leaves a readable trace.

LAUNCH = { game = nil, plan = nil, lines = {}, ok = {}, title = "" }

--- The plan: everything the screen shows and the backend needs. -----------------------
function launch_plan(game)
	local p = { game = game }
	local how, id = gamelist_backend_text(game)
	p.backend, p.backend_name = id, how
	p.system = (SYSTEMS[game.kind] or {}).name or game.kind
	p.where = library_where(game)
	p.file = game.path or game.file
	p.card = nil
	p.card_note = nil
	if game.kind == "psx" then
		if id == "pops" and game.vcd ~= nil then
			local drive = POPS_DE(game.file)
			p.file = drive .."/POPS/".. game.file
			p.elf = drive .."/POPS/XX.".. game.stem ..".ELF"
			p.card = drive .."/POPS/".. game.stem .."/SLOT0.VMC"
			if doesFileExist(p.card) == false then p.card_note = "created by POPStarter on first run" end
			p.discs = drive .."/POPS/".. game.stem .."/DISCS.TXT"
		elseif game.ember ~= nil or game.disc ~= nil then
			local root, dir = ember_game(game.ember)
			p.ember_root, p.ember_dir = root, dir
			p.file = dir or game.ember_dir or game.disc
			p.elf = (root or "?") .."/ember.elf"
			-- The card this game actually keeps its saves on, which is POPStarter's
			-- folder whichever emulator is playing. Ember borrows a copy for the
			-- session; see emu/ps1_card.lua.
			local cdir = nil
			if ps1_card_dir ~= nil then cdir = ps1_card_dir(game, dir) end
			if cdir ~= nil then
				p.card = cdir .."/SLOT0.VMC"
				if doesFileExist(p.card) then
					p.card_note = "lent to Ember, back here when you return"
				else
					p.card_note = "created on this first run, and kept"
				end
			end
		end
	elseif game.kind == "ps2" then
		-- The card Neutrino will get: the one chosen in the game menu, else this game's
		-- own card if one exists, else the real card. Nothing is created silently.
		local drive = string.match(game.dir or "", "^[^:]+:") or "mass0:"
		local arg = nil
		if vmc_auto ~= nil then
			local ok, v = pcall(vmc_auto, game.file, drive)
			if ok then arg = v end
		end
		if arg ~= nil then
			p.card = string.gsub(arg, "^%-mc0=", "")
		else
			p.card = "Real memory card in slot 1"
			p.card_note = "triangle > Memory card to use a VMC file"
		end
		-- What the cheat file says, before you commit to it. A game whose cheats are on
		-- is not launched by the emulator you would expect, and that is worth reading
		-- on the screen that exists to tell you what is about to happen.
		if cheats_count ~= nil then
			local on, total = cheats_count(game)
			if total > 0 then
				p.cheats = on .." of ".. total .." on"
				if game.cheats_path ~= nil then
					p.cheats = p.cheats .."   ".. game.cheats_path
				end
			end
		end
		if id == "opl" then
			p.elf = System.currentDirectory() .."/OPL/OPNPS2LD.ELF"
			p.note = "OPL is run from a copy on mc0: - it needs the IOP reset first"
		else
			p.elf = System.currentDirectory() .."/Neutrino/neutrino.elf"
		end
	else
		if id ~= nil then p.elf = tostring(id) .."_libretro_ps2.elf" end
	end
	return p
end

function launch_view_open(game)
	LAUNCH.game = game
	LAUNCH.plan = launch_plan(game)
	-- Asked once, here, and not on every frame: each check is a file lookup, and this
	-- screen redraws sixty times a second.
	LAUNCH.plan.missing = launch_missing(game, LAUNCH.plan)
	VIEW = "launch"
	input_flush()
end

function launch_view_input()
	if input_pressed("circle") then
		play_sfx(S_CANCELAR)
		VIEW = "gamelist"
		input_flush()
	elseif input_pressed("triangle") then
		play_sfx(S_EJECUTAR)
		VIEW = "gamelist"
		GAMELIST.menu = game_menu_new(LAUNCH.game)
		input_flush()
	elseif input_pressed("cross") then
		if LAUNCH.plan.backend == nil then
			play_sfx(S_CANCELAR)
		else
			play_sfx(S_EJECUTAR)
			-- Written NOW: loadELF never returns, so this is the last chance.
			collections_played(LAUNCH.game)
			launch_run(LAUNCH.game, LAUNCH.plan)
			-- Only reached if the launch failed: the backend showed why.
			VIEW = "gamelist"
			input_flush()
		end
	end
end

local function row(y, label, value, color)
	gfx_text(label, THEME.launch_box.x + 18, y, THEME.size_small, THEME.text_dim)
	gfx_text(gfx_fit(value, THEME.size_text, THEME.launch_box.w - 36), THEME.launch_box.x + 18, y + 12, THEME.size_text, color or THEME.text)
	return y + 34
end

--- What the chosen emulator is still missing, in one line, or nil if it is ready. ------
--- The same checks the launch itself makes, asked early: being told the BIOS is absent
--- while you are still looking at the game is help; being told after the screen has
--- gone black and come back is an apology.
function launch_missing(g, p)
	if g == nil or p == nil then return nil end
	if g.warn ~= nil then return nil end          -- already explained above, in red
	-- An image on a drive that is neither the boot medium nor a known internal disk.
	-- Neutrino and OPL remount the drives themselves and never see Enceladus's massN:
	-- names, so the launch would hand them a path that cannot exist. Said here, while
	-- it is still a sentence rather than a black screen.
	if (g.kind == "ps2" or g.kind == "psx") and g.dir ~= nil then
		local dev = string.match(g.dir, "^[^:]+:")
		local boot = string.match(System.currentDirectory(), "^[^:]+:")
		if dev ~= nil and dev ~= boot and ES_RAIZ_ATA ~= nil and ES_RAIZ_ATA(g.dir) == false then
			return "This game is on ".. dev .." - create ".. dev .."/internal-ata-disk.flag if that is the internal disk"
		end
	end
	if g.kind == "psx" then
		if p.backend == "ember" or (p.backend ~= "pops" and g.vcd == nil) then
			if ember_ready ~= nil then
				local ok, why = ember_ready()
				if ok == false then return why end
			end
			return nil
		end
		-- POPStarter: its binaries live beside the .VCD, on that drive.
		if g.vcd ~= nil and POPS_DE ~= nil then
			local pops = POPS_DE(g.file) .."/POPS"
			if doesFileExist(pops .."/POPS_IOX.PAK") == false then
				return "POPStarter is not installed in ".. pops .." (no POPS_IOX.PAK)"
			end
			if doesFileExist(pops .."/XX.".. tostring(g.stem) ..".ELF") == false
			   and doesFileExist(System.currentDirectory() .."/POPStarter/POPSTARTER.ELF") == false then
				return "No XX.".. tostring(g.stem) ..".ELF and no POPSTARTER.ELF to make one"
			end
		end
	end
	return nil
end

function launch_view_draw()
	local g, p = LAUNCH.game, LAUNCH.plan
	draw_header(p.system)
	local b = THEME.launch_box
	gfx_rect(b.x, b.y - 30, b.w, b.h + 30, THEME.panel)
	gfx_rect(b.x, b.y - 30, b.w, b.h + 30, THEME.panel)
	gfx_frame(b.x, b.y - 30, b.w, b.h + 30, THEME.selector_edge)
	gfx_rect(b.x, b.y - 30, b.w, 30, THEME.selector)
	gfx_text("Ready to launch", b.x, b.y - 23, THEME.size_head, THEME.text_head, "center", b.w)

	local y = b.y + 10
	gfx_text(gfx_fit(g.title, THEME.size_head, b.w - 36), b.x + 18, y, THEME.size_head, THEME.text_head)
	y = y + 30
	local hcol = THEME.text
	if p.backend == nil then hcol = THEME.warn end
	y = row(y, "Emulator", p.backend_name, hcol)
	local _w, wcol = library_where(g)
	y = row(y, "Image  (".. p.where ..")", p.file, wcol)
	if p.card ~= nil then
		local note = ""
		if p.card_note ~= nil then note = "   - ".. p.card_note end
		y = row(y, "Memory card", p.card .. note, THEME.ok)
	end
	if p.cheats ~= nil then
		y = row(y, "Cheats", p.cheats, THEME.ok)
	end
	if p.elf ~= nil then
		y = row(y, "Program", p.elf, THEME.text_dim)
	end
	if g.warn == "chd" then
		gfx_text("A .chd cannot be read on the PS2. Convert it on the PC:", b.x + 18, y, THEME.size_small, THEME.warn)
		gfx_text("PS1toPOPS.py (to .VCD) or chdman extractcd (to .cue/.bin).", b.x + 18, y + 12, THEME.size_small, THEME.warn)
	elseif g.warn == "loose" then
		gfx_text("POPStarter reads .VCD, Ember reads .cue/.bin - this is neither.", b.x + 18, y, THEME.size_small, THEME.warn)
		gfx_text("PS1toPOPS.py turns it into POPS/<name>.VCD, which runs.", b.x + 18, y + 12, THEME.size_small, THEME.warn)
	elseif g.disc ~= nil and g.ember == nil then
		gfx_text("It will be moved into Ember/games/".. tostring(g.stem) .."/ first,", b.x + 18, y, THEME.size_small, THEME.text_dim)
		gfx_text("and put back in Roms/psx when you launch another game.", b.x + 18, y + 12, THEME.size_small, THEME.text_dim)
		y = y + 26
	end

	if p.note ~= nil then
		gfx_text(gfx_fit(p.note, THEME.size_small, b.w - 36), b.x + 18, y,
			THEME.size_small, THEME.text_dim)
		y = y + 20
	end

	-- What this emulator still needs, said here rather than after a failed launch.
	local lack = p.missing
	if lack ~= nil then
		gfx_text(gfx_fit(lack, THEME.size_small, b.w - 36), b.x + 18, y, THEME.size_small, THEME.warn)
	end
	draw_footer({ {"cross", "launch"}, {"triangle", "options"}, {"circle", "back"} })
end

--- Progress screen ----------------------------------------------------------------------
--- The same names the emu/ helpers call (launch_step, copy_progress, LIBRETRO_PANTALLA),
--- so RetroArch preparation reports through here without knowing the interface.
function launch_begin(title)
	LAUNCH.title = title
	LAUNCH.lines, LAUNCH.ok = {}, {}
	launch_paint()
end

function launch_paint()
	gfx_background()
	local b = THEME.launch_box
	gfx_rect(b.x, b.y - 30, b.w, b.h + 30, THEME.panel)
	gfx_frame(b.x, b.y - 30, b.w, b.h + 30, THEME.selector_edge)
	gfx_rect(b.x, b.y - 30, b.w, 30, THEME.selector)
	gfx_text(gfx_fit(LAUNCH.title, THEME.size_head, b.w - 20), b.x, b.y - 23, THEME.size_head, THEME.text_head, "center", b.w)
	local y = b.y + 12
	local first = math.max(1, #LAUNCH.lines - 10)
	for i = first, #LAUNCH.lines do
		local col = THEME.text
		if LAUNCH.ok[i] == true then col = THEME.ok end
		if LAUNCH.ok[i] == "warn" then col = THEME.warn end
		gfx_text(gfx_fit(LAUNCH.lines[i], THEME.size_text, b.w - 36), b.x + 18, y, THEME.size_text, col)
		y = y + 20
	end
	Screen.flip()
end

function launch_step(text, ok)
	LAUNCH.lines[#LAUNCH.lines + 1] = tostring(text)
	LAUNCH.ok[#LAUNCH.lines] = ok
	if log_event ~= nil then log_event("LANZA", tostring(text)) end
	launch_paint()
end

function launch_replace(text)
	if #LAUNCH.lines == 0 then LAUNCH.lines[1] = "" end
	LAUNCH.lines[#LAUNCH.lines] = tostring(text)
	launch_paint()
end

function launch_fail(text)
	launch_step(text, "warn")
	if boot_flush ~= nil then boot_flush() end
	System.sleep(3)
end

--- Copy progress from copy_with_progress(): label, bytes done, bytes total. -----------
function copy_progress(label, done, total)
	local pct = 0
	if total ~= nil and total > 0 then pct = math.floor(done * 100 / total) end
	launch_replace(tostring(label) .."  ".. pct .."%   ".. math.floor((done or 0) / 1024) .." / ".. math.floor((total or 0) / 1024) .." KB")
end

--- The RetroArch helpers' own screen call: routed to the same box. ------------------
function LIBRETRO_PANTALLA(title, line, done, total)
	if total ~= nil and total > 0 then
		launch_replace(tostring(line) .."  ".. tostring(done) .." / ".. tostring(total))
	else
		launch_step(tostring(line))
	end
end

--- Disc-swap help for a multi-disc POPStarter game, five seconds before it starts. -----
--- POPStarter shows these combinations nowhere.
function discs_hint(discs_file, title)
	if doesFileExist(discs_file) == false then return end
	local n = 0
	pcall(function()
		local fd = System.openFile(discs_file, FREAD)
		local size = System.sizeFile(fd)
		System.seekFile(fd, 0, SET)
		local data = System.readFile(fd, size)
		System.closeFile(fd)
		for _line in string.gmatch(data or "", "[^\r\n]+") do n = n + 1 end
	end)
	if n < 2 then return end
	local combos = { "SELECT + L2 + R2 + TRIANGLE  : disc 1", "SELECT + L2 + R2 + UP        : disc 2",
		"SELECT + L2 + R2 + RIGHT     : disc 3", "SELECT + L2 + R2 + DOWN      : disc 4",
		"SELECT + L2 + R2 + LEFT      : disc 5", "SELECT + L2 + R2 + SQUARE    : disc 6" }
	for t = 5, 1, -1 do
		gfx_background()
		local b = THEME.launch_box
		gfx_rect(b.x, b.y - 30, b.w, b.h + 30, THEME.panel)
		gfx_frame(b.x, b.y - 30, b.w, b.h + 30, THEME.selector_edge)
		gfx_rect(b.x, b.y - 30, b.w, 30, THEME.selector)
		gfx_text("Multi-disc game: ".. n .." discs", b.x, b.y - 23, THEME.size_head, THEME.text_head, "center", b.w)
		gfx_text(gfx_fit(title, THEME.size_text, b.w - 36), b.x + 18, b.y + 10, THEME.size_text, THEME.text_head)
		gfx_text("To change disc while playing, hold:", b.x + 18, b.y + 36, THEME.size_small, THEME.text_dim)
		for i = 1, math.min(n, 6) do
			gfx_text(combos[i], b.x + 18, b.y + 56 + (i - 1) * 18, THEME.size_text, THEME.text)
		end
		gfx_text("Starting in ".. t .."...", b.x, b.y + b.h - 26, THEME.size_small, THEME.text_dim, "center", b.w)
		Screen.flip()
		System.sleep(1)
	end
end
