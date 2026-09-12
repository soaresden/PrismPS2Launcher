-- Prism PS2 Launcher - views/menu.lua
-- The main menu on START, as EmulationStation does it: one modal box, a few settings,
-- a few actions. Settings live in core/prefs.lua; nothing here reads or writes files.

MAIN_MENU = nil

--- Video mode is decided at boot by a marker file (System/Defaults/PAL or NTSC), so the
--- preference is mirrored into those files and applies at the next start.
local function apply_video_pref()
	local base = System.currentDirectory() .."/System/Defaults/"
	local want = prefs_get("video")
	local function ensure(name, present)
		local p = base .. name
		if present then
			if doesFileExist(p) == false then
				local fd = System.openFile(p, FCREATE)
				System.closeFile(fd)
			end
		elseif doesFileExist(p) then
			pcall(System.removeFile, p)
		end
	end
	ensure("PAL", want == "pal")
	ensure("NTSC", want == "ntsc")
end

local VIDEO = { "auto", "ntsc", "pal" }

--- Finds where a stored id sits in a list of ids, for the "choice" rows. --------------
local function index_of(list, value, fallback)
	for i = 1, #list do if list[i] == value then return i end end
	return fallback or 1
end

--- Builds the menu section by section. The order is meant to go from what you change
--- often (how it looks) to what you change once (video mode, and the way out).
function main_menu_open()
	local opts = {}
	local function header(text) opts[#opts + 1] = { label = text, kind = "header" } end
	local function add(o) opts[#opts + 1] = o end

	--- Appearance ---------------------------------------------------------------------
	header("APPEARANCE")
	add({ label = "Selection colour", kind = "choice", values = SELECTION_NAMES,
		get = function() return index_of(SELECTION_IDS, prefs_get("select_color")) end,
		set = function(v)
			prefs_set("select_color", SELECTION_IDS[v])
			theme_selection(SELECTION_IDS[v])
		end })
	add({ label = "Show the drive in the list", kind = "toggle",
		get = function() return prefs_is("show_where", "on") end,
		set = function(v) if v then prefs_set("show_where", "on") else prefs_set("show_where", "off") end end })
	add({ label = "Scrolling text speed", kind = "choice", values = SCROLL_LABELS,
		get = function() return index_of(SCROLL_MODES, prefs_get("scroll_speed"), 3) end,
		set = function(v)
			prefs_set("scroll_speed", SCROLL_MODES[v])
			gfx_scroll_speed(SCROLL_MODES[v])
		end })

	--- The game column ----------------------------------------------------------------
	-- A is the square beside the title, B and C the pair underneath: A | name over B | C.
	header("GAME COLUMN")
	local SLOT_LABEL = { a = "Picture beside the title", b = "Picture bottom left", c = "Picture bottom right" }
	for i = 1, #ART_SLOTS do
		local slot = ART_SLOTS[i]
		add({ label = SLOT_LABEL[slot], kind = "choice", values = ART_LABELS,
			get = function() return index_of(ART_KINDS, prefs_get("art_".. slot)) end,
			set = function(v) prefs_set("art_".. slot, ART_KINDS[v]) end })
	end

	--- Library ------------------------------------------------------------------------
	header("LIBRARY")
	add({ label = "Sort systems by", kind = "choice", values = SORT_LABELS,
		get = function() return index_of(SORT_MODES, prefs_get("sort")) end,
		set = function(v) systems_set_sort(SORT_MODES[v]) end })
	add({ label = "Rescan games", kind = "action", action = function()
		frontend_rescan()
		return "close"
	end })
	add({ label = "Empty the recent list", kind = "action", action = function()
		COLLECTIONS.recent = {}
		collections_save()
		collections_refresh()
		if log_event ~= nil then log_event("MENU", "recent list emptied") end
		return "close"
	end })

	--- Sound --------------------------------------------------------------------------
	header("SOUND")
	add({ label = "Menu sounds", kind = "toggle",
		get = function() return prefs_is("sound", "on") end,
		set = function(v) if v then prefs_set("sound", "on") else prefs_set("sound", "off") end end })
	if S_MUSICA ~= nil then
		add({ label = "Background music", kind = "toggle",
			get = function() return prefs_is("music", "on") end,
			set = function(v) if v then prefs_set("music", "on") else prefs_set("music", "off") end end })
	end

	--- The console --------------------------------------------------------------------
	header("SYSTEM")
	add({ label = "Video mode  (next start)", kind = "choice", values = { "Auto", "NTSC 480i", "PAL 576i" },
		get = function() return index_of(VIDEO, prefs_get("video")) end,
		set = function(v) prefs_set("video", VIDEO[v]); apply_video_pref() end })
	-- Marking a drive as the internal disk, from the sofa. Detection normally does
	-- this on its own - index.lua watches which drive appears when ata_bd loads - but
	-- on a warm restart the drivers are already resident and nothing appears. The
	-- alternative was to ask for a file to be created on a disk that lives inside the
	-- console, which means opening the console. This writes it instead.
	for i = 1, #(BDM_DEVICES or {}) do
		local dev = BDM_DEVICES[i]
		if BDM_ATA == nil or BDM_ATA[dev] ~= true then
			add({ label = dev .." is the internal disk", kind = "action", action = function()
				local flag = dev .."/internal-ata-disk.flag"
				pcall(function()
					local fd = System.openFile(flag, FCREATE)
					System.writeFile(fd, "Prism", 5)
					System.closeFile(fd)
				end)
				if log_event ~= nil then
					log_event("MENU", "marked ".. dev .." as internal: "
						.. tostring(doesFileExist(flag)))
				end
				if doesFileExist(flag) then BDM_ATA[dev] = true end
				frontend_rescan()
				return "close"
			end })
		end
	end

	local wle = nil
	if RUTA_WLE ~= nil then wle = RUTA_WLE(false) end
	if wle ~= nil then
		add({ label = "Open wLaunchELF", kind = "action", action = function()
			if log_event ~= nil then log_event("MENU", "wLaunchELF ".. wle) end
			boot_flush()
			System.loadELF(wle, 0, System.currentDirectory() .."/uLaunchELF/")
		end })
	end
	add({ label = "Restart Prism", kind = "action", action = function()
		if log_event ~= nil then log_event("MENU", "restart") end
		boot_flush()
		System.loadELF(System.currentDirectory() .."/Prism.elf", 0)
	end })
	add({ label = "Quit to PS2 menu", kind = "action", action = function()
		if log_event ~= nil then log_event("MENU", "quit") end
		boot_flush()
		System.exitToBrowser()
	end })

	--- About --------------------------------------------------------------------------
	header("ABOUT")
	add({ label = "Prism PS2 Launcher", kind = "info", get = function() return "created by soaresden" end })
	add({ label = "Games in the library", kind = "info", get = function()
		-- The collections are counted out: their entries are the same games again.
		local n = 0
		for i = 1, #LIBRARY.systems do
			local s = LIBRARY.systems[i]
			if s.virtual ~= true and s.games ~= nil then n = n + #s.games end
		end
		return tostring(n)
	end })
	add({ label = "Journal", kind = "info", get = function()
		return gfx_fit(tostring(BOOT_LOG_DESTINO or "not written"), THEME.size_text, 190)
	end })

	MAIN_MENU = menu_new("Main menu", opts)
	input_flush()
end

function main_menu_input()
	local r = menu_input(MAIN_MENU)
	if r == "close" then
		play_sfx(S_CANCELAR)
		MAIN_MENU = nil
		input_flush()
	elseif r == "changed" then
		play_sfx(S_MOVER)
	end
end

function main_menu_draw()
	dim_screen()
	menu_draw(MAIN_MENU)
end
