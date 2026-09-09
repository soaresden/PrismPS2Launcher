-- Prism PS2 Launcher - emu/retroarch.lua
-- RetroArch: locating the install, cores, forced retroarch.cfg values.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- Carpeta de medios por identidad, incluidos los sistemas sin alias EmulationStation
--- (APPS, PS1, PS2). Es el nombre usado bajo "Roms/<aqui>/media/".
--- Arranque de RetroArch a traves de "raboot.elf". ----------------------------------
--- DESCARTADO, y el motivo esta en el codigo de RetroArch. "raboot.elf" es el
--- Salamander, y en "frontend/drivers/platform_ps2.c" el bloque que pasa el juego al
--- core esta dentro de un "#ifndef IS_SALAMANDER": el Salamander llama al core con
--- CERO argumentos. Nunca podra arrancar una ROM, solo abrir el menu de RetroArch.
--- Ademas reescribe "retroarch-salamander.cfg" con su propia eleccion, borrando la
--- nuestra. Se deja el camino por si sirve para depurar, apagado.
RABOOT_ON = false

--- Devuelve la ruta de raboot.elf si esta disponible, si no nil. ---------------------
function RUTA_RABOOT()
	if RABOOT_ON ~= true or RAICES == nil then return nil end
	for i = 1, #RAICES do
		local base = RUTA_LIBRETRO()
		local cand = RAICES[i] .."/LibretroPS2Files/raboot.elf"
		if base ~= nil then cand = base .."/raboot.elf" end
		if doesFileExist(cand) then return cand end
	end
	return nil
end

--- Escribe el core elegido en el salamander que lee raboot. -------------------------
--- Ruta del salamander que corresponde a un raboot.elf dado. -------------------------
function RUTA_SALAMANDER(ruta_raboot)
	if ruta_raboot == nil then return nil end
	-- "raboot.elf" son 10 caracteres: hay que quitar 10, no 11. Con -12 se comia
	-- tambien la barra y el fichero se escribia en una ruta inexistente, en silencio.
	local base = string.sub(ruta_raboot, 1, string.len(ruta_raboot) - 10)
	return base .."retroarch/retroarch-salamander.cfg"
end

--- Escribe el core elegido en el salamander que lee raboot. -------------------------
--- Se relee despues: si el contenido no es el esperado, se devuelve false y el
--- lanzamiento cae en la llamada directa en vez de arrancar el core anterior.
function PREPARAR_RABOOT(ruta_raboot, ruta_core)
	if ruta_raboot == nil or ruta_core == nil then return false end
	local cfg = RUTA_SALAMANDER(ruta_raboot)
	local linea = "libretro_path = \"".. ruta_core .."\"\n"
	pcall(function()
		local f = System.openFile(cfg, FCREATE)
		System.writeFile(f, linea, string.len(linea))
		System.closeFile(f)
	end)
	local leido = nil
	pcall(function()
		local f = System.openFile(cfg, FREAD)
		local tam = System.sizeFile(f)
		System.seekFile(f, 0, SET)
		leido = System.readFile(f, tam)
		System.closeFile(f)
	end)
	return leido ~= nil and string.find(leido, ruta_core, 1, true) ~= nil
end

--- Carpetas del modulo RetroArch. ----------------------------------------------------
---
---   LibretroPS2Files/
---     cores/  info/  raboot.elf       la nightly, descomprimida tal cual
---     retroarch/retroarch.cfg         LA configuracion. Una. No hay copia de fabrica.
---     retroarch/config/<Core>/        los ajustes por core
---
--- Hubo aqui una carpeta "DefaultCFGs/" que guardaba un segundo "retroarch.cfg" del
--- que se reconstruia el primero. Se ha quitado: dos ficheros con el mismo papel es
--- una ocasion de que difieran, y no hacia falta. Una nightly no trae "retroarch/", y
--- si falta, RetroArch se escribe el suyo con sus propios valores -- que es justamente
--- lo que una copia de fabrica intentaba imitar. El lanzador solo tiene que reimponer
--- encima sus claves, y eso lo hace en cada arranque de juego.
---
--- RetroArch encuentra sus carpetas solo: al arrancar, un core toma su propio
--- directorio y SUBE UN NIVEL ("path_parent_dir" en "frontend/drivers/platform_ps2.c"),
--- asi que la carpeta que contiene "cores/" es su raiz. Da igual como se llame.
--- Donde puede estar la nightly, en orden de preferencia. Se acepta tanto
--- descomprimida en su propia subcarpeta como directamente en LibretroPS2Files.
LIBRETRO_SUBS = {"/LibretroPS2Files", "/LibretroPS2Files/UnzippedFileHere"}

--- La raiz de RetroArch: la carpeta que contiene "cores/". ---------------------------
--- PRIORIDAD AL SOPORTE QUE EL CORE PODRA LEER. Un core arranca haciendo SifIopReset:
--- el ELF ya esta en RAM, pero el IOP se vacia y el disco interno deja de existir para
--- el. Si sus "cores/", "info/" y "retroarch/" estan en ese disco, se queda sin nada
--- que leer y muere antes de dibujar el primer fotograma. Ni siquiera "raboot.elf"
--- sobrevive: no encuentra los cores y sale.
--- Es un problema conocido, no una particularidad de este fork: el autor de PSBBN da
--- el mismo rodeo en su issue #448 -- el ELF donde se quiera, TODO lo demas en el USB.
--- Por eso se busca primero en un soporte que no sea el disco ATA, y solo se cae al
--- disco interno si no hay otra cosa (donde funcionara con cores parcheados, y solo
--- con ellos).
--- Instalacion impuesta para este lanzamiento, si ha habido que preparar una. --------
LIBRETRO_FORZADO = nil

--- Y el resultado del ultimo rastreo, para no repetirlo. ------------------------------
--- Esto NO es una optimizacion cosmetica. Cada rastreo lista "cores/" en hasta seis
--- sitios, y esa carpeta lleva una decena de ELF de varios MB: sobre exFAT via BDM
--- cuesta segundos. Se llamaba tres veces solo durante el arranque -- LIBRETRO_REPARAR,
--- el diagnostico, y la pantalla de carga -- y el resultado no puede cambiar entre
--- ellas. La pantalla parecia colgada porque, sencillamente, lo estaba esperando.
--- "" quiere decir "ya se busco y no habia nada", que es distinto de "aun no se ha
--- buscado": sin esa distincion, el caso "no hay RetroArch" repetiria el rastreo entero
--- en cada llamada, que es justamente el mas caro de todos.
LIBRETRO_CACHE = nil

function RUTA_LIBRETRO()
	if LIBRETRO_FORZADO ~= nil then return LIBRETRO_FORZADO end
	if LIBRETRO_CACHE == "" then return nil end
	if LIBRETRO_CACHE ~= nil then return LIBRETRO_CACHE end
	if RAICES == nil then return nil end   -- aun sin unidades: no se guarda nada
	-- Tres pasadas: primero una instalacion completa fuera del disco interno, que es
	-- la unica que un core sabra leer; luego una completa donde sea; y en ultimo
	-- lugar cualquier cosa que tenga cores, para al menos poder decir algo.
	for pasada = 1, 3 do
		for i = 1, #RAICES do
			local es_ata = ES_RAIZ_ATA(RAICES[i] .."/x")
			if pasada ~= 1 or es_ata == false then
				for k = 1, #LIBRETRO_SUBS do
					local cand = RAICES[i] .. LIBRETRO_SUBS[k]
					if System.listDirectory(cand .."/cores") ~= nil then
						if pasada == 3 or LIBRETRO_COMPLETO(cand) == true then
							LIBRETRO_CACHE = cand
							return cand
						end
					end
				end
			end
		end
	end
	LIBRETRO_CACHE = ""
	return nil
end

--- Una instalacion sirve solo si esta COMPLETA. --------------------------------------
--- Tener la carpeta no basta: una copia a medias -- cortada a mitad de un despliegue,
--- o de una version anterior del arbol -- ganaria la eleccion y bloquearia para
--- siempre el despliegue que deberia repararla. Se exige lo minimo indispensable: los
--- cores, y la configuracion.
function LIBRETRO_COMPLETO(base)
	if base == nil then return false end
	if System.listDirectory(base .."/cores") == nil then return false end
	if doesFileExist(base .."/retroarch/retroarch.cfg") == false then return false end
	return true
end

--- Monta la carpeta "retroarch/" que RetroArch exige. --------------------------------
--- El contrato con el usuario es simple: descomprimir una nightly dentro de
--- "LibretroPS2Files/" -- raboot.elf, cores/, info/ -- y que funcione. Todo lo demas
--- lo pone el lanzador aqui.
---
--- Y hace falta ponerlo, porque una nightly NO trae la carpeta "retroarch/", mientras
--- que RetroArch la exige y no admite discusion: "create_path_names()" toma el
--- directorio del core, sube un nivel y busca "retroarch/retroarch.cfg" ahi. Esa ruta
--- esta compilada dentro del binario. Es el unico anclaje rigido de todo el montaje;
--- el resto de carpetas si se pueden mover, porque el lanzador las escribe despues en
--- la configuracion ("libretro_directory", "system_directory"...).
---
--- Aqui no se copia nada: solo se crean las carpetas que faltan. El "retroarch.cfg"
--- no se restaura de ningun molde -- si no esta, lo escribe FORZAR_CONF_RETROARCH con
--- las claves del lanzador, y RetroArch completa el resto con sus propios valores la
--- primera vez que guarda.
function LIBRETRO_REPARAR()
	local base = RUTA_LIBRETRO()
	if base == nil then return false end

	local necesarias = {"/retroarch", "/retroarch/config", "/retroarch/config/remaps",
		"/retroarch/system", "/retroarch/logs", "/retroarch/temp",
		"/retroarch/savefiles", "/retroarch/savestates", "/retroarch/assets",
		"/retroarch/cheats", "/retroarch/playlists", "/retroarch/thumbnails",
		"/retroarch/downloads", "/retroarch/overlays", "/retroarch/database"}
	for i = 1, #necesarias do
		if System.listDirectory(base .. necesarias[i]) == nil then
			System.createDirectory(base .. necesarias[i])
		end
	end

	local cfg = base .."/retroarch/retroarch.cfg"
	if doesFileExist(cfg) == false then
		boot_log("CONF   sin ".. cfg .." : se escribira al lanzar el primer juego")
		boot_flush()
	end
	return true
end

--- Donde caen NUESTRAS tres carpetas -- Bios, Saves, SaveStates. ----------------------
--- Normalmente junto al lanzador, que es donde el usuario las ve. Pero si el lanzador
--- corre desde el disco interno ATA y el core no lleva ata_bd, ese disco no existe para
--- el: entonces van al mismo sitio que la ROM transbordada, y el puente de partidas las
--- trae de vuelta al arrancar. Devuelve la raiz y, si el core SI lee ATA, el nombre que
--- ese disco tendra del otro lado del SifIopReset.
function RAIZ_DATOS(lee_ata)
	local actual = System.currentDirectory()
	if ES_RAIZ_ATA(actual .."/Saves") == false then return actual, nil end
	if lee_ata == true then return actual, DEV_ATA_PARA_CORE() end
	local destinos = ROM_DESTINOS()
	if #destinos >= 1 then
		CREAR_CADENA(destinos[1], string.sub(ROM_SHUTTLE_SUB, 2))
		return destinos[1] .. ROM_SHUTTLE_SUB, nil
	end
	return actual, nil
end

--- "Bios/" es la UNICA copia de referencia de cada BIOS. ------------------------------
--- Se le da a RetroArch como "system_directory", asi que no hay segunda copia que
--- mantener. Un solo caso la necesita: cuando el core no puede leer el disco donde esta
--- "Bios/", y entonces se deposita en la llave lo poco que RetroArch busca ahi.
BIOS_LIBRETRO_LISTA = {"gba_bios.bin"}

function BIOS_LIBRETRO(lee_ata)
	local raiz = RAIZ_DATOS(lee_ata)
	if raiz == System.currentDirectory() then return end   -- ya la lee donde esta
	local destino = raiz .."/Bios"
	if System.listDirectory(destino) == nil then
		System.createDirectory(destino)
		if System.listDirectory(destino) == nil then return end
	end
	for i = 1, #BIOS_LIBRETRO_LISTA do
		local fichero = BIOS_LIBRETRO_LISTA[i]
		if doesFileExist(destino .."/".. fichero) == false then
			local origen = RUTA_BIOS(fichero, "")
			if doesFileExist(origen) then
				pcall(System.copyFile, origen, destino .."/".. fichero)
				boot_log("BIOS   ".. fichero .." -> ".. destino .." : ".. tostring(doesFileExist(destino .."/".. fichero)))
			else
				boot_log("BIOS   ".. fichero .." AUSENTE en Bios/")
			end
			boot_flush()
		end
	end
end

--- Se puede arrancar HOY un core de RetroArch? ---------------------------------------
--- Devuelve false y el motivo cuando no. Dos casos: no hay instalacion en ningun sitio,
--- o la hay pero en el disco interno y no hay llave USB donde transbordarla. La tarjeta
--- de memoria no cuenta: 8 MB no dan ni para un core.
function LIBRETRO_POSIBLE()
	-- "Hay instalacion?" se pregunta a la maestra; "podra leerla un core?" tambien,
	-- porque de ella se copia lo que acabe en la llave.
	local base = libretro_master_path()
	if base == nil then return false, "no RetroArch installation found" end
	if ES_RAIZ_ATA(base) == false then return true, base end
	local destinos = ROM_DESTINOS()
	for i = 1, #destinos do
		if string.lower(string.sub(destinos[i], 1, 4)) == "mass" then
			return true, base .." via ".. destinos[i]
		end
	end
	return false, "RetroArch on the internal drive and no USB stick"
end

--- Sin core posible, los doce sistemas libretro no se ofrecen. ------------------------
--- Mas vale una consola ausente que una consola que abre y devuelve "Games or
--- RetroArch not found" en cada juego.
LIBRETRO_SISTEMAS_OFF = false
LIBRETRO_SISTEMAS_MOTIVO = nil

function LIBRETRO_APAGAR_SI_IMPOSIBLE()
	local ok, motivo = LIBRETRO_POSIBLE()
	LIBRETRO_SISTEMAS_OFF = (ok ~= true)
	LIBRETRO_SISTEMAS_MOTIVO = motivo
	if ok == true then
		boot_log("SISTEMAS  libretro disponibles: ".. tostring(motivo))
		boot_flush()
		return false
	end
	boot_log("SISTEMAS  libretro DESACTIVADOS: ".. tostring(motivo))
	boot_flush()
	SISTEMAS.MEGADRIVE_ON = 0
	SISTEMAS.MASTERSYSTEM_ON = 0
	SISTEMAS.GAMEGEAR_ON = 0
	SISTEMAS.FAMICOM_ON = 0
	SISTEMAS.GAMEBOY_ON = 0
	SISTEMAS.GAMEBOYCOLOR_ON = 0
	SISTEMAS.GAMEBOYADVANCE_ON = 0
	SISTEMAS.ATARI2600_ON = 0
	SISTEMAS.ATARILYNX_ON = 0
	SISTEMAS.SEGASG1000_ON = 0
	SISTEMAS.NEOGEOPOCKET_ON = 0
	SISTEMAS.SUPERFAMICOM_ON = 0
	return true
end

--- Interruptores de diagnostico. -----------------------------------------------------
--- Pantalla negra al lanzar un juego? Poner uno de estos a false y volver a probar,
--- de uno en uno. No hace falta recompilar nada.
---   RETROARCH_FORZAR_ON     a false: no se toca "retroarch.cfg" en absoluto.
---   RETROARCH_FORZAR_VIDEO  a false: se fuerzan las carpetas, pero NO el modo de
---                           video. Un "current_resolution_id" que el televisor no
---                           acepta da exactamente una pantalla negra.
RETROARCH_FORZAR_ON = true
--- A false, y por una razon concreta. El bloque PAL escribe current_resolution_id=1,
--- video_refresh_rate=54.5 y vrr_runloop_enable=true. Esos valores vienen de las
--- configuraciones de Boon Tobias y NUNCA se han comprobado en hardware. Lo que si se
--- ha comprobado, en esta misma consola PAL y con un juego funcionando, es lo
--- contrario: current_resolution_id=0 y 59.940063, con "[PS2_GFX] New vmode: 0,
--- 704x576" en el log de RetroArch. Forzar un modo de video que la consola no produce
--- es una de las dos formas conocidas de acabar en pantalla negra.
--- A true vuelven a imponerse, si algun dia se comprueban.
RETROARCH_FORZAR_VIDEO = false

--- Ajustes que el lanzador impone a RetroArch antes de cada juego. --------------------
--- RetroArch guarda su configuracion al salir y el usuario puede tocarla desde el
--- menu: lo que hay aqui se reescribe en cada arranque. Para anadir un ajuste, basta
--- con meterlo en la tabla.
RETROARCH_FORZADO = {
	-- Las partidas viven FUERA del arbol de RetroArch, en "Saves/" y "SaveStates/".
	-- "in_content_dir" las pondria junto a la ROM; "sort_..._enable" las agruparia por
	-- core, y entonces PicoDrive mezclaria cuatro consolas Sega en una sola carpeta.
	-- Por carpeta de contenido sale "Saves/<consola>/", el mismo nombre que en "Roms/".
	{"savefiles_in_content_dir",          "false"},
	{"savestates_in_content_dir",         "false"},
	{"sort_savefiles_enable",             "false"},
	{"sort_savestates_enable",            "false"},
	{"sort_savefiles_by_content_enable",  "true"},
	{"sort_savestates_by_content_enable", "true"},

	-- 21 = "Square pixel": un pixel de la consola es un pixel de pantalla. Lo que
	-- venia por defecto era 22, "Core provided", que en PS2 deja la imagen estirada.
	-- Si lo que se queria era el "1:1" literal del menu de RetroArch, ese es el 5.
	-- Los overrides por core siguen mandando sobre esto, que es lo correcto: una
	-- Game Boy es 10:9 pase lo que pase.
	{"aspect_ratio_index", "21"},
}

--- Lo unico que separa una configuracion NTSC de una PAL. -----------------------------
--- Boot Tobias mantenia para esto veinticuatro "retroarch.cfg" completos, doce por modo
--- de video. La diferencia real son estas seis claves.
--- Aqui NO estan "aspect_ratio_index" ni "video_scale_integer", que si estaban antes.
--- No son propiedades del modo de video sino gustos del usuario: una Game Boy es 10:9
--- en NTSC como en PAL. Forzarlos deshacia en cada arranque lo que se hubiera elegido
--- en el menu de RetroArch. Su valor vive en retroarch/retroarch.cfg, que es el unico,
--- cada core lo afina con su override.
--- Hay una clave que tambien cambiaba, "video_vsync", pero no de forma uniforme: en PAL
--- valia "false" solo para Neo Geo Pocket, Game Boy, Game Boy Color y Super Famicom.
--- Eso es por sistema Y por modo a la vez, que no cabe en esta tabla.
RETROARCH_VIDEO = {
	NTSC = {
		{"video_refresh_rate",     "59.940063"},
		{"crt_video_refresh_rate", "59.940063"},
		{"current_resolution_id",  "0"},
		{"vrr_runloop_enable",     "false"},
	},
	PAL = {
		{"video_refresh_rate",     "54.500000"},
		{"crt_video_refresh_rate", "54.500000"},
		{"current_resolution_id",  "1"},
		{"vrr_runloop_enable",     "true"},
	},
}

--- Escribe todo lo anterior en el "retroarch.cfg" de RetroArch. -----------------------
function FORZAR_CONF_RETROARCH(pal, lee_ata)
	if RETROARCH_FORZAR_ON ~= true then
		boot_log("CONF   desactivado (RETROARCH_FORZAR_ON = false)")
		boot_flush()
		return false
	end
	local base = RUTA_LIBRETRO()
	if base == nil then
		boot_log("CONF   carpeta de RetroArch no encontrada, sin ajustes que forzar")
		boot_flush()
		return false
	end
	-- No hay copia de fabrica de la que sacarlo: si falta, se crea vacio y las claves
	-- de abajo lo llenan. RetroArch anade despues las suyas al guardar.
	local cfg = base .."/retroarch/retroarch.cfg"
	if doesFileExist(cfg) == false then
		if System.listDirectory(base .."/retroarch") == nil then
			System.createDirectory(base .."/retroarch")
		end
		pcall(function()
			local f = System.openFile(cfg, FCREATE)
			System.writeFile(f, "\n", 1)
			System.closeFile(f)
		end)
		boot_log("CONF   ".. cfg .." no existia, creado")
		if doesFileExist(cfg) == false then
			boot_log("CONF   imposible crearlo: soporte de solo lectura?")
			boot_flush()
			return false
		end
	end

	-- Las partidas tienen que caer en un soporte que el core PUEDA leer. Si el
	-- lanzador corre desde el disco interno ATA y el core no lleva ata_bd, ese disco
	-- no existe para el: se usa entonces el mismo destino que el transbordo de ROMs.
	local raiz_saves, dev_saves = RAIZ_DATOS(lee_ata)
	if dev_saves ~= nil then
		boot_log("CONF   lanzador en disco ATA, core compatible: datos en ".. dev_saves)
	elseif raiz_saves ~= System.currentDirectory() then
		boot_log("CONF   lanzador en disco ATA, core sin ata_bd: datos en ".. raiz_saves)
	end

	-- Enceladus ve "mass0:"; RetroArch reinicia el IOP y llama al mismo USB "mass:".
	-- Pero "mc0:" se llama igual en los dos lados, y "mc:" no existe: por eso la
	-- traduccion solo toca "massN:".
	local function para_core(ruta)
		if ruta == nil then return nil end
		if dev_saves ~= nil and ES_RAIZ_ATA(ruta) then
			local pos = string.find(ruta, ":", 1, true)
			if pos ~= nil then return dev_saves .. string.sub(ruta, pos+1) end
		end
		return DEV_PARA_CORE(ruta)
	end

	-- Las tres carpetas que son NUESTRAS, no de RetroArch: van junto al lanzador y no
	-- dentro de su arbol. "Bios/" es la unica copia de referencia de los BIOS, asi que
	-- se le da como "system_directory" en vez de mantener una segunda copia.
	local quiero = {}
	local dirs = {{"savefile_directory",  raiz_saves .."/Saves"},
	              {"savestate_directory", raiz_saves .."/SaveStates"},
	              {"system_directory",    raiz_saves .."/Bios"}}
	for i = 1, #dirs do
		if System.listDirectory(dirs[i][2]) == nil then
			System.createDirectory(dirs[i][2])
		end
		quiero[dirs[i][1]] = para_core(dirs[i][2])
	end

	-- Las CARPETAS PROPIAS de RetroArch, escritas explicitamente. ----------------------
	-- Sin estas claves RetroArch las deduce de su propio directorio, y ahi esta la
	-- trampa: arrancado desde el disco interno ese directorio puede ser un nombre que
	-- existe pero cuya raiz no se lista, y entonces assets, config, system y savefiles
	-- apuntan todos a un sitio vacio. Se recalculan en cada arranque a partir de donde
	-- esta REALMENTE la carpeta, asi que mover el lanzador las corrige solo.
	local base_ra = para_core(base)
	if base_ra ~= nil then
		local carpetas = {
			{"libretro_directory",        "/cores"},
			{"libretro_info_path",        "/info"},
			{"rgui_config_directory",     "/retroarch/config"},
			{"input_remapping_directory", "/retroarch/config/remaps"},
			{"cheat_database_path",       "/retroarch/cheats"},
			{"content_database_path",     "/retroarch/database/rdb"},
			{"assets_directory",          "/retroarch/assets"},
			{"core_assets_directory",     "/retroarch/downloads"},
			{"playlist_directory",        "/retroarch/playlists"},
			{"thumbnails_directory",      "/retroarch/thumbnails"},
			{"cache_directory",           "/retroarch/temp"},
			{"log_dir",                   "/retroarch/logs"},
			{"overlay_directory",         "/retroarch/overlays"},
			-- Estas cinco no son carpetas sino ficheros, y RetroArch las guarda por
			-- separado: cambiar "playlist_directory" no las arrastra. Sin ponerlas
			-- aqui se quedan apuntando a donde estuviera la instalacion anterior.
			{"content_favorites_path",      "/retroarch/playlists/builtin/content_favorites.lpl"},
			{"content_history_path",        "/retroarch/playlists/builtin/content_history.lpl"},
			{"content_image_history_path",  "/retroarch/playlists/builtin/content_image_history.lpl"},
			{"content_music_history_path",  "/retroarch/playlists/builtin/content_music_history.lpl"},
			{"content_video_history_path",  "/retroarch/playlists/builtin/content_video_history.lpl"},
		}
		for i = 1, #carpetas do
			quiero[carpetas[i][1]] = base_ra .. carpetas[i][2]
		end
		boot_log("CONF   carpetas de RetroArch fijadas en ".. base_ra)
	end

	for i = 1, #RETROARCH_FORZADO do
		quiero[RETROARCH_FORZADO[i][1]] = RETROARCH_FORZADO[i][2]
	end
	local modo = "NTSC"
	if pal == true then modo = "PAL" end
	if RETROARCH_FORZAR_VIDEO == true then
		local vid = RETROARCH_VIDEO[modo]
		for i = 1, #vid do quiero[vid[i][1]] = vid[i][2] end
	else
		modo = modo .." (video NO forzado)"
	end

	local txt = nil
	pcall(function()
		local f = System.openFile(cfg, FREAD)
		local tam = System.sizeFile(f)
		System.seekFile(f, 0, SET)
		txt = System.readFile(f, tam)
		System.closeFile(f)
	end)
	if txt == nil then
		boot_log("CONF   ilegible: ".. cfg)
		boot_flush()
		return false
	end

	-- El fichero ya termina en salto de linea. Sin quitarlo, el "txt..salto" de abajo
	-- anadiria una linea vacia en cada arranque.
	if string.sub(txt, -1) == "\n" then txt = string.sub(txt, 1, -2) end

	-- Una sola pasada por lineas: mas barato que un gsub por clave sobre 44 KB.
	local salida, vistas, cambios = {}, {}, 0
	for cruda in string.gmatch(txt .."\n", "([^\n]*)\n") do
		-- La variable de control de un "for" es constante desde Lua 5.4: hay que
		-- copiarla antes de tocarla. Y el fichero puede venir con finales CRLF.
		local linea = cruda
		if string.sub(linea, -1) == "\r" then linea = string.sub(linea, 1, -2) end
		local clave = string.match(linea, "^([%w_]+) = ")
		if clave ~= nil and quiero[clave] ~= nil then
			vistas[clave] = true
			local nueva = clave .. ' = "'.. quiero[clave] ..'"'
			if linea ~= nueva then cambios = cambios + 1 end
			salida[#salida + 1] = nueva
		else
			salida[#salida + 1] = linea
		end
	end
	for clave, valor in pairs(quiero) do
		if vistas[clave] ~= true then
			salida[#salida + 1] = clave .. ' = "'.. valor ..'"'
			cambios = cambios + 1
		end
	end

	if cambios == 0 then
		boot_log("CONF   ".. modo .." ya correcto  ".. tostring(quiero["savefile_directory"]))
		boot_flush()
		return true
	end

	local nuevo = table.concat(salida, "\n") .."\n"
	local ok = false
	pcall(function()
		local f = System.openFile(cfg, FCREATE)
		System.writeFile(f, nuevo, string.len(nuevo))
		System.closeFile(f)
		ok = true
	end)
	boot_log("CONF   ".. modo .."  ".. tostring(cambios) .." clave(s) forzada(s), escrito=".. tostring(ok))
	boot_log("       ".. tostring(quiero["savefile_directory"]) .." , ".. tostring(quiero["savestate_directory"]))
	-- Esto sale justo antes de loadELF, que no vuelve nunca: si no se vuelca ahora,
	-- el diagnostico se pierde con el proceso.
	boot_flush()
	return ok
end

--- La instalacion MAESTRA: la que tiene TODOS los cores. ------------------------------
--- Hay dos instalaciones y confundirlas era el error de fondo:
---
---   la maestra   junto al lanzador, con los 60 cores de la nightly. Dice QUE se
---                puede jugar. No hace falta que un core sepa leerla.
---   la de la llave  "<llave>/Prism/LibretroPS2Files", con EL core del juego
---                nada mas. Dice con que se ejecuta.
---
--- RUTA_LIBRETRO devuelve la segunda en cuanto existe, porque es la unica que un core
--- podra leer tras el SifIopReset. Preguntarle "tienes handy?" da que no, y el juego
--- se rechazaba antes de intentar nada -- que es el "Games or RetroArch not found" de
--- Lynx, GBA, GB, GBC y NES con los sesenta cores presentes en el disco.
function libretro_master_path()
	local propia = System.currentDirectory() .."/LibretroPS2Files"
	if System.listDirectory(propia .."/cores") ~= nil then return propia end
	if RAICES ~= nil then
		for i = 1, #RAICES do
			for k = 1, #LIBRETRO_SUBS do
				local cand = RAICES[i] .. LIBRETRO_SUBS[k]
				if System.listDirectory(cand .."/cores") ~= nil then return cand end
			end
		end
	end
	return RUTA_LIBRETRO()
end

--- Resuelve un core en la instalacion maestra. ---------------------------------------
function core_master_path(nombre_core, ruta_original)
	if nombre_core == nil or nombre_core == " " then return ruta_original end
	local base = libretro_master_path()
	if base ~= nil then
		local cand = base .."/cores/".. nombre_core
		if doesFileExist(cand) then return cand end
	end
	return ruta_original
end

function RUTA_CORE(nombre_core, ruta_original)
	if nombre_core == nil or nombre_core == " " then return ruta_original end
	-- Una sola instalacion, la que RUTA_LIBRETRO haya elegido: la que el core podra
	-- leer despues de reiniciar el IOP.
	local base = RUTA_LIBRETRO()
	if base ~= nil then
		local cand = base .."/cores/".. nombre_core
		if doesFileExist(cand) then return cand end
	end
	return ruta_original
end

--- Extensiones declaradas por un core, leidas de su ".info". ------------------------
--- "picodrive_libretro_ps2.elf" -> "info/picodrive_libretro.info".
function core_extensions(ruta_core)
	local n = nombre_fichero(ruta_core)
	if string.len(n) < 9 or string.sub(n, -8) ~= "_ps2.elf" then return nil end
	local info = string.sub(n, 1, -9) ..".info"

	-- En la MAESTRA primero. La instalacion de la llave lleva un solo ".info", el del
	-- core del juego en curso: buscando ahi, todos los demas cores quedaban sin
	-- extensiones declaradas, CORE_SIRVE los daba por inutiles, y la lista de cores de
	-- cada sistema se quedaba vacia. Los sesenta cores del disco eran invisibles.
	local sitios = {}
	local maestra = libretro_master_path()
	if maestra ~= nil then table.insert(sitios, maestra) end
	if RAICES ~= nil then
		for i = 1, #RAICES do
			for k = 1, #LIBRETRO_SUBS do
				table.insert(sitios, RAICES[i] .. LIBRETRO_SUBS[k])
			end
		end
	end
	local base_ra = RUTA_LIBRETRO()
	if base_ra ~= nil then table.insert(sitios, base_ra) end

	for i = 1, #sitios do
		local p = sitios[i] .."/info/".. info
		if doesFileExist(p) then
			local txt = nil
			pcall(function()
				local f = System.openFile(p, FREAD)
				local tam = System.sizeFile(f)
				System.seekFile(f, 0, SET)
				txt = System.readFile(f, tam)
				System.closeFile(f)
			end)
			if txt ~= nil then
				return string.match(txt, "supported_extensions%s*=%s*\"([^\"]*)\"")
			end
		end
	end
	return nil
end

--- Un core sirve para un sistema si declara alguna de sus extensiones. --------------
function CORE_SIRVE(ruta_core, identidad)
	local exts = SISTEMA_EXTEN[identidad]
	if exts == nil then return true end
	local sup = core_extensions(ruta_core)
	if sup == nil then return false end
	sup = "|".. string.lower(sup) .."|"
	for i = 1, #exts do
		if string.find(sup, "|".. exts[i] .."|", 1, true) ~= nil then return true end
	end
	return false
end
