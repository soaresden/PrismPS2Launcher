-- Prism PS2 Launcher - core/log.lua
-- The session journal (log/Debug_*.log), launch log, inventories.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- =====================================================================================
--- UN journal: "Prism.log", junto al ELF. ------------------------------------
--- Habia cuatro -- BOOT_LOG, LAUNCH_LOG, MEDIA_LOG, PREBOOT_LOG -- y no se leia
--- ninguno entero: lo que hace falta es el ORDEN de los sucesos, y repartidos en
--- cuatro ficheros el orden se pierde. Ahora todo va a uno, con una categoria por
--- linea, que es lo que separaba los ficheros y cabe en seis caracteres:
---
---   PRE     el pre-boot (System/index.lua), antes de que exista nada de esto
---   BOOT    soporte de arranque, IRX, unidades, raices
---   CARGA   los pasos del arranque, los mismos que se ven en pantalla
---   CONF    lo que se le impone a "retroarch.cfg"
---   SAVES   el puente de partidas disco <-> llave
---   LANZA   la secuencia de lanzamiento de un juego, y el volcado previo al loadELF
---   ART     la ultima imagen abierta (ver ART_LOG_ON)
---
--- Escribe desde la primera linea de codigo. Durante la fase critica cada linea
--- reescribe el fichero entero (BOOT_FLUSH): si la consola se congela, la ultima
--- linea escrita nombra al culpable. Si el fichero no llega ni a existir, el cuelgue
--- es ANTERIOR a Lua -- conflicto de drivers en el arranque de Enceladus -- y ningun
--- script puede verlo.
--- El destino se resuelve una vez y SIEMPRE en el soporte que lanzo el programa:
--- "log/" junto al ELF, o junto al ELF a secas si "log/" no se deja crear. Nunca en
--- una Memory Card.
BOOT_LOG_ON = true
BOOT_FLUSH = true
BOOT_LOG_DESTINO = nil

--- ONE FILE PER SESSION, in log/. -----------------------------------------------------
--- "log/Debug_YYYY-MM-DD_HHMMSS.log", stamped with the moment the program started, so
--- two boots can never share a file and a failed launch that drops back to uLaunchELF
--- leaves its trace intact for the next attempt to sit beside, not on top of.
---
--- This also retires the history prefix the single-file journal needed: every line
--- used to rewrite the WHOLE file, previous sessions included, which on exFAT came to
--- nearly two megabytes of writes before the menu appeared. A session file starts
--- empty and only ever carries its own lines.
---
--- The folder is trimmed to LOG_KEEP files, oldest first by name - the name IS the
--- date - so the drive does not fill up with a thousand boots.
LOG_DIR = "log"
LOG_KEEP = 20
BOOT_LOG_TXT = ""
LOG_FILE = nil

if true then
	local sello, nombre = "", "Debug_unknown.log"
	pcall(function()
		sello = os.date("%Y-%m-%d %H:%M:%S")
		nombre = "Debug_".. os.date("%Y-%m-%d_%H%M%S") ..".log"
	end)
	LOG_FILE = nombre
	BOOT_LOG_TXT = "Prism - session ".. sello .."\n"
		.."One line per event, category first. BOOT_LOG_ON = false in\n"
		.."System/system.lua turns this off.\n"
		.."============================================================\n"

	-- The pre-boot (System/index.lua, run from the memory card before any of this
	-- exists) still writes its PRE lines to Prism.log beside the ELF. They are
	-- the only trace of the IRX loading, so they are pulled into this session's file
	-- and the old file goes - consumed, not lost.
	pcall(function()
		local previo = System.currentDirectory() .."/Prism.log"
		if doesFileExist(previo) == false then return end
		local f = System.openFile(previo, FREAD)
		local tam = System.sizeFile(f)
		System.seekFile(f, 0, SET)
		local t = System.readFile(f, tam)
		System.closeFile(f)
		if t ~= nil and string.len(t) > 0 then
			if string.len(t) > 12000 then t = "[...]\n".. string.sub(t, -12000) end
			BOOT_LOG_TXT = BOOT_LOG_TXT .."--- pre-boot (from Prism.log) ---\n"
				.. t .."--- end of pre-boot ---\n"
		end
	end)
end

--- La ultima imagen abierta. No se acumula: se sustituye. -----------------------------
--- Antes esto reescribia un fichero en CADA caratula cargada, o sea en cada movimiento
--- por la lista. Ahora es una linea que vive al final del journal y se pisa a si misma.
ART_ULTIMA = nil

--- Old sessions beyond LOG_KEEP, dropped oldest first. --------------------------------
local function log_rotate(dir)
	pcall(function()
		local lista = System.listDirectory(dir)
		if lista == nil then return end
		local nombres = {}
		for i = 1, #lista do
			local n = lista[i].name
			if lista[i].directory == false and string.sub(n, 1, 6) == "Debug_"
			   and string.sub(n, -4) == ".log" then
				nombres[#nombres + 1] = n
			end
		end
		table.sort(nombres)
		for i = 1, #nombres - LOG_KEEP do
			pcall(System.removeFile, dir .."/".. nombres[i])
		end
	end)
end

function boot_flush()
	if BOOT_LOG_ON ~= true then return end
	pcall(function()
		local texto = BOOT_LOG_TXT
		if ART_ULTIMA ~= nil then texto = texto .."ART    ".. ART_ULTIMA .."\n" end
		if BOOT_LOG_DESTINO == nil then
			-- ONLY on the medium that launched the program: log/ next to the ELF, or
			-- beside the ELF if log/ cannot be created. Never a memory card: a journal
			-- that lands on mc0 is one nobody finds, and it fills the card. If nothing
			-- here takes writes, the text stays in memory and the next flush retries.
			local actual = System.currentDirectory()
			local dirs = {actual .."/".. LOG_DIR, actual}
			for i = 1, #dirs do
				if System.listDirectory(dirs[i]) == nil then
					pcall(System.createDirectory, dirs[i])
				end
				local cand = dirs[i] .."/".. LOG_FILE
				local ok = pcall(function()
					local f = System.openFile(cand, FCREATE)
					System.writeFile(f, texto, string.len(texto))
					System.closeFile(f)
				end)
				if ok == true and doesFileExist(cand) then
					BOOT_LOG_DESTINO = cand
					log_rotate(dirs[i])
					if i > 1 then
						BOOT_LOG_TXT = BOOT_LOG_TXT .."LOG    ".. actual .."/".. LOG_DIR
							.." refused writes; journal kept beside the ELF instead\n"
					end
					break
				end
			end
			if BOOT_LOG_DESTINO == nil then return end
			-- The journals of earlier designs, now just clutter.
			local viejos = {"Prism.log", "BOOT_LOG.txt", "LAUNCH_LOG.txt",
			                "MEDIA_LOG.txt", "BDM_REPORT.txt", "PREBOOT_LOG.txt"}
			for i = 1, #viejos do
				local v = actual .."/".. viejos[i]
				if doesFileExist(v) then pcall(System.removeFile, v) end
			end
			return
		end
		local f = System.openFile(BOOT_LOG_DESTINO, FCREATE)
		System.writeFile(f, texto, string.len(texto))
		System.closeFile(f)
	end)
end

function boot_log(linea)
	if BOOT_LOG_ON ~= true then return end
	BOOT_LOG_TXT = BOOT_LOG_TXT .. linea .. "\n"
	if BOOT_FLUSH == true then boot_flush() end
end

--- log_event(category, text): the one call new code should use. -----------------------
--- Same file, same line format, a timestamp in front so a freeze can be timed against
--- the last thing that happened. Categories seen so far: PRE BOOT CARGA CONF SAVES
--- LANZA ART LLAVE SONIDO, and from here on MENU (a screen opened or closed), SET (a
--- setting changed, with old and new value), VMC (a card chosen or created), FILE
--- (something copied, moved, deleted).
function log_event(categoria, texto)
	local hora = ""
	pcall(function() hora = os.date("%H:%M:%S ") end)
	boot_log(hora .. string.format("%-6s ", tostring(categoria)) .. tostring(texto))
end

--- Alias historicos: parte del codigo llama todavia irx_log / irx_escribir. -----------
irx_log = boot_log
irx_escribir = boot_flush

--- Inventario de lo que el launcher ve en cada raiz. Se anade al journal. ------
--- Poner INVENTARIO_ON a false cuando ya no haga falta.
INVENTARIO_ON = false

function inventario()
	if INVENTARIO_ON ~= true then return end
	local sistemas = {"Sega Megadrive", "Sega Master System", "Sega Game Gear", "Nintendo Famicom",
		"Nintendo Game Boy", "Nintendo Game Boy Color", "Nintendo Game Boy Advance", "Atari 2600",
		"Atari Lynx", "Sega SG-1000", "Neo Geo Pocket", "Nintendo Super Famicom"}

	local function listar(etiqueta, ruta)
		local c = System.listDirectory(ruta)
		if c == nil then
			irx_log("    ".. etiqueta .."  ->  NO EXISTE   (".. ruta ..")")
			return
		end
		local ficheros = 0
		for i = 1, #c do
			if c[i].directory == false then ficheros = ficheros + 1 end
		end
		local t = "    ".. etiqueta .."  ->  ".. ficheros .." fichero(s)   (".. ruta ..")"
		local n = 0
		for i = 1, #c do
			if c[i].directory == false and string.sub(c[i].name, 1, 1) ~= "." then
				n = n + 1
				if n <= 25 then t = t .."\n         ".. c[i].name end
			end
		end
		if n > 25 then t = t .."\n         ... y ".. (n-25) .." mas" end
		irx_log(t)
	end

	irx_log("")
	irx_log("=====================================================================")
	irx_log("INVENTARIO: lo que Prism encuentra en cada raiz")
	irx_log("=====================================================================")

	for i = 1, #RAICES do
		local r = RAICES[i]
		local etiqueta_raiz = "USB / soporte de arranque"
		if ES_RAIZ_ATA(r) then etiqueta_raiz = "DISCO INTERNO exFAT (ATA)" end
		irx_log("")
		irx_log("RAIZ ".. i ..": ".. r .."   [".. etiqueta_raiz .."]")
		for s = 1, #sistemas do
			listar(sistemas[s], r .."/Roms/Roms ".. sistemas[s])
		end
		listar("PS1 (CUEs + ember)", r .."/Roms/CUEs PlayStation 1")
		listar("PS2 (ISOs)",         r .."/Roms/ISOs PlayStation 2")
		listar("APPS",               r .."/Roms/APPS")
	end

	-- Directorios a nivel de unidad (fuera de la carpeta del launcher). --------------
	local unidades = {}
	local pos = string.find(System.currentDirectory(), ":", 1, true)
	if pos ~= nil then table.insert(unidades, string.sub(System.currentDirectory(), 1, pos)) end
	for i = 1, #BDM_DEVICES do table.insert(unidades, BDM_DEVICES[i]) end

	for i = 1, #unidades do
		local u = unidades[i]
		local etiqueta_u = "USB"
		if BDM_ATA[u] == true then etiqueta_u = "DISCO INTERNO exFAT (ATA)" end
		irx_log("")
		irx_log("UNIDAD ".. u .."   [".. etiqueta_u .."]")
		listar("DVD",  u .."/DVD")
		listar("CD",   u .."/CD")
		listar("POPS", u .."/POPS")
		listar("APPS", u .."/APPS")
	end
	irx_log("")
	irx_log("Fin del inventario.")
	irx_escribir()
end

--- Journal de lancement. Ecrit dans Prism.log juste avant chaque loadELF, pour
--- qu'un ecran noir laisse une trace exploitable au prochain demarrage.
--- Mettre LAUNCH_LOG_ON a false pour desactiver.
LAUNCH_LOG_ON = true

--- Reinicio del IOP antes de lanzar un core de RetroArch. ----------------------------
--- 0 = no reiniciar.   1 = reiniciar antes de entregar el ELF.
---
--- Estuvo en 0 mucho tiempo, con este razonamiento: RetroArch reinicia el IOP el
--- mismo nada mas arrancar ("reset_IOP()" en frontend_ps2_init), asi que hacerlo dos
--- veces no aportaba nada. Era cierto... mientras el IOP no llevase nada especial.
---
--- Ahora si lleva algo: el pre-boot ("System/index.lua") carga dev9_ns y ata_bd para
--- que el lanzador vea el disco interno. Al entregar el core sin reiniciar, RetroArch
--- se encuentra un ata_bd ya residente y un bus ATA ya tomado, y vuelve a cargar el
--- suyo encima. Sintoma: pantalla negra, y ni una linea en el log de RetroArch -
--- muere antes de poder escribir.
---
--- La prueba que lo senala: el MISMO core, con el MISMO juego en el disco interno,
--- arranca perfectamente cuando se lanza a mano desde uLaunchELF, que si reinicia el
--- IOP. Solo falla por la via del lanzador.
---
--- PROBADO EN CONSOLA, Y ES QUE NO: con 1 la pantalla se queda negra y la consola
--- vuelve al menu del sistema. Ese retorno al menu es la firma de un ELF que muere o
--- que no llega a cargarse, no de un cuelgue. Enceladus NO lee el ELF antes de
--- reiniciar el IOP: se queda sin drivers para leerlo. Vuelve a 0.
--- (Con 0 el sintoma es otro: pantalla negra que se queda, sin volver al menu. Son
--- dos fallos distintos, y solo el segundo sigue abierto.)
IOP_REBOOT_CORES = 0

--- Tamano maximo del historial. Al pasarlo se recorta por el PRINCIPIO, nunca por el
--- final: lo interesante es siempre lo ultimo. A ~700 bytes por entrada esto guarda
--- Una entrada de lanzamiento, en el journal unico. ----------------------------------
--- Tenia fichero propio, LAUNCH_LOG.txt, con su propio historial y su propia marca de
--- sesion. Las dos cosas las hace ya el nucleo del journal, asi que aqui solo queda
--- formatear el bloque y mandarlo por boot_log con la categoria delante.
LAUNCH_LOG_ON = true

function log_lanzamiento(titulo, campos)
	if LAUNCH_LOG_ON ~= true then return end
	boot_log("")
	boot_log("LANZA  ------------------------------------------------------")
	boot_log("LANZA  ".. tostring(titulo))
	for i = 1, #campos do
		boot_log("LANZA    ".. tostring(campos[i]))
	end
	if MEDIA_DIAG ~= nil and #MEDIA_DIAG >= 1 then
		boot_log("LANZA    caratula, rutas probadas en orden:")
		for i = 1, #MEDIA_DIAG do boot_log("LANZA      ".. tostring(MEDIA_DIAG[i])) end
	end
	-- Esto sale justo antes de un loadELF, que no vuelve nunca. Si es la ultima
	-- entrada del fichero, el fallo esta en el ELF que nombra.
	boot_flush()
end

--- Verifica que un fichero existe y lo describe para el journal. ---------------------
function log_existe(etiqueta, ruta)
	local marca = "NO EXISTE"
	if ruta ~= nil and doesFileExist(ruta) then marca = "ok" end
	return etiqueta .." [".. marca .."] : ".. tostring(ruta)
end

--- Que hay en la llave, al arrancar. --------------------------------------------------
--- Cuando un core sale a pantalla negra la primera pregunta es siempre "que ha llegado
--- de verdad a la llave", y hasta ahora habia que apagar, sacarla y mirarla en el PC.
--- Aqui queda escrito. Son cuatro listados de carpetas pequenas: la raiz del lanzador
--- en la llave, los cores que hay, la ROM en cache y las partidas.
function usb_inventory()
	local destinos = ROM_DESTINOS()
	for d = 1, #destinos do
		local dev = destinos[d]
		if string.lower(string.sub(dev, 1, 4)) == "mass" then
			local raiz = dev .."/".. CARPETA_LANZADOR
			local top = System.listDirectory(raiz)
			if top ~= nil then
				boot_log("")
				boot_log("LLAVE  ".. raiz)
				for i = 1, #top do
					local n = top[i].name
					if n ~= "." and n ~= ".." then
						if top[i].directory == true then boot_log("       d ".. n)
						else boot_log("         ".. n) end
					end
				end
				-- Los cores presentes: es lo que decide si un juego arrancara sin
				-- copiar nada, y lo primero que falta cuando algo va mal.
				local cores = System.listDirectory(raiz .."/LibretroPS2Files/cores")
				if cores == nil then
					boot_log("       LibretroPS2Files/cores : AUSENTE")
				else
					local n = 0
					for i = 1, #cores do
						if cores[i].directory == false then
							n = n + 1
							boot_log("       core : ".. cores[i].name)
						end
					end
					if n == 0 then boot_log("       LibretroPS2Files/cores : vacio") end
				end
				local cfg = raiz .."/LibretroPS2Files/retroarch/retroarch.cfg"
				boot_log("       retroarch.cfg : ".. tostring(doesFileExist(cfg)))
				-- Las carpetas de trabajo de RetroArch. No las crea el: si faltan,
				-- abre ficheros dentro de nada. "temp" es "cache_directory", donde se
				-- descomprime un .zip -- sin ella una ROM comprimida no arranca.
				local criticas = {"temp", "logs", "system", "savefiles", "savestates"}
				local ausentes = ""
				for i = 1, #criticas do
					if System.listDirectory(raiz .."/LibretroPS2Files/retroarch/".. criticas[i]) == nil then
						ausentes = ausentes .." ".. criticas[i]
					end
				end
				if ausentes == "" then
					boot_log("       retroarch/ carpetas de trabajo : todas presentes")
				else
					boot_log("       retroarch/ AUSENTES :".. ausentes)
				end
				-- La ROM en cache y las partidas que esperan la vuelta.
				local roms = System.listDirectory(raiz .."/Roms")
				if roms ~= nil then
					for i = 1, #roms do
						local c = roms[i].name
						if roms[i].directory == true and c ~= "." and c ~= ".." then
							local dentro = System.listDirectory(raiz .."/Roms/".. c)
							if dentro ~= nil then
								for j = 1, #dentro do
									if dentro[j].directory == false then
										boot_log("       rom  : ".. c .."/".. dentro[j].name)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	boot_flush()
end
