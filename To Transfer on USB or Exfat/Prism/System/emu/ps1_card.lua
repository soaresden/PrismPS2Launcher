-- Prism PS2 Launcher - emu/ps1_card.lua
-- PlayStation 1 memory cards: one folder per emulator, one card per game.
--
-- POPStarter keeps a game's saves in POPS/<game>/SLOT0.VMC. Ember keeps its own pair,
-- MC1.vmc and MC2.vmc, inside the game's folder under Ember/games/. Both are a raw
-- 128 KiB PlayStation memory card image - byte for byte the same kind of file - and
-- each emulator now keeps its own. They are not shared and not moved about.
--
-- An earlier version of this file lent POPStarter's card to Ember for a session and
-- carried it home at the next start-up, so that one game could never end up with two
-- divergent saves. That was worth the machinery while a game could be played either
-- way. It stopped being worth it: POPStarter cannot read an internal exFAT disk at
-- all, so on that disk there is only ever Ember, and a library converted to .cue/.bin
-- has no .VCD left to share with. What the machinery bought was a copy operation
-- before every launch and a file on the memory card remembering a loan that a power
-- cut could leave half-done.
--
-- The cost of separating them is honest and small: a game you have played under BOTH
-- emulators has two saves that know nothing of each other. The game menu shows both,
-- says which is which, and lets you create either - so the divergence is visible
-- rather than discovered.
--
-- Cards are made by the emulators themselves at first use. Prism only creates one on
-- request, from the game menu, and HelperScripts/POPSVCDtoBinCue.py seeds a converted
-- game's Ember folder with a copy of its POPStarter save, once, so a library that
-- moves to Ember does not start from nothing.

PS1_CARD_FILE = "/System/Config/ps1_card.cfg"

--- The two slots, as each emulator names them. In slot order. --------------------------
--- The files are counted from zero and the console counts from one: SLOT0.VMC is the
--- card in port 1. Showing "SLOT0" to somebody deciding where a save lives is how a
--- save ends up in the wrong place, so the menu says port 1 and port 2 and the file
--- name is written underneath, unabbreviated.
SLOTS = { { pops = "SLOT0.VMC", ember = "MC1.vmc" },
          { pops = "SLOT1.VMC", ember = "MC2.vmc" } }

local function cfg_path()
	return System.currentDirectory() .. PS1_CARD_FILE
end

--- The drive letter part of a path: "mass0:/PRISM/Ember" -> "mass0:". ------------------
local function drive_of(path)
	local pos = string.find(tostring(path or ""), ":", 1, true)
	if pos == nil then return nil end
	return string.sub(path, 1, pos)
end

--- Where POPStarter keeps this game's card: <drive>/POPS/<game>/. ----------------------
--- On the drive the .VCD is on, because that is where POPStarter looks.
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

--- Every card this game has, on either side. -------------------------------------------
--- A game that exists only as a .VCD has two POPStarter slots; one that exists only as
--- an Ember folder has two Ember slots; one that is both has four, and they are
--- separate saves. Each entry says which emulator it belongs to, because a list of
--- four cards with no owner written on them would be worse than no list at all.
function ps1_slots(game, ember_dir)
	local out = {}
	if game == nil then return out end
	if game.vcd ~= nil then
		local dir = ps1_card_dir(game, ember_dir)
		if dir ~= nil then
			for i = 1, #SLOTS do
				local path = dir .."/".. SLOTS[i].pops
				out[#out + 1] = { port = i, who = "POPStarter", file = SLOTS[i].pops,
					path = path, exists = doesFileExist(path) }
			end
		end
	end
	if ember_dir ~= nil then
		for i = 1, #SLOTS do
			local path = ember_dir .."/".. SLOTS[i].ember
			out[#out + 1] = { port = i, who = "Ember", file = SLOTS[i].ember,
				path = path, exists = doesFileExist(path) }
		end
	end
	return out
end

--- An empty 128 KiB card, which is what both emulators make on their own. -------------
--- Written as zeros: POPStarter and Ember both format an unformatted card at first use,
--- so there is no need to build a PlayStation filesystem here - only to make the file
--- exist, at the right size, in the right place.
function ps1_card_create(path)
	if doesFileExist(path) then return true end
	local dir = string.match(path, "^(.*)/[^/]+$")
	if dir ~= nil and System.listDirectory(dir) == nil then
		pcall(System.createDirectory, dir)
	end
	local block = string.rep("\0", 1024)
	pcall(function()
		local fd = System.openFile(path, FCREATE)
		for _i = 1, 128 do System.writeFile(fd, block, 1024) end
		System.closeFile(fd)
	end)
	if log_event ~= nil then
		log_event("CARD", "created ".. path .." : ".. tostring(doesFileExist(path)))
	end
	return doesFileExist(path)
end

--- Clear the record left by the old lending scheme. ------------------------------------
--- Run once at start-up. A card that was out on loan when this changed is sitting in
--- the Ember folder, which is exactly where it now belongs, so nothing is moved: only
--- the note saying it is owed back is thrown away. Harmless when there is no note.
function ps1_card_tidy()
	local path = cfg_path()
	if doesFileExist(path) == false then return false end
	pcall(System.removeFile, path)
	if log_event ~= nil then
		log_event("CARD", "cleared the old loan record: each emulator keeps its own card now")
	end
	return true
end
