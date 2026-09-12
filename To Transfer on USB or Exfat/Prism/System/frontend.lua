-- Prism PS2 Launcher - frontend.lua
-- The interface: one loop, one current view, one optional modal. Loaded last by
-- system.lua, after the drives, the emulators and the sound are ready.
--
--   VIEW       "systems" | "gamelist" | "launch"
--   MAIN_MENU  the START menu when open (views/menu.lua)

VIEW = "systems"

--- Tracing the first frames. ------------------------------------------------------------
--- BOOT_FLUSH goes false once the boot is over, so everything logged afterwards sits in
--- memory until something flushes it - no use at all when the thing being chased is a
--- freeze, because a freeze never reaches the flush. This writes the line AND forces it
--- to disk, for the first few frames only. Set TRACE_FRAMES to 0 when the interface is
--- trusted: the cost is a whole file rewritten per line.
TRACE_FRAMES = 3

function trace(text)
	if TRACE_FRAMES <= 0 then return end
	boot_log("TRACE  ".. tostring(text))
	boot_flush()
end

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
	-- Coming back from a game is the moment a borrowed memory card has to go home,
	-- before anything reads the library or the player launches something else.
	if ps1_card_return ~= nil then pcall(ps1_card_return) end
	theme_selection(prefs_get("select_color"))
	gfx_scroll_speed(prefs_get("scroll_speed"))
	if sfx_volume ~= nil then pcall(sfx_volume, 65) end
	-- The library is built while the boot screen is still up; then the interface
	-- takes over. Fonts were made by the boot screen (gfx_init runs once).
	frontend_build_library()
	boot_log("BOOT   frontend ready, entering the systems view")
	boot_flush()
	load_end()
	trace("load_end done")
	systems_view_init()
	trace("systems_view_init done, ".. #LIBRARY.systems .." entries, "
		.. tostring(SYSTEMS_VIEW.list.rows) .." rows")
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
	trace("entering the loop")
	while true do
		trace("frame: input")
		input_poll()
		gfx_tick()

		if MAIN_MENU ~= nil then
			main_menu_input()
		elseif VIEW == "systems" then
			systems_view_input()
		elseif VIEW == "gamelist" then
			gamelist_input()
		elseif VIEW == "viewer" then
			viewer_input()
		elseif VIEW == "launch" then
			launch_view_input()
		end

		trace("frame: background")
		-- The viewer paints its own black background; everything else gets the gradient.
		if VIEW ~= "viewer" then gfx_background() end
		trace("frame: draw ".. tostring(VIEW))
		if VIEW == "systems" then
			systems_view_draw()
		elseif VIEW == "gamelist" then
			gamelist_draw()
		elseif VIEW == "viewer" then
			viewer_draw()
		elseif VIEW == "launch" then
			launch_view_draw()
		end
		if MAIN_MENU ~= nil then main_menu_draw() end

		trace("frame: flip")
		music_tick()
		Screen.flip()
		TRACE_FRAMES = TRACE_FRAMES - 1
		if TRACE_FRAMES == 0 then
			boot_log("TRACE  the interface is drawing; tracing stops here")
			boot_flush()
		end
	end
end
