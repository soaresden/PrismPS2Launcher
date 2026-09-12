-- Prism PS2 Launcher - library/gamelist_xml.lua
-- gamelist.xml, the EmulationStation format, read and written. This is what lets a
-- scraper made for ES (ARRM, Skraper, Batocera's own) fill in titles, descriptions
-- and artwork for Prism, and what HelperScripts/BatoceraGamelistandMediaCopier.py can copy straight from
-- an existing Batocera install.
--
--   <gameList>
--     <game>
--       <path>./Sonic (World).zip</path>
--       <name>Sonic the Hedgehog</name>
--       <desc>...</desc>
--       <image>./media/screenshots/Sonic (World).png</image>      screenshot (or mix)
--       <thumbnail>./media/covers/Sonic (World).png</thumbnail>    box art
--       <developer/> <publisher/> <genre/> <players/> <rating/> <releasedate/>
--     </game>
--   </gameList>
--
-- Where it is looked for, in order: Roms/<system>/gamelist.xml on every root, then a
-- gamelist.xml inside each folder the system is scanned from (so ARRM pointed at POPS/
-- works too). Media paths are relative to the file that names them.
-- If a system has games and no gamelist.xml anywhere, one is written with what is
-- known - path and name - so a scraper has something to start from. An existing file
-- is never overwritten.

local function decode(s)
	if s == nil then return nil end
	s = string.gsub(s, "^%s+", "")
	s = string.gsub(s, "%s+$", "")
	if s == "" then return nil end
	s = string.gsub(s, "&lt;", "<")
	s = string.gsub(s, "&gt;", ">")
	s = string.gsub(s, "&quot;", "\"")
	s = string.gsub(s, "&apos;", "'")
	s = string.gsub(s, "&#39;", "'")
	s = string.gsub(s, "&#(%d+);", function(n)
		local ok, ch = pcall(function() return utf8.char(tonumber(n)) end)
		if ok then return ch end
		return ""
	end)
	s = string.gsub(s, "&amp;", "&")
	return s
end

local function encode(s)
	s = tostring(s or "")
	s = string.gsub(s, "&", "&amp;")
	s = string.gsub(s, "<", "&lt;")
	s = string.gsub(s, ">", "&gt;")
	s = string.gsub(s, "\"", "&quot;")
	return s
end

local function read_file(path)
	local data = nil
	pcall(function()
		local fd = System.openFile(path, FREAD)
		local size = System.sizeFile(fd)
		System.seekFile(fd, 0, SET)
		data = System.readFile(fd, size)
		System.closeFile(fd)
	end)
	return data
end

local function field(block, tag)
	return decode(string.match(block, "<".. tag ..">(.-)</".. tag ..">"))
end

--- "./media/covers/x.png" relative to the gamelist's folder -> absolute path. -----------
local function resolve(base, rel)
	if rel == nil then return nil end
	if string.find(rel, ":", 1, true) ~= nil then return rel end     -- already absolute
	rel = string.gsub(rel, "^%./", "")
	rel = string.gsub(rel, "^/", "")
	return base .."/".. rel
end

--- Base name of a <path>: "./sub/Game.zip" -> "game.zip" (lower case, for matching). ----
--- An Ember folder is "./Game/" or "./Game/Game.cue": the first segment is the key.
local function path_keys(p)
	if p == nil then return {} end
	p = string.gsub(p, "^%./", "")
	p = string.gsub(p, "/+$", "")
	local keys = {}
	local last = string.match(p, "([^/]+)$") or p
	keys[#keys + 1] = string.lower(last)
	local first = string.match(p, "^([^/]+)/")
	if first ~= nil then keys[#keys + 1] = string.lower(first) end
	return keys
end

--- Parse one file into { [key] = entry }. -----------------------------------------------
function gamelist_parse(path)
	local xml = read_file(path)
	if xml == nil or xml == "" then return nil end
	local base = string.match(path, "^(.*)/[^/]+$") or ""
	local out, n = {}, 0
	for block in string.gmatch(xml, "<game[^>]*>(.-)</game>") do
		local p = field(block, "path")
		if p ~= nil then
			local e = {
				name = field(block, "name"),
				desc = field(block, "desc"),
				developer = field(block, "developer"),
				publisher = field(block, "publisher"),
				genre = field(block, "genre"),
				players = field(block, "players"),
				rating = field(block, "rating"),
				releasedate = field(block, "releasedate"),
				image = resolve(base, field(block, "image")),
				thumbnail = resolve(base, field(block, "thumbnail")),
				marquee = resolve(base, field(block, "marquee")),
				cartridge = resolve(base, field(block, "cartridge")),
			}
			local keys = path_keys(p)
			for i = 1, #keys do
				if out[keys[i]] == nil then out[keys[i]] = e end
			end
			n = n + 1
		end
	end
	if log_event ~= nil then log_event("LIB", "gamelist ".. path .."  ".. n .." entries") end
	return out
end

--- Every gamelist.xml that can describe a system, in order of preference. ---------------
local function candidates(folder)
	local list, seen = {}, {}
	local function add(p)
		if seen[p] == nil then seen[p] = true; list[#list + 1] = p end
	end
	for r = 1, #RAICES do add(RAICES[r] .."/Roms/".. folder .."/gamelist.xml") end
	for r = 1, #RAICES do
		local dirs = scan_roots(folder, RAICES[r])
		for d = 1, #dirs do add(dirs[d] .."/gamelist.xml") end
	end
	return list
end

--- Apply metadata to the games of one system. Returns true if any file was found. ----
function gamelist_apply(folder, games)
	local found = false
	local maps = {}
	local cands = candidates(folder)
	for i = 1, #cands do
		if doesFileExist(cands[i]) then
			local m = gamelist_parse(cands[i])
			if m ~= nil then maps[#maps + 1] = m; found = true end
		end
	end
	if found == false then return false end
	for i = 1, #games do
		local g = games[i]
		local keys = { string.lower(g.file) }
		if g.stem ~= nil then keys[#keys + 1] = string.lower(g.stem) end
		if g.ember ~= nil then keys[#keys + 1] = string.lower(g.ember) end
		local e = nil
		for m = 1, #maps do
			for k = 1, #keys do
				if e == nil and maps[m][keys[k]] ~= nil then e = maps[m][keys[k]] end
			end
		end
		if e ~= nil then
			g.listed = true
			if e.name ~= nil then g.title = e.name end
			g.desc, g.developer, g.publisher = e.desc, e.developer, e.publisher
			g.genre, g.players, g.rating = e.genre, e.players, e.rating
			if e.releasedate ~= nil then g.year = string.match(e.releasedate, "^(%d%d%d%d)") end
			-- Artwork named by the file wins over the naming convention, when it exists.
			if e.thumbnail ~= nil and doesFileExist(e.thumbnail) then g.art_covers = e.thumbnail end
			if e.image ~= nil and doesFileExist(e.image) then g.art_screenshots = e.image end
			if e.marquee ~= nil and doesFileExist(e.marquee) then g.art_gamelogo = e.marquee end
			if e.cartridge ~= nil and doesFileExist(e.cartridge) then g.art_cartridges = e.cartridge end
		end
	end
	return true
end

--- The <path> a game is written under: the file, or the folder for an Ember game. -----
local function game_path(g)
	if g.vcd == nil and g.ember ~= nil then return "./".. g.ember .."/" end
	return "./".. g.file
end

--- Add the games that are on the drive but not in the gamelist. -----------------------
--- A scraper only ever describes what it was pointed at, so a game copied in afterwards
--- is missing from the file even though it is right there on the disk. Rather than
--- ignore it, or rewrite the whole gamelist and lose every description in it, the new
--- games are appended before </gameList> with the two things we know for certain: where
--- it is and what it is called. A scraper run later fills in the rest.
function gamelist_add_missing(folder, games)
	local missing = {}
	for i = 1, #games do
		if games[i].listed ~= true then missing[#missing + 1] = games[i] end
	end
	if #missing == 0 then return 0 end

	-- The file to grow is the one a scraper is pointed at: Roms/<system>/gamelist.xml.
	local path = nil
	local cands = candidates(folder)
	for i = 1, #cands do
		if doesFileExist(cands[i]) and string.find(string.lower(cands[i]), "/roms/", 1, true) ~= nil then
			path = cands[i]
			break
		end
	end
	if path == nil then
		for i = 1, #cands do
			if doesFileExist(cands[i]) then path = cands[i]; break end
		end
	end
	if path == nil then return 0 end

	local xml = read_file(path)
	if xml == nil then return 0 end
	local cut = string.find(xml, "</gameList>", 1, true)
	if cut == nil then return 0 end

	local t = {}
	for i = 1, #missing do
		local g = missing[i]
		t[#t + 1] = "\t<game>\n\t\t<path>".. encode(game_path(g)) .."</path>\n\t\t<name>"
			.. encode(g.title) .."</name>\n\t</game>\n"
	end
	local text = string.sub(xml, 1, cut - 1) .. table.concat(t) .. string.sub(xml, cut)
	pcall(function()
		local fd = System.openFile(path, FCREATE)
		System.writeFile(fd, text, string.len(text))
		System.closeFile(fd)
	end)
	if log_event ~= nil then
		log_event("LIB", "gamelist ".. path .."  +".. #missing .." game(s) not scraped yet")
	end
	return #missing
end

--- Write a starting gamelist.xml for a system that has none. -------------------------
--- Goes in Roms/<system>/ on the first root: that is the folder a scraper is pointed
--- at, and where media/ already lives. Paths are "./<file>" (or "./<folder>/" for
--- Ember), names are what the list shows today.
function gamelist_write_default(folder, games)
	if #games == 0 then return end
	local dir = RAICES[1] .."/Roms/".. folder
	if System.listDirectory(RAICES[1] .."/Roms") == nil then pcall(System.createDirectory, RAICES[1] .."/Roms") end
	if System.listDirectory(dir) == nil then pcall(System.createDirectory, dir) end
	if System.listDirectory(dir) == nil then return end
	local path = dir .."/gamelist.xml"
	if doesFileExist(path) then return end
	local t = { "<?xml version=\"1.0\"?>\n<gameList>\n" }
	for i = 1, #games do
		local g = games[i]
		t[#t + 1] = "\t<game>\n\t\t<path>".. encode(game_path(g)) .."</path>\n\t\t<name>".. encode(g.title) .."</name>\n"
		local cover = library_art(g, "covers")
		local shot = library_art(g, "screenshots")
		if cover ~= nil then t[#t + 1] = "\t\t<thumbnail>./media/covers/".. encode(string.match(cover, "([^/]+)$")) .."</thumbnail>\n" end
		if shot ~= nil then t[#t + 1] = "\t\t<image>./media/screenshots/".. encode(string.match(shot, "([^/]+)$")) .."</image>\n" end
		t[#t + 1] = "\t</game>\n"
	end
	t[#t + 1] = "</gameList>\n"
	local text = table.concat(t)
	pcall(function()
		local fd = System.openFile(path, FCREATE)
		System.writeFile(fd, text, string.len(text))
		System.closeFile(fd)
	end)
	if log_event ~= nil then log_event("LIB", "wrote ".. path .."  (".. #games .." games, no scraper data yet)") end
end
