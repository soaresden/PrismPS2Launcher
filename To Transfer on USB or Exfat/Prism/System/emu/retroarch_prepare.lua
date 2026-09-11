-- Prism PS2 Launcher - emu/retroarch_prepare.lua
-- Putting on the USB stick exactly what one core needs, at launch time.
-- Moved verbatim from the former launch/run.lua. Reports progress through
-- launch_step / launch_replace / LIBRETRO_PANTALLA, defined by the interface.

--- Preparing RetroArch on the USB stick, AT LAUNCH TIME. -----------------------------
--- An official core cannot read the internal drive: on starting it does a SifIopReset,
--- the IOP is wiped and that drive stops existing for it. Its installation has to sit
--- on a medium that survives the reset.
---
--- Copying the whole of it when the launcher starts was a bad idea: 75 MB, and even
--- done in the background the menu dragged. Above all it was work done in advance for
--- games that may never be launched at all.
---
--- Here it happens when a game is pressed, and only what THAT game needs: its core,
--- its ".info", and the configuration. A megabyte and a half, once per core. The second
--- time a game for that console is launched there is nothing left to copy.
LIBRETRO_AUTO_USB = true
COPIA_TITULO = "Preparing RetroArch on the USB stick"
COPIA_HECHOS = 0
COPIA_TOTAL = 0

--- "fceumm_libretro_ps2.elf" -> "fceumm_libretro.info" -------------------------------
function CORE_A_INFO(nombre)
	if nombre == nil then return nil end
	if string.len(nombre) < 9 or string.sub(nombre, -8) ~= "_ps2.elf" then return nil end
	return string.sub(nombre, 1, -9) ..".info"
end

--- Copies a file if missing or if the size differs. Returns true if it copied. -------
function COPIA_SI_HACE_FALTA(origen, destino, etiqueta)
	if doesFileExist(origen) == false then return false end
	local a = ROM_TAMANO(origen)
	if doesFileExist(destino) then
		local b = ROM_TAMANO(destino)
		if a ~= nil and a == b then return false end
	end
	COPIA_HECHOS = COPIA_HECHOS + 1
	LIBRETRO_PANTALLA(COPIA_TITULO, etiqueta, COPIA_HECHOS, COPIA_TOTAL)
	pcall(System.copyFile, origen, destino)
	return true
end

--- Puts on the USB stick what is needed to launch THIS core. -------------------------
--- Returns the folder to use, or nil if nothing could be prepared.
function LIBRETRO_PREPARAR_PARA(nombre_core)
	LIBRETRO_FORZADO = nil
	if LIBRETRO_AUTO_USB ~= true then return RUTA_LIBRETRO() end
	-- The SOURCE of the copy is the master: it is the only one with the core being asked for.
	local casa = libretro_master_path()
	if casa == nil then return nil end
	-- Already where the core will know how to read it: nothing to prepare.
	if ES_RAIZ_ATA(casa) == false then return casa end

	-- Destination: a USB stick. The memory card is no use, it is 8 MB.
	local destinos = ROM_DESTINOS()
	local dev = nil
	for i = 1, #destinos do
		if dev == nil and string.lower(string.sub(destinos[i], 1, 4)) == "mass" then
			dev = destinos[i]
		end
	end
	if dev == nil then
		boot_log("RETROARCH  no USB stick: this game cannot start.")
		boot_flush()
		LIBRETRO_PANTALLA(COPIA_TITULO, "No USB stick: this game cannot start", 0, nil)
		System.sleep(3)
		return nil
	end

	-- In "<stick>/Prism/LibretroPS2Files", the same place as on the drive.
	local destino = dev .."/".. CARPETA_LANZADOR .."/LibretroPS2Files"

	COPIA_HECHOS = 0
	COPIA_TOTAL = 0

	CREAR_CADENA(dev, CARPETA_LANZADOR .."/LibretroPS2Files")
	CREAR_CADENA(destino, "cores")
	CREAR_CADENA(destino, "info")

	-- ALL the folders the configuration names. RetroArch OPENS the files inside its own
	-- folders but does NOT create the folders: without "temp/" (cache_directory) it cannot
	-- unpack the ROM's .zip, and dies without drawing. Without "logs/" it cannot write
	-- its own log either. Creating a directory is free; not creating it costs a boot.
	local esqueleto = {"retroarch", "retroarch/config", "retroarch/config/remaps",
		"retroarch/system", "retroarch/logs", "retroarch/temp",
		"retroarch/savefiles", "retroarch/savestates", "retroarch/assets",
		"retroarch/cheats", "retroarch/database", "retroarch/database/rdb",
		"retroarch/downloads", "retroarch/overlays", "retroarch/thumbnails",
		"retroarch/playlists", "retroarch/playlists/builtin"}
	local faltan = ""
	for i = 1, #esqueleto do
		CREAR_CADENA(destino, esqueleto[i])
		if System.listDirectory(destino .."/".. esqueleto[i]) == nil then
			faltan = faltan .." ".. esqueleto[i]
		end
	end
	if faltan ~= "" then
		boot_log("RETROARCH  could NOT create:".. faltan)
		boot_flush()
		launch_step("Cannot create folders on USB")
	end

	-- "retroarch.cfg" is OVERWRITTEN, without checking whether it matches: RetroArch
	-- rewrites its own on the stick every time it exits. The drive has the last word.
	launch_step("Writing retroarch.cfg")
	if doesFileExist(casa .."/retroarch/retroarch.cfg") then
		pcall(System.copyFile, casa .."/retroarch/retroarch.cfg",
		      destino .."/retroarch/retroarch.cfg")
	end
	-- The per-core settings, for the same reason.
	COPIAR_ARBOL(casa .."/retroarch/config", destino .."/retroarch/config", 0)

	-- "raboot.elf": with it on the stick, RetroArch can be opened from uLaunchELF without
	-- going through Prism. It is 300 KB and is copied only once.
	if doesFileExist(casa .."/raboot.elf") and doesFileExist(destino .."/raboot.elf") == false then
		copy_with_progress(casa .."/raboot.elf", destino .."/raboot.elf", "raboot.elf")
	end

	-- The game's core and its ".info", nothing more.
	COPIA_TOTAL = 2
	local core_origen = casa .."/cores/".. nombre_core
	local core_destino = destino .."/cores/".. nombre_core
	local ya_esta = (doesFileExist(core_destino)
		and ROM_TAMANO(core_destino) ~= nil
		and ROM_TAMANO(core_destino) == ROM_TAMANO(core_origen))
	if ya_esta == true then
		launch_step("Core already on USB", true)
	else
		launch_step("Copying core")
		copy_with_progress(core_origen, core_destino, "core")
	end
	local info = CORE_A_INFO(nombre_core)
	if info ~= nil then
		COPIA_SI_HACE_FALTA(casa .."/info/".. info, destino .."/info/".. info, info)
	end

	if doesFileExist(destino .."/cores/".. nombre_core) == false then
		boot_log("RETROARCH  could not put ".. nombre_core .." in ".. destino)
		boot_flush()
		LIBRETRO_PANTALLA(COPIA_TITULO, "Could not copy ".. nombre_core, 0, nil)
		System.sleep(3)
		return nil
	end

	if COPIA_HECHOS > 0 then
		boot_log("RETROARCH  ".. tostring(COPIA_HECHOS) .." file(s) prepared in ".. destino)
		boot_flush()
	end
	-- From here on, EVERYTHING -- config, BIOS, saves -- points at the stick.
	LIBRETRO_FORZADO = destino
	return destino
end
