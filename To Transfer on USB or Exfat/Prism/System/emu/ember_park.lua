-- Prism PS2 Launcher - emu/ember_park.lua
-- One parking space for Ember.
--
-- Ember does not take a path. Its ELF is handed the NAME of a folder and looks for it
-- in Ember/games/, so a .cue sitting in Roms/psx cannot be launched where it lies, no
-- matter how willing everything else is. The disc has to be in Ember/games/<Game>/.
--
-- Copying it there would double the space a 600 MB game takes, so it is MOVED instead:
-- on one drive that is a rename, which costs nothing whatever the size of the file.
-- Only one game is parked at a time. Launching another one first sends the previous
-- game home to the folder it came from, so Roms/psx stays the library and Ember/games
-- stays a single slot - and the game that is in it is, by definition, the last played.
--
-- What is NOT moved back: the .vmc memory cards Ember writes into the game folder. They
-- stay in Ember/games/<Game>/, so the folder is still there with your saves in it the
-- next time that game is parked. Moving a save out of an emulator's reach to tidy up
-- would be a strange way to keep it.
--
-- The record of what is parked: System/Config/ember_park.cfg
--     name=Spyro
--     from=mass0:/Prism/Roms/psx
--     files=Spyro.cue|Spyro.bin

EMBER_PARK_FILE = "/System/Config/ember_park.cfg"

local function cfg_path()
	return System.currentDirectory() .. EMBER_PARK_FILE
end

local function say(text)
	if launch_step ~= nil then launch_step(text) end
	if log_event ~= nil then log_event("EMBER", text) end
end

--- The record of the game currently parked, or nil. ----------------------------------
function ember_park_read()
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
		if t.name ~= nil and t.name ~= "" then
			t.list = {}
			for f in string.gmatch(tostring(t.files or ""), "[^|]+") do
				t.list[#t.list + 1] = f
			end
			rec = t
		end
	end)
	return rec
end

local function park_write(name, from, files)
	local text = ""
	if name ~= nil then
		text = "# Which game is in Ember/games right now, and where it came from.\n"
			.. "name=".. name .."\nfrom=".. tostring(from) .."\n"
			.. "files=".. table.concat(files or {}, "|") .."\n"
	end
	pcall(function()
		local fd = System.openFile(cfg_path(), FCREATE)
		System.writeFile(fd, text, string.len(text))
		System.closeFile(fd)
	end)
end

--- Move one file. A rename first, because on one drive it is instant whatever the size;
--- a copy only if this build has no rename, or the rename did not take.
local function move_one(src, dst)
	if doesFileExist(src) == false then return false end
	if System.rename ~= nil then
		pcall(System.rename, src, dst)
		if doesFileExist(dst) and doesFileExist(src) == false then return true end
	end
	pcall(System.copyFile, src, dst)
	if doesFileExist(dst) == false then return false end
	pcall(System.removeFile, src)
	return true
end

--- The files that make up one disc: the .cue and every FILE it names. ------------------
--- A cue sheet is the only thing that knows whether a game is one .bin or twenty-two
--- numbered tracks, so it is read rather than guessed at. If it cannot be read, the
--- fallback is every file in the folder sharing the disc's name.
local function disc_files(dir, name)
	local out = { name }
	local ext = string.lower(string.match(name, "%.[^%.]+$") or "")
	if ext ~= ".cue" then return out end
	local data = nil
	pcall(function()
		local fd = System.openFile(dir .."/".. name, FREAD)
		local size = System.sizeFile(fd)
		System.seekFile(fd, 0, SET)
		data = System.readFile(fd, size)
		System.closeFile(fd)
	end)
	local n = 0
	if data ~= nil then
		for track in string.gmatch(data, "FILE%s+\"([^\"]+)\"") do
			-- A cue may name a path; only the file name matters, they sit together.
			local base = string.match(track, "([^/\\]+)$") or track
			if doesFileExist(dir .."/".. base) then
				out[#out + 1] = base
				n = n + 1
			end
		end
	end
	if n == 0 then
		local stem = string.match(name, "^(.*)%.[^%.]+$") or name
		local list = System.listDirectory(dir)
		if list ~= nil then
			for i = 1, #list do
				local e = list[i]
				if e.directory == false and e.name ~= name then
					local s = string.match(e.name, "^(.*)%.[^%.]+$") or e.name
					if s == stem then out[#out + 1] = e.name end
				end
			end
		end
	end
	return out
end

--- Send the parked game back where it came from. --------------------------------------
--- Missing pieces are not an error: the user is allowed to have tidied up by hand.
function ember_unpark(rec)
	if rec == nil then rec = ember_park_read() end
	if rec == nil or rec.name == nil then return true end
	local _root, dir = ember_game(rec.name)
	if dir == nil or rec.from == nil or rec.from == "" then
		park_write(nil)
		return true
	end
	say("Putting ".. rec.name .." back in ".. rec.from)
	for i = 1, #(rec.list or {}) do
		local f = rec.list[i]
		if doesFileExist(dir .."/".. f) then
			move_one(dir .."/".. f, rec.from .."/".. f)
		end
	end
	park_write(nil)
	return true
end

--- The Ember root on the same drive as a folder, so the move is a rename. -------------
local function root_for(dir)
	local roots = ember_roots()
	if #roots == 0 then return nil end
	local d = string.lower(tostring(dir))
	for i = 1, #roots do
		local prefix = string.lower(string.match(roots[i], "^(.-)/[^/]*$") or roots[i])
		if string.sub(d, 1, string.len(prefix)) == prefix then return roots[i] end
	end
	return roots[1]
end

--- Put a loose disc image into Ember/games/<Game>/ and make the game point at it. ------
--- Returns true when Ember can be started on it. Sets game.ember / game.ember_dir.
function ember_park(game)
	if game == nil then return false end
	if game.ember ~= nil then return true end          -- already a real Ember game
	if game.disc == nil then return false end
	local ext = string.lower(tostring(game.disc_ext or ""))
	if ext ~= ".cue" and ext ~= ".bin" then return false end

	local name = game.stem
	local rec = ember_park_read()
	if rec ~= nil and rec.name == name then
		local _r, d = ember_game(name)
		if d ~= nil then
			say("Already in Ember/games/".. name)
			game.ember, game.ember_dir = name, d
			return true
		end
	end
	if rec ~= nil and rec.name ~= name then ember_unpark(rec) end

	local root = root_for(game.dir)
	if root == nil then
		say("No Ember folder with ember.elf on any drive")
		return false
	end
	local games = root .."/games"
	if System.listDirectory(games) == nil then pcall(System.createDirectory, games) end
	local dest = games .."/".. name
	if System.listDirectory(dest) == nil then pcall(System.createDirectory, dest) end
	if System.listDirectory(dest) == nil then
		say("Could not create ".. dest)
		return false
	end

	local files = disc_files(game.dir, game.file)
	say("Moving ".. #files .." file(s) into Ember/games/".. name)
	local moved = {}
	for i = 1, #files do
		local f = files[i]
		if doesFileExist(dest .."/".. f) then
			moved[#moved + 1] = f                      -- already there from a past run
		elseif move_one(game.dir .."/".. f, dest .."/".. f) then
			moved[#moved + 1] = f
		else
			say("Could not move ".. f)
		end
	end
	if #moved == 0 then return false end

	park_write(name, game.dir, moved)
	game.ember, game.ember_dir = name, dest
	return true
end
