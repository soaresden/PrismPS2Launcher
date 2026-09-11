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

function main_menu_open()
	local opts = {}
	opts[#opts + 1] = { label = "Video mode  (next start)", kind = "choice", values = { "Auto", "NTSC 480i", "PAL 576i" },
		get = function()
			local v = prefs_get("video")
			for i = 1, #VIDEO do if VIDEO[i] == v then return i end end
			return 1
		end,
		set = function(v) prefs_set("video", VIDEO[v]); apply_video_pref() end }
	opts[#opts + 1] = { label = "Menu sounds", kind = "toggle",
		get = function() return prefs_is("sound", "on") end,
		set = function(v) if v then prefs_set("sound", "on") else prefs_set("sound", "off") end end }
	if S_MUSICA ~= nil then
		opts[#opts + 1] = { label = "Background music", kind = "toggle",
			get = function() return prefs_is("music", "on") end,
			set = function(v) if v then prefs_set("music", "on") else prefs_set("music", "off") end end }
	end
	opts[#opts + 1] = { label = "Rescan games", kind = "action", action = function()
		frontend_rescan()
		return "close"
	end }
	local wle = nil
	if RUTA_WLE ~= nil then wle = RUTA_WLE(false) end
	if wle ~= nil then
		opts[#opts + 1] = { label = "Open wLaunchELF", kind = "action", action = function()
			if log_event ~= nil then log_event("MENU", "wLaunchELF ".. wle) end
			boot_flush()
			System.loadELF(wle, 0, System.currentDirectory() .."/uLaunchELF/")
		end }
	end
	opts[#opts + 1] = { label = "Restart Prism", kind = "action", action = function()
		if log_event ~= nil then log_event("MENU", "restart") end
		boot_flush()
		System.loadELF(System.currentDirectory() .."/Prism.elf", 0)
	end }
	opts[#opts + 1] = { label = "Quit to PS2 menu", kind = "action", action = function()
		if log_event ~= nil then log_event("MENU", "quit") end
		boot_flush()
		System.exitToBrowser()
	end }
	opts[#opts + 1] = { label = "Prism PS2 Launcher", kind = "info", get = function() return "created by soaresden" end }
	opts[#opts + 1] = { label = "Journal", kind = "info", get = function()
		return gfx_fit(tostring(BOOT_LOG_DESTINO or "not written"), THEME.size_text, 190)
	end }
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
