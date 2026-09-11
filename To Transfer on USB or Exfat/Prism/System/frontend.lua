-- Prism PS2 Launcher - frontend.lua
-- The interface: one loop, one current view, one optional modal. Loaded last by
-- system.lua, after the drives, the emulators and the sound are ready.
--
--   VIEW       "systems" | "gamelist" | "launch"
--   MAIN_MENU  the START menu when open (views/menu.lua)

VIEW = "systems"

--- Menu sounds. S_MOVER / S_EJECUTAR / S_CANCELAR / S_NETX come from ui/sound.lua. -----
function play_sfx(sound)
	if sound == nil then return end
	if prefs_is("sound", "on") == false then return end
	local voice = 1
	if sfx_voice ~= nil then voice = sfx_voice(sound, 1) end
	pcall(Sound.playADPCM, voice, sound)
end

--- Background music: the track loops by being re-triggered whenever its voice is free
--- (audsrv refuses to restart a busy voice, so calling this every frame is harmless).
local function music_tick()
	if S_MUSICA == nil then return end
	if prefs_is("music", "on") then pcall(Sound.playADPCM, 2, S_MUSICA) end
end

--- Build the library with the boot checklist showing progress. -----------------------
function frontend_build_library()
	load_step("scanning games")
	library_build(function(name, count)
		load_step(name .."  ".. count)
	end)
	load_step("game lists built", true)
end

--- Rescan from the menu: same thing, on the launch box instead of the boot screen. ---
function frontend_rescan()
	launch_begin("Scanning games")
	library_build(function(name, count)
		launch_step(name .."  ".. count)
	end)
	gfx_free_images()
	systems_view_init()
	VIEW = "systems"
	input_flush()
end

function frontend_start()
	prefs_load()
	if sfx_volume ~= nil then pcall(sfx_volume, 65) end
	-- The library is built while the boot checklist is still on screen. Only then does
	-- the interface take the screen: Font.ftInit() a second time invalidates the boot
	-- screen's font handle, so it must come after the last load_step().
	frontend_build_library()
	boot_log("BOOT   frontend ready, entering the systems view")
	boot_flush()
	if load_end ~= nil then load_end() end
	gfx_init()
	gfx_set_screen(LOAD_RES_X or 640, LOAD_RES_Y or 448)
	systems_view_init()
	-- Reopen where the user was.
	local last = prefs_get("last_system")
	if last ~= nil and last ~= "" then
		for i = 1, #LIBRARY.systems do
			if LIBRARY.systems[i].folder == last then SYSTEMS_VIEW.list.sel = i end
		end
		list_scroll(SYSTEMS_VIEW.list)
	end
	input_flush()
end

function frontend_run()
	while true do
		input_poll()

		if MAIN_MENU ~= nil then
			main_menu_input()
		elseif VIEW == "systems" then
			systems_view_input()
		elseif VIEW == "gamelist" then
			gamelist_input()
		elseif VIEW == "launch" then
			launch_view_input()
		end

		gfx_background()
		if VIEW == "systems" then
			systems_view_draw()
		elseif VIEW == "gamelist" then
			gamelist_draw()
		elseif VIEW == "launch" then
			launch_view_draw()
		end
		if MAIN_MENU ~= nil then main_menu_draw() end

		music_tick()
		Screen.flip()
	end
end
