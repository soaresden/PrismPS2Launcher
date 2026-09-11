-- Prism PS2 Launcher - emu/retroarch_prepare.lua
-- Putting on the USB stick exactly what one core needs, at launch time.
-- Moved verbatim from the former launch/run.lua. Reports progress through
-- launch_step / launch_replace / LIBRETRO_PANTALLA, defined by the interface.

--- Preparacion de RetroArch en la llave, EN EL MOMENTO DE LANZAR. --------------------
--- Un core oficial no sabe leer el disco interno: al arrancar hace SifIopReset, el IOP
--- se vacia y ese disco deja de existir para el. Su instalacion tiene que estar en un
--- soporte que sobreviva al reset.
---
--- Copiarla entera al arrancar el lanzador era mala idea: 75 MB, y aunque se hiciera
--- de fondo el menu se arrastraba. Y sobre todo era trabajo hecho por adelantado para
--- juegos que quiza no se lanzan nunca.
---
--- Aqui se hace al pulsar sobre un juego, y solo lo que ESE juego necesita: su core,
--- su ".info", y la configuracion. Un megabyte y medio, una vez por core. La segunda
--- vez que se lanza un juego de esa consola ya no hay nada que copiar.
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

--- Copia un fichero si falta o si no coincide el tamano. Devuelve true si copio. -----
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

--- Deja listo en la llave lo que hace falta para lanzar ESTE core. -------------------
--- Devuelve la carpeta que hay que usar, o nil si no se ha podido preparar nada.
function LIBRETRO_PREPARAR_PARA(nombre_core)
	LIBRETRO_FORZADO = nil
	if LIBRETRO_AUTO_USB ~= true then return RUTA_LIBRETRO() end
	-- El ORIGEN de la copia es la maestra: es la unica que tiene el core que se pide.
	local casa = libretro_master_path()
	if casa == nil then return nil end
	-- Ya esta donde el core sabra leerla: nada que preparar.
	if ES_RAIZ_ATA(casa) == false then return casa end

	-- Destino: una llave USB. La tarjeta de memoria no sirve, son 8 MB.
	local destinos = ROM_DESTINOS()
	local dev = nil
	for i = 1, #destinos do
		if dev == nil and string.lower(string.sub(destinos[i], 1, 4)) == "mass" then
			dev = destinos[i]
		end
	end
	if dev == nil then
		boot_log("RETROARCH  sin llave USB: este juego no puede arrancar.")
		boot_flush()
		LIBRETRO_PANTALLA(COPIA_TITULO, "No USB stick: this game cannot start", 0, nil)
		System.sleep(3)
		return nil
	end

	-- En "<llave>/Prism/LibretroPS2Files", el mismo sitio que en el disco.
	local destino = dev .."/".. CARPETA_LANZADOR .."/LibretroPS2Files"

	COPIA_HECHOS = 0
	COPIA_TOTAL = 0

	CREAR_CADENA(dev, CARPETA_LANZADOR .."/LibretroPS2Files")
	CREAR_CADENA(destino, "cores")
	CREAR_CADENA(destino, "info")

	-- TODAS las carpetas que la configuracion nombra. RetroArch ABRE los ficheros de
	-- sus carpetas pero NO crea las carpetas: sin "temp/" (cache_directory) no puede
	-- descomprimir el .zip de la ROM, y muere sin dibujar. Sin "logs/" tampoco escribe
	-- su propio log. Crear un directorio es gratis; no crearlo cuesta un arranque.
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
		boot_log("RETROARCH  NO se han podido crear:".. faltan)
		boot_flush()
		launch_step("Cannot create folders on USB")
	end

	-- "retroarch.cfg" se MACHACA, sin mirar si coincide: RetroArch reescribe el suyo
	-- cada vez que sale, en la llave. El disco manda.
	launch_step("Writing retroarch.cfg")
	if doesFileExist(casa .."/retroarch/retroarch.cfg") then
		pcall(System.copyFile, casa .."/retroarch/retroarch.cfg",
		      destino .."/retroarch/retroarch.cfg")
	end
	-- Los ajustes por core, por la misma razon.
	COPIAR_ARBOL(casa .."/retroarch/config", destino .."/retroarch/config", 0)

	-- "raboot.elf": con el en la llave, RetroArch se puede abrir desde uLaunchELF sin
	-- pasar por Prism. Son 300 KB y se copia una sola vez.
	if doesFileExist(casa .."/raboot.elf") and doesFileExist(destino .."/raboot.elf") == false then
		copy_with_progress(casa .."/raboot.elf", destino .."/raboot.elf", "raboot.elf")
	end

	-- El core del juego y su ".info", nada mas.
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
		boot_log("RETROARCH  no se ha podido poner ".. nombre_core .." en ".. destino)
		boot_flush()
		LIBRETRO_PANTALLA(COPIA_TITULO, "Could not copy ".. nombre_core, 0, nil)
		System.sleep(3)
		return nil
	end

	if COPIA_HECHOS > 0 then
		boot_log("RETROARCH  ".. tostring(COPIA_HECHOS) .." fichero(s) preparados en ".. destino)
		boot_flush()
	end
	-- A partir de aqui, TODO -- config, BIOS, partidas -- apunta a la llave.
	LIBRETRO_FORZADO = destino
	return destino
end
