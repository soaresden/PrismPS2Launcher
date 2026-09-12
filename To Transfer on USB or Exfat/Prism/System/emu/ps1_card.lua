-- Prism PS2 Launcher - emu/ps1_card.lua
-- One memory card per PlayStation 1 game, wherever it is played from.
--
-- POPStarter keeps a game's saves in POPS/<game>/SLOT0.VMC. Ember keeps its own pair,
-- MC1.vmc and MC2.vmc, inside the game's folder under Ember/games/. Both are a raw
-- 128 KiB PlayStation memory card image - byte for byte the same kind of file - so the
-- only thing standing between them is which folder they sit in.
--
-- Two copies of a save is worse than one copy in an awkward place: you finish a session
-- on one emulator, come back on the other, and your afternoon is gone. So there is ONE
-- card per game and it lives with POPStarter, in POPS/<game>/. Ember borrows it:
--
--   before an Ember launch   POPS/<game>/SLOT0.VMC  ->  games/<folder>/MC1.vmc
--   at the next start-up     games/<folder>/MC1.vmc  ->  POPS/<game>/SLOT0.VMC
--                            and Ember's copy is deleted
--
-- Slot 1 rides along the same way: MC2.vmc <-> SLOT1.VMC.
--
-- The borrow is recorded in System/Config/ps1_card.cfg BEFORE anything is copied, so a
-- console that loses power mid-session still knows, at the next boot, that there is a
-- card out on loan and where it belongs. The return is idempotent: if it has already
-- happened, nothing is found to copy and the record is simply cleared.
--
-- A game with no POPS folder yet gets one, seeded with whatever Ember already had.
-- Nobody's existing saves are thrown away on the first run of this.

PS1_CARD_FILE = "/System/Config/ps1_card.cfg"

--- SLOT0/SLOT1 on the POPStarter side, MC1/MC2 on Ember's. In slot order. -------------
local SLOTS = { { pops = "SLOT0.VMC", ember = "MC1.vmc" },
                { pops = "SLOT1.VMC", ember = "MC2.vmc" } }

local function cfg_path()
	return System.currentDirectory() .. PS1_CARD_FILE
end

local function say(text)
	if launch_step ~= nil then launch_step(text) end
	if log_event ~= nil then log_event("CARD", text) end
end

--- The drive letter part of a path: "mass0:/PRISM/Ember" -> "mass0:". ------------------
local function drive_of(path)
	local pos = string.find(tostring(path or ""), ":", 1, true)
	if pos == nil then return nil end
	return string.sub(path, 1, pos)
end

--- Where this game's card lives: <drive>/POPS/<game>/. ---------------------------------
--- The same folder POPStarter uses, on the drive the game is on, so a game that has
--- both a .VCD and an Ember folder has one card and not two.
function ps1_card_dir(game, ember_dir)
	if game == nil then return nil end
	local name = game.stem or game.ember
	if name == nil or name == "" then return nil end
	local drive = nil
	if game.vcd ~= nil and POPS_DE ~= nil then
		local ok, d = pcall(POPS_DE, game.file)
		if ok and d ~= nil and d ~= "" then drive = d end
	end
	if drive == nil then drive = drive_of(ember_dir) end
	if drive == nil then drive = drive_of(System.currentDirectory()) end
	if drive == nil then return nil end
	return drive .."/POPS/".. name
end

--- The record of a card out on loan, or nil. ------------------------------------------
function ps1_card_read()
	local path = cfg_path()
	if doesFileExist(path) == false then return nil end
	local rec = nil
	pcall(function()
		local fd = System.openFile(path, FREAD)
		local size = System.sizeFile(fd)
		System.seekFile(fd, 0, SET)
		local data = System.readFile(fd, size)
		System.closeFile(fd)
		if data == nil then return end
		local t = {}
		for line in string.gmatch(data, "[^\r\n]+") do
			local k, v = string.match(line, "^%s*(%w+)%s*=%s*(.-)%s*$")
			if k ~= nil then t[k] = v end
		end
		if t.pops ~= nil and t.pops ~= "" and t.ember ~= nil and t.ember ~= "" then
			rec = t
		end
	end)
	return rec
end

local function card_write(pops_dir, ember_dir, title)
	local text = ""
	if pops_dir ~= nil then
		text = "# A memory card is on loan to Ember. It belongs in the POPS folder,\n"
			.. "# and goes back there at the next start-up.\n"
			.. "pops=".. pops_dir .."\nember=".. tostring(ember_dir) .."\n"
			.. "title=".. tostring(title or "") .."\n"
	end
	pcall(function()
		local fd = System.openFile(cfg_path(), FCREATE)
		System.writeFile(fd, text, string.len(text))
		System.closeFile(fd)
	end)
end

--- Copy, then check. A memory card is 128 KiB, so this costs nothing on any drive. -----
local function copy_card(src, dst)
	if doesFileExist(src) == false then return false end
	pcall(System.copyFile, src, dst)
	return doesFileExist(dst)
end

local function ensure_dir(path)
	if System.listDirectory(path) ~= nil then return true end
	pcall(System.createDirectory, path)
	return System.listDirectory(path) ~= nil
end

--- Bring the card home. Called at start-up, which is when you come back from a game. ---
--- Safe to call when nothing is on loan, and safe to call twice.
function ps1_card_return()
	local rec = ps1_card_read()
	if rec == nil then return 0 end
	local moved = 0
	if System.listDirectory(rec.pops) ~= nil then
		for i = 1, #SLOTS do
			local from = rec.ember .."/".. SLOTS[i].ember
			local to = rec.pops .."/".. SLOTS[i].pops
			if doesFileExist(from) then
				if copy_card(from, to) then
					pcall(System.removeFile, from)
					moved = moved + 1
				else
					-- The copy failed: Ember's card stays where it is rather than
					-- being deleted. A save in the wrong folder beats no save.
					say("could not bring ".. SLOTS[i].ember .." back to ".. to)
					return moved
				end
			end
		end
	end
	card_write(nil)
	if moved > 0 and log_event ~= nil then
		log_event("CARD", moved .." card(s) returned to ".. rec.pops)
	end
	return moved
end

--- Lend this game's card to Ember, just before it starts. -----------------------------
--- Returns the POPS folder the card came from, or nil if there was nothing to do.
function ps1_card_borrow(game, ember_dir)
	if game == nil or ember_dir == nil then return nil end
	-- Whatever was out before goes home first: one card at a time, like the discs.
	ps1_card_return()

	local pops_dir = ps1_card_dir(game, ember_dir)
	if pops_dir == nil then return nil end
	if ensure_dir(pops_dir) == false then
		say("could not create ".. pops_dir)
		return nil
	end

	-- First time for this game: POPS has no card, but Ember may already hold one from
	-- a session before any of this existed. That one becomes the home copy.
	for i = 1, #SLOTS do
		local home = pops_dir .."/".. SLOTS[i].pops
		local mine = ember_dir .."/".. SLOTS[i].ember
		if doesFileExist(home) == false and doesFileExist(mine) then
			if copy_card(mine, home) then
				say("adopted Ember's ".. SLOTS[i].ember .." as ".. SLOTS[i].pops)
			end
		end
	end

	-- Written before the copying starts, so a power cut leaves a trail.
	card_write(pops_dir, ember_dir, game.title)

	local lent = 0
	for i = 1, #SLOTS do
		local home = pops_dir .."/".. SLOTS[i].pops
		if doesFileExist(home) then
			if copy_card(home, ember_dir .."/".. SLOTS[i].ember) then lent = lent + 1 end
		end
	end
	if lent == 0 then
		-- Nothing existed on either side. Ember will make its own pair, and the
		-- record stays so that pair is brought home at the next start-up.
		say("no card yet - Ember will create one, and it will be kept")
	else
		say("card from POPS/".. tostring(game.stem or game.ember))
	end
	return pops_dir
end
