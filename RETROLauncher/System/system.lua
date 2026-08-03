--[[------------------SPAGHETTICODE-------------------]]--
--[[█▀█ ██▀ ▀█▀ █▀█ █▀█ █    ▄▄ ▄ ▄ ▄▄▄ ▄▄▄ █▄▄ ▄▄  ▄▄]]--
--[[█▀▄ █▄▄  █  █▀▄ █▄█ █▄▄ ▀▄█ █▄█ █ █ █▄▄ █ █ ██▄ █ ]]--
--[[------------------- v1.0/rev2 --------------------]]--

--- Capa de compatibilidad Enceladus 2024 <-> 2025+ ------------------------------------
--- La build de 2024 incluida en RETROLauncher define FREAD/FWRITE/FCREATE, SET/CUR/END,
--- la tabla "Sif" y System.rename. Las versiones recientes las han sustituido por
--- O_RDONLY/O_WRONLY/O_CREAT..., la tabla "IOP" y System.moveFile.
--- Este bloque NO hace nada en la build antigua: solo rellena lo que falte.
if FREAD   == nil and O_RDONLY ~= nil then FREAD   = O_RDONLY end
if FWRITE  == nil and O_WRONLY ~= nil then FWRITE  = O_WRONLY end
if FRDWR   == nil and O_RDWR   ~= nil then FRDWR   = O_RDWR   end   -- usada por guardar()
if FCREATE == nil and O_CREAT  ~= nil then FCREATE = O_RDWR | O_CREAT | O_TRUNC end
if SET == nil then SET = 0 end
if CUR == nil then CUR = 1 end
if END == nil then END = 2 end
if Sif == nil and IOP ~= nil then Sif = IOP end
if System.rename == nil and System.moveFile ~= nil then System.rename = System.moveFile end

--- Deteccion de la build: la tabla global "IOP" solo existe en Enceladus reciente. ----
ENCELADUS_MODERNO = (IOP ~= nil)

--- Intenta cargar módulos "IRX". -------------------------------------------------------
--- Solo se intenta en la build reciente. En el ELF de 2024-10-20 incluido en
--- RETROLauncher, "Sif.loadModule" cuelga la consola en CUALQUIER llamada:
--- probado con las formas de 1 y de 3 argumentos, y hasta con un fichero que ni
--- siquiera es un IRX valido. Se congela antes de la inicializacion de video,
--- sin ningun mensaje en pantalla.
IRX_CARGA_ACTIVA = ENCELADUS_MODERNO

--- Orden impuesto: "ata_bd.irx" importa la libreria "dev9", asi que el driver dev9
--- tiene que estar cargado ANTES. System.listDirectory no garantiza ningun orden.
---   dev9_ns.irx : driver dev9 (hardware del adaptador de red).
---   ata_bd.irx  : expone el disco interno a la pila BDM. Importa "dev9" y "bdm".
--- No hace falta nada mas. "poweroff.irx" solo servia para satisfacer un import de
--- "ps2dev9.irx", abandonado en favor de la version de Neutrino, y "_test_dummy.irx"
--- era el testigo de diagnostico.
IRX_ORDEN = {"dev9_ns.irx", "ata_bd.irx"}

--- No cargar: ya los carga Enceladus, o son restos de diagnostico.
IRX_IGNORAR = {"usbd.irx", "usbhdfsd.irx", "bdm.irx", "bdmfs_fatfs.irx", "usbmass_bd.irx",
	"iomanx.irx", "filexio.irx", "dev9_hidden.irx", "ps2dev9.irx", "poweroff.irx",
	"_test_dummy.irx"}

IRX_LOG = "RETROLauncher - informe IRX / BDM\n\n"
BDM_DEVICES = {}
BDM_ATA = {}   -- unidades aparecidas TRAS cargar ata_bd => disco interno, no USB

--- Volcado del informe. Reescribir el fichero entero en CADA linea costaba varios
--- segundos de arranque (una apertura/escritura/cierre en el USB por linea, con un
--- buffer que crece). Ahora solo se fuerza durante la carga de modulos IRX, que es
--- la unica fase donde un cuelgue puede ocurrir y donde localizarlo importa.
IRX_FLUSH = true

function irx_escribir()
	pcall(function()
		local f = System.openFile(System.currentDirectory() .."/BDM_REPORT.txt", FCREATE)
		System.writeFile(f, IRX_LOG, string.len(IRX_LOG))
		System.closeFile(f)
	end)
end

function irx_log(linea)
	IRX_LOG = IRX_LOG .. linea .. "\n"
	if IRX_FLUSH == true then irx_escribir() end
end

function irx_load()
	if IRX_CARGA_ACTIVA == false then return end
	local actual = System.currentDirectory()
	local hecho = {}
	irx_log("Enceladus reciente detectado (tabla IOP presente).")
	irx_log("currentDirectory = ".. actual)
	irx_log("")
	for i = 1, #IRX_IGNORAR do hecho[IRX_IGNORAR[i]] = "ignorar" end

	-- IMPORTANTE: NO usar Sif.loadModule(ruta). Esa funcion hace que el IOP resuelva
	-- la ruta con su modulo LOADFILE, que usa el viejo "ioman". Pero "mass:" lo aporta
	-- bdmfs_fatfs, que se registra en "iomanX". El IOP no sabe abrir la ruta y la
	-- llamada RPC nunca vuelve: la consola se congela. Comprobado con cualquier
	-- fichero, incluso uno que no es un IRX, y en las builds de 2024 y de 2025.
	-- Solucion: leer el fichero desde el EE y enviar los bytes con loadModuleBuffer.
	local function cargar(nombre)
		local ruta = actual .."/System/IRX/".. nombre
		irx_log("-> ".. nombre)

		local okl, datos, tam = pcall(function()
			local fd = System.openFile(ruta, FREAD)
			local size = System.sizeFile(fd)
			System.seekFile(fd, 0, SET)
			local buf = System.readFile(fd, size)
			System.closeFile(fd)
			return buf, size
		end)

		if okl == false or datos == nil then
			irx_log("   ERROR de lectura: ".. tostring(datos))
			return
		end
		irx_log("   leidos ".. tostring(tam) .." bytes, primer byte = ".. tostring(string.byte(datos, 1)) .." (127 = ELF valido)")

		local okc, ID = pcall(Sif.loadModuleBuffer, datos, tam)
		irx_log("   loadModuleBuffer ok=".. tostring(okc) .."  ID=".. tostring(ID))
	end

	-- Instantanea de las unidades BDM ANTES de cargar los drivers. -------------------
	local antes = {}
	for n = 0, 5 do
		if System.listDirectory("mass".. n ..":") ~= nil then antes["mass".. n ..":"] = true end
	end

	for i = 1, #IRX_ORDEN do
		if doesFileExist(actual .."/System/IRX/".. IRX_ORDEN[i]) then
			cargar(IRX_ORDEN[i])
			hecho[string.lower(IRX_ORDEN[i])] = "hecho"
		end
	end

	local buscar_irx = System.listDirectory(actual.. "/System/IRX")
	if buscar_irx ~= nil and #buscar_irx >= 1 then
		for elementos = 1, #buscar_irx do
			local nombre = buscar_irx[elementos].name
			local clave = string.lower(nombre)
			if string.lower(string.sub(nombre, -4)) == ".irx" then
				if hecho[clave] == "ignorar" then
					irx_log("-- ignorado ".. nombre)
				elseif hecho[clave] == nil then
					cargar(nombre)
				end
			end
		end
	end

	-- Fin de la fase critica: a partir de aqui basta con volcar al final.
	IRX_FLUSH = false
	if System.sleep ~= nil then System.sleep(1) end

	-- Sondeo de las unidades BDM y relleno de BDM_DEVICES. ----------------------------
	local propio = ""
	local pos = string.find(actual, ":", 1, false)
	if pos ~= nil then propio = string.sub(actual, 1, pos) end
	irx_log("")
	irx_log("Unidades BDM (propio = ".. propio ..") :")
	for n = 0, 5 do
		local unidad = "mass".. n ..":"
		local contenido = System.listDirectory(unidad)
		if contenido ~= nil then
			local texto = "  ".. unidad .."  OK  (".. #contenido .." entradas)"
			for i = 1, math.min(#contenido, 30) do
				local marca = "   "
				if contenido[i].directory == true then marca = " d " end
				texto = texto .."\n      ".. marca .. contenido[i].name
			end
			-- No estaba antes de cargar los drivers => la ha montado ata_bd.
			if antes[unidad] ~= true then
				BDM_ATA[unidad] = true
				texto = texto .."\n      (ATA: montada por ata_bd, NO es un USB)"
			end
			irx_log(texto)
			if unidad ~= propio then table.insert(BDM_DEVICES, unidad) end
		else
			irx_log("  ".. unidad .."  nil")
		end
	end
	irx_log("")
	irx_log("Fin. Arranque normal a partir de aqui.")
	irx_escribir()
end
irx_load()

--- Raices de busqueda de juegos ("append" USB + disco interno). -----------------------
--- RAICES[1] es SIEMPRE el soporte de arranque. Se anaden las unidades ATA que
--- contengan un directorio con el mismo nombre que el del launcher.
--- Ejemplo: arranque en "mass:/RETROLauncher", disco interno en "mass1:" con un
--- "mass1:/RETROLauncher" => se buscan los juegos en los dos.
RAICES = { System.currentDirectory() }

if true then
	local actual = System.currentDirectory()
	local nombre_carpeta = actual
	local corte = string.find(string.reverse(actual), "/", 1, true)
	if corte ~= nil then nombre_carpeta = string.sub(actual, -corte+1) end
	for i = 1, #BDM_DEVICES do
		if BDM_ATA[BDM_DEVICES[i]] == true then
			local candidata = BDM_DEVICES[i] .."/".. nombre_carpeta
			if System.listDirectory(candidata) ~= nil then
				table.insert(RAICES, candidata)
			end
		end
	end
	local resumen = "\nRaices de busqueda:\n"
	for i = 1, #RAICES do resumen = resumen .."  ".. i ..". ".. RAICES[i] .."\n" end
	if IRX_CARGA_ACTIVA then irx_log(resumen) end
end

--- Unidad donde vive el directorio "POPS". Puede estar en el soporte de arranque o
--- en el disco interno exFAT. Se prefiere la que contenga los binarios de POPStarter
--- ("POPS_IOX.PAK"), luego cualquiera que exista, y en ultimo recurso el arranque.
POPS_RAIZ = nil

if true then
	local cand = {}
	local pos = string.find(System.currentDirectory(), ":", 1, true)
	if pos ~= nil then table.insert(cand, string.sub(System.currentDirectory(), 1, pos)) end
	for i = 1, #BDM_DEVICES do table.insert(cand, BDM_DEVICES[i]) end

	for i = 1, #cand do
		if POPS_RAIZ == nil and doesFileExist(cand[i] .."/POPS/POPS_IOX.PAK") then
			POPS_RAIZ = cand[i]
		end
	end
	if POPS_RAIZ == nil then
		for i = 1, #cand do
			if POPS_RAIZ == nil and System.listDirectory(cand[i] .."/POPS") ~= nil then
				POPS_RAIZ = cand[i]
			end
		end
	end
	if POPS_RAIZ == nil and #cand >= 1 then POPS_RAIZ = cand[1] end
	if POPS_RAIZ == nil then POPS_RAIZ = "mass:" end
end

--- Primera raiz donde exista la ruta relativa dada (empieza por "/"). ------------------
function RAIZ(rel)
	for i = 1, #RAICES do
		if doesFileExist(RAICES[i] .. rel) then return RAICES[i] end
	end
	return RAICES[1]
end

--- Inventario de lo que el launcher ve en cada raiz. Se anade a BDM_REPORT.txt. ------
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
	irx_log("INVENTARIO: lo que RETROLauncher encuentra en cada raiz")
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

--- Journal de lancement. Ecrit LAUNCH_LOG.txt juste avant chaque loadELF, pour
--- qu'un ecran noir laisse une trace exploitable au prochain demarrage.
--- Mettre LAUNCH_LOG_ON a false pour desactiver.
LAUNCH_LOG_ON = true

--- Reinicio del IOP antes de lanzar un core de RetroArch. ----------------------------
--- 0 = no reiniciar (comportamiento original de RETROLauncher).
--- 1 = reiniciar: el core recibe un IOP limpio y carga sus propios drivers USB.
--- Con 0, el core hereda usbd/usbmass_bd/bdm/bdmfs_fatfs ya residentes (mas
--- dev9_ns y ata_bd), y su propia carga de drivers puede fallar -> pantalla negra.
IOP_REBOOT_CORES = 1

function log_lanzamiento(titulo, campos)
	if LAUNCH_LOG_ON ~= true then return end
	pcall(function()
		local t = "RETROLauncher - ultimo intento de lanzamiento\n"
		t = t .."============================================\n\n"
		t = t .. titulo .."\n\n"
		for i = 1, #campos do
			t = t .. campos[i] .."\n"
		end
		t = t .."\n(si esto es lo ultimo escrito, el fallo esta en el ELF de arriba)\n"
		local f = System.openFile(System.currentDirectory() .."/LAUNCH_LOG.txt", FCREATE)
		System.writeFile(f, t, string.len(t))
		System.closeFile(f)
	end)
end

--- Verifica que un fichero existe y lo describe para el journal. ---------------------
function log_existe(etiqueta, ruta)
	local marca = "NO EXISTE"
	if ruta ~= nil and doesFileExist(ruta) then marca = "ok" end
	return etiqueta .." [".. marca .."] : ".. tostring(ruta)
end

--- Origen de cada juego encontrado: ORIGEN["identidad|nombre"] = raiz. ---------------
ERROR_DETALLE = nil   -- detalle del ultimo fallo de "existe()"

--- El cuadro de error solo dispone de UNA linea entre el titulo y el pie. Aqui se
--- devuelve un texto corto (solo los nombres de fichero, truncado si hace falta) y
--- se vuelca la version completa, con la ruta, en LAUNCH_LOG.txt.
function detalle_falta(etiqueta, base, faltan)
	if faltan == nil or #faltan == 0 then
		log_lanzamiento(etiqueta .."  comprobacion fallida", {"directorio : ".. tostring(base), "(ningun fichero identificado como ausente)"})
		return "Check ".. etiqueta ..": path?"
	end

	local campos = {"directorio esperado : ".. tostring(base), ""}
	for i = 1, #faltan do
		table.insert(campos, "FALTA : ".. faltan[i])
	end
	log_lanzamiento(etiqueta .."  ficheros ausentes", campos)

	local corto = "Missing: ".. faltan[1]
	if #faltan >= 2 then corto = corto .." +".. (#faltan-1) end
	if string.len(corto) > 44 then corto = string.sub(corto, 1, 41) .."..." end
	return corto
end
ORIGEN = {}
ORIGEN_DIR = {}   -- directorio real donde se encontro el juego (PS2)

--- True si la ruta esta en una unidad montada por ata_bd (disco interno exFAT). ------
function ES_RAIZ_ATA(ruta)
	if ruta == nil then return false end
	local pos = string.find(ruta, ":", 1, true)
	if pos == nil then return false end
	return BDM_ATA[string.sub(ruta, 1, pos)] == true
end

--- True si el juego indicado proviene del disco interno. -----------------------------
function ES_ATA(identidad, nombre)
	if nombre == nil then return false end
	return ES_RAIZ_ATA(ORIGEN[tostring(identidad) .."|".. nombre])
end

--- Ruta completa resuelta sobre la primera raiz que la contenga. ----------------------
function RUTA(rel)
	return RAIZ(rel) .. rel
end

--- El inventario usa ES_RAIZ_ATA, asi que se llama DESPUES de definirla. -------------
inventario()

--- Pantalla de carga y comprobación de directorio. -------------------------------------
if true then
	local actual, temp_dir, res_x, res_y = System.currentDirectory(), " ", 640, 448
	if doesFileExist("System/Respaldo/RetroarchPS2/retroarch-salamander.cfg") then
		local salamander = System.openFile("System/Respaldo/RetroarchPS2/retroarch-salamander.cfg", FREAD)
		System.seekFile(salamander, 0, SET)
		local size = System.sizeFile(salamander)
		temp_dir = System.readFile(salamander, size)
		System.closeFile(salamander)
	end
	-- "mass1:" solo cuenta como segundo USB si NO la ha montado ata_bd.
	local usb2 = (System.listDirectory("mass1:") ~= nil and BDM_ATA["mass1:"] ~= true)
	if string.lower("libretro_path = \"".. actual .."/RETROLauncher.elf\"") ~= string.lower(temp_dir) or usb2 then
		require("System/relocation")
	end
	if doesFileExist("System/Respaldo/PAL") == false and doesFileExist("System/Respaldo/NTSC") == false then
		local VMODE = System.openFile("System/Respaldo/NTSC", FCREATE)
		System.closeFile(VMODE)
	elseif doesFileExist("System/Respaldo/PAL") then
		Screen.setMode(PAL, 640, 512, CT24, INTERLACED, FIELD)
		res_x, res_y = 640, 512
	end
	local FONDO_LOAD = Graphics.loadImage("System/Medios/Default/FONDO.png")
	local LOADING_LOAD = Graphics.loadImage("System/Medios/Default/LOADING.png")
	Screen.clear(Color.new(0, 0, 0))
	Graphics.drawScaleImage(FONDO_LOAD, -5, 0, res_x+5, res_y, Color.new(0, 80, 120))
	Graphics.drawScaleImage(LOADING_LOAD, 0, 0, res_x, res_y)
	Screen.flip()
	Graphics.freeImage(FONDO_LOAD)
	Graphics.freeImage(LOADING_LOAD)
	if doesFileExist("System/Medios/Sound/Background/music.adp") == true and doesFileExist("System/Medios/Sound/Background/music0.adp") == true then
		System.removeFile("System/Medios/Sound/Background/music.adp")
	end
end

--- Formato de audio. -------------------------------------------------------------------
Sound.setFormat(16, 48000, 3)

--- Carga y verificación de sonidos. ----------------------------------------------------
function verificar_sonidos(sonido, dir)
	local actual = System.currentDirectory()
	sonido = nil
	if doesFileExist(actual .."/".. dir) then
		sonido = Sound.loadADPCM(dir)
	end
	return sonido
end

-- Carga de sonidos. --------------------------------------------------------------------
S_MOVER = verificar_sonidos(S_MOVER, "System/Medios/Sound/Menu/move.adp");
S_EJECUTAR = verificar_sonidos(S_EJECUTAR, "System/Medios/Sound/Menu/run.adp");
S_CANCELAR = verificar_sonidos(S_CANCELAR, "System/Medios/Sound/Menu/back.adp");
S_NETX = verificar_sonidos(S_NETX, "System/Medios/Sound/Menu/next.adp");
S_MUSICA = verificar_sonidos(S_MUSICA, "System/Medios/Sound/Background/music.adp");

--- Cargar variables y configuraciones. -------------------------------------------------
require("System/language")
lang_select()
require("System/menu")
require("System/funciones")

-- Guarda las listas / últimos movimientos / límite de captura. -------------------------
PRE_CARGADAS = {}
LAST_MOVE = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
JOYSTICK_LIMITE = 0

--- Carga y verificación de imágenes. ---------------------------------------------------
function verif_img(dir)
	local actual = System.currentDirectory()
	if doesFileExist(actual .."/".. dir) == false then
		dir = "System/Medios/Default/ERROR.png"
	end
	return dir
end

-- Precargar logos. ---------------------------------------------------------------------
LOGOS = {
	DEFAULT = Graphics.loadImage(verif_img("System/Medios/Logos/Default.png"));
	DEFAULT_DEMO = Graphics.loadImage(verif_img("System/Medios/Logos/Default_DEMO.png"));
	MEGADRIVE = Graphics.loadImage(verif_img("System/Medios/Logos/Megadrive.png"));
	MASTERSYSTEM = Graphics.loadImage(verif_img("System/Medios/Logos/MasterSystem.png"));
	GAMEGEAR = Graphics.loadImage(verif_img("System/Medios/Logos/GameGear.png"));
	FAMICOM = Graphics.loadImage(verif_img("System/Medios/Logos/Famicom.png"));
	GAMEBOY = Graphics.loadImage(verif_img("System/Medios/Logos/GameBoy.png"));
	GAMEBOYCOLOR = Graphics.loadImage(verif_img("System/Medios/Logos/GameBoyColor.png"));
	GAMEBOYADVANCE = Graphics.loadImage(verif_img("System/Medios/Logos/GameBoyAdvance.png"));
	ATARI2600 = Graphics.loadImage(verif_img("System/Medios/Logos/Atari2600.png"));
	ATARILYNX = Graphics.loadImage(verif_img("System/Medios/Logos/AtariLynx.png"));
	SEGASG1000 = Graphics.loadImage(verif_img("System/Medios/Logos/SegaSG1000.png"));
	NEOGEOPOCKET = Graphics.loadImage(verif_img("System/Medios/Logos/NeoGeoPocket.png"));
	SUPERFAMICOM = Graphics.loadImage(verif_img("System/Medios/Logos/SuperFamicom.png"));
	APPS = Graphics.loadImage(verif_img("System/Medios/Logos/Apps.png"));
	PLAYSTATION = Graphics.loadImage(verif_img("System/Medios/Logos/PlayStation.png"));
	PLAYSTATION2 = Graphics.loadImage(verif_img("System/Medios/Logos/PlayStation2.png"));
};

-- Precargar imágenes de los pads. ------------------------------------------------------
PAD_IMG = {
	CIRCLE = Graphics.loadImage(verif_img("System/Medios/Pads/circle.png"));
	CROSS = Graphics.loadImage(verif_img("System/Medios/Pads/cross.png"));
	L1 = Graphics.loadImage(verif_img("System/Medios/Pads/L1.png"));
	R1 = Graphics.loadImage(verif_img("System/Medios/Pads/R1.png"));
	L2 = Graphics.loadImage(verif_img("System/Medios/Pads/L2.png"));
	R2 = Graphics.loadImage(verif_img("System/Medios/Pads/R2.png"));
	R3 = Graphics.loadImage(verif_img("System/Medios/Pads/R3.png"));
	SELECT_S = Graphics.loadImage(verif_img("System/Medios/Pads/select.png"));
	SQUARE = Graphics.loadImage(verif_img("System/Medios/Pads/square.png"));
	TRIANGLE = Graphics.loadImage(verif_img("System/Medios/Pads/triangle.png"));
	START = Graphics.loadImage(verif_img("System/Medios/Pads/start.png"));
};

-- Precargar imágenes de los sprites. ---------------------------------------------------
SPRITES = {
	MEGADRIVE = nil;
	MASTERSYSTEM = nil;
	GAMEGEAR = nil;
	FAMICOM = nil;
	GAMEBOY = nil;
	GAMEBOYCOLOR = nil;
	GAMEBOYADVANCE = nil;
	ATARI2600 = nil;
	ATARILYNX = nil;
	SEGASG1000 = nil;
	NEOGEOPOCKET = nil;
	SUPERFAMICOM = nil;
	APPS = nil;
	PLAYSTATION = nil;
	PLAYSTATION2 = nil;
	SPRITE_SYS = {"MEGADRIVE"; "MASTERSYSTEM"; "GAMEGEAR"; "FAMICOM"; "GAMEBOY"; "GAMEBOYCOLOR";
				"GAMEBOYADVANCE"; "ATARI2600"; "ATARILYNX"; "SEGASG1000"; "NEOGEOPOCKET";
				"SUPERFAMICOM"; "APPS"; "PLAYSTATION"; "PLAYSTATION2"};
	HEIGHT_Y = {45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45};
	WIDTH_X = {40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40};
	N_COLUMNS = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4};
	N_ROWS = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4};
	X = 0;
	Y = 0;
	ANI_FRAME = 0;
	FLIP = {0, 0};
	FONDO_ANI = false;
	FONDO_HEIGHT_Y = 640;
	FONDO_WIDTH_X = 448;
	FONDO_N_COLUMNS = 4;
	FONDO_N_ROWS = 4;
	FOND_X = 0;
	FOND_Y = 0;
	FONDO_ANI_FRAME = 0;
	LAYER = false;
	LAYER_TYPE = 0;
	LAYER_SPEED = 1;
	TRAN_TYPE = 0;
	TRAN_LEVEL = 1;
	TRAN_SPEED = 1;
	TRAN = {128, 128, 128, 128};
	TRAN_ALT = {false, false, false, false};
	SPIN_TYPE = 0;
	SPIN = 0;
	SPIN_SPEED = 1;
	LAYER_MULTI = 1;
	BACK_X = 0;
	BACK_Y = 0;
	LAYER_X_1 = 0;
	LAYER_X_2 = 0;
	LAYER_X_3 = 0;
	LAYER_X_4 = 0;
	LAYER_Y_1 = 0;
	LAYER_Y_2 = 0;
	LAYER_Y_3 = 0;
	LAYER_Y_4 = 0;
	ALTERNATE = false;
	ALTERNATE_R = false;
	ALTERNATE_T = false;
	ACTIVATE_ALTER_T = false;
	ANG = {0.00, 3.14};
	ZOOM = {0, false};
	MOVE = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	AUTO_MOVE_SPRITE = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	MOVE_X = 0;
	MOVE_Y = 0;
	MOVE_ALT_X = false;
	MOVE_ALT_Y = false;
	SPIN_SPRITE_ON = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	SPIN_SPRITE = 0.00;
	SPIN_SPRITE_ALT = false;
	TRAN_SPRITE_ON = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	TRAN_SPRITE = 128;
	TRAN_ALT_SPRITE = false;
	ANG_SPRITE = 0.00;
	ZOOM_SPRITE = {0, false};
	SPEED_SPRITE = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
};
TEML(true)

-- Define colores básicos. --------------------------------------------------------------
COLOR = {
	BLANCO = Color.new(128, 128, 128);
	BLANCO_LISTA = Color.new(128, 128, 128);
	NEGRO = Color.new(0, 0, 0);
	GRIS = Color.new(70, 70, 70);
	NEGRO_T = Color.new(0, 0, 0, 85);
	BLANCO_T = Color.new(128, 128, 128, 20);
	CC_BACK = {0, 0, 0, 85};
};

-- Define opciones y configuraciones. ---------------------------------------------------
OPCIONES = {
	RGB_ON = 1;
	FONDO_RGB_ON = 1;
	FONDO_RGB_FIJO_ON = 0;
	R = 0;
	G = 80;
	B = 120;
	CAMBIO_FUENTE_ON = 1;
	FUENTES_ENCONTRADAS = {};
	CAMBIO_FONDO_ON = 1;
	FONDO_ENCONTRADOS = {};
	GUI_LIMPIA_ON = 0;
	APPS_MENU_FULL_PATH = 0;
	LIMITADOR_RAM_ON = 0;
	SALIDA_RETROLANCHER_ON = 0;
	SALIDA_RETROLANCHER = "PS2 SYSTEM MENU";
	SALIDA_DIR_ACTUALES = {};
	SALIDA_DIR_ANTERIORES = {};
	SOUND_ON = 0;
	SCREENSHOT_BACK_ON = 0;
	SCREENSHOT_BACK_TR = 128;
	SOUND_VOLUME = 65;
	VIDEO_MODE = 0;
	VIBRATION_ON = 0;
	VIBRATION = false;
	VIBRATION_MODE = nil;
	DIR_EXTRAS_ON = 1;
	PREGUNTAR_PS2 = false;
	LIBERAR_LISTAS = 0;
	FONT_PIXEL_X = 16;
	FONT_PIXEL_Y = 16;
	FONT_SHADOW = 5;
	SCROLL_MIN = 24;
	OPL_ELF = "mass:/RETROLauncher/System/RetroarchPS2/Sony PlayStation 2/OPL/OPNPS2LD.ELF";
	OPL_DIR = "DVD";
	SPRITE_ON = 0;
	SEE_INDEX = 0;
	COLOR_LISTA_B = 74;
	RUN_DEFAULT = 0
};

-- Define el estado de los emuladores (Activado / Desactivado). -------------------------
SISTEMAS = {
	MEGADRIVE_ON = 1;
	MASTERSYSTEM_ON = 1;
	GAMEGEAR_ON = 1;
	FAMICOM_ON = 1;
	GAMEBOY_ON = 1;
	GAMEBOYCOLOR_ON = 1;
	GAMEBOYADVANCE_ON = 1;
	ATARI2600_ON = 1;
	ATARILYNX_ON = 1;
	SEGASG1000_ON = 1;
	NEOGEOPOCKET_ON = 1;
	SUPERFAMICOM_ON = 1;
	APPS_ON = 1;
	PLAYSTATION_ON = 1;
	PLAYSTATION2_ON = 1;
};

-- Define las variables usadas para la ejecución del programa. --------------------------
CONTROL = {
	ANCHO = 640;
	ALTO = 480;
	ALTO_F = 448;
	Y_FIX_PAL = 0;
	SELECTOR = 1;
	ESTILO = 1;
	JOYSTICK_ON = false;
	TIME = Timer.new();
	TIEMPO = 0;
	ESPERA_CARGA_SCR = false;
	PAUSA_SCR_TEX = 0;
	EXTENSION = 5;
	FPS = Screen.getFPS(1);
	LISTA_ANCHO = 30; LISTA_X = 310; LISTA_ALTO = 90; LISTA_Y = 290;
	IMG_ANCHO = 358; IMG_X = 250; IMG_ALTO = 92; IMG_Y = 193;
	IMG_ANCHO_2 = 358; IMG_X_2 = 250; IMG_ALTO_2 = 92; IMG_Y_2 = 193;
	FLOW_ANCHO = 15; FLOW_X = 160; FLOW_ALTO = 358; FLOW_Y = 103;
	FLOW_ANCHO_2 = 358; FLOW_X_2 = 250; FLOW_ALTO_2 = 92; FLOW_Y_2 = 250;
	LOGO_ANCHO = 194; LOGO_X = 252; LOGO_ALTO = 5; LOGO_Y = 76;
	X_BUTTON_X = 0; Y_BUTTON_X = 0;
	X_BUTTON_T = 0; Y_BUTTON_T = 0;
	X_BUTTON_S = 0; Y_BUTTON_S = 0;
	X_BUTTON_L1 = 0; Y_BUTTON_L1 = 0;
	X_BUTTON_R1 = 0; Y_BUTTON_R1 = 0;
	X_BUTTON_R3 = 0; Y_BUTTON_R3 = 0;
	X_BUTTON_STA = 0; Y_BUTTON_STA = 0;
	X_BUTTON_SEL = 0; Y_BUTTON_SEL = 0;
	CUSTOM_ANIM = 1;
	ANIM_VELOCIDAD = 29;
	CUSTOM_LIST = true;
	CUSTOM_ART1 = true;
	CUSTOM_ART2 = false;
	CUSTOM_FLOW = false;
	CUSTOM_LOGO = true;
	CUSTOM_BUTTON_X = true;
	CUSTOM_BUTTON_T = true;
	CUSTOM_BUTTON_S = true;
	CUSTOM_BUTTON_L1 = true;
	CUSTOM_BUTTON_R1 = true;
	CUSTOM_BUTTON_R3 = true;
	CUSTOM_BUTTON_STA = true;
	CUSTOM_BUTTON_SEL = true;
	CUSTOM_BACK = true;
	SPRITE_ANCHO = 30; SPRITE_X = 80; SPRITE_ALTO = 30; SPRITE_Y = 100;
	CUSTOM_SPRITE = false;
	Font.ftInit();
	fontARCA = Font.ftLoad("System/Medios/Font/PublicPixel.ttf");
	fontABC = Font.ftLoad("System/Medios/Font/PublicPixel.ttf");
	ACT_FONTABC = false;
};

-- Define las variables usadas para la ejecución de las listas. -------------------------
LISTAS = {
	FONDO = Graphics.loadImage(verif_img("System/Medios/Default/FONDO.png"));
	LOADING = Graphics.loadImage(verif_img("System/Medios/Default/LOADING.png"));
	COVER_DEFAULT = Graphics.loadImage(verif_img("System/Medios/Default/".. img_lang("COVER_DEFAULT", true) ..".png"));
	SCREENSHOT_DEFAULT = Graphics.loadImage(verif_img("System/Medios/Default/".. img_lang("SCREENSHOT_DEFAULT", false) ..".png"));
	LOGO = LOGOS.DEFAULT;
	IDENTIDAD = 1;
	INDICE = 1;
	INDICE2 = 1;
	INDICE3 = 1;
	ROMS = {};
	DIR_FULL_APP = {};
	MOSTRAR = 0;
	ART_LIMITE = 8;
	SCREENSHOT_ON = false;
	SCREENSHOT_FULL = false;
	COVER_ART = nil;
	COVER_DIR = " "; COVER_DIR_ALT = " ";
	COVER_ART2 = nil;
	COVER_DIR2 = " "; COVER_DIR2_ALT = " ";
	COVER_ART3 = nil;
	COVER_DIR3 = " "; COVER_DIR3_ALT = " ";
	SCREENSHOT = nil;
	SCREENSHOT_DIR = " "; SCREENSHOT_DIR_ALT = " ";
	SCROLL_TEX = 1;
	EXISTE_COV = false;
	EXISTE_SCR = false;
	EXISTE_COV2 = false;
	EXISTE_COV3 = false;
	COV_X = 250; COV_Y = 193; COV_FIX = 0; COV_FIX_Y = 0;
	SCR_X = 250; SCR_Y = 193; SCR_FIX = 0; SCR_FIX_Y = 0;
	SCR_ART2_X = 250; SCR_ART2_Y = 193; SCR_FIX_ART2 = 0; SCR_FIX_Y_ART2 = 0;
	COV_1_X = 160; COV_1_Y = 103; COV_1_FIX = 0; COV_1_FIX_Y = 0;
	COV_2_X = 160; COV_2_Y = 103; COV_2_FIX = 0; COV_2_FIX_Y = 0;
	EX_FIX_S = 0; EX_FIX_S_Y = 0;
	EX_FIX_C = 0; EX_FIX_C_Y = 0;
	ELEMENTOS_LIST = 11;
	ART_ZOOM = 2;
};

-- Define los colores usados para cada sistema. -----------------------------------------
CAMBIOS_EMUS = {
	COLOR_EMU = Color.new(0, 0, 0);
	COLOR_EMU_BACK = Color.new(0, 80, 120);
	COLOR_ACTUAL = 0;
	COLOR_MAX = 0;
	COLOR_MIN = 0;
	RGB_COLOR = 1;
	CAM_COLOR_ACTUAL = false;
	R = 0;
	G = 80;
	B = 120;
	TRAS = 74;
};

--- Cargar variables y configuraciones. -------------------------------------------------
cargar_config()

--- Ejecutar RETROLauncher. -------------------------------------------------------------
while true do
	dibujar()
	refrescar(false)
	CONTROL.FPS = Screen.getFPS(1)
end
--[[------------------SPAGHETTICODE-------------------]]--