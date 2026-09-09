--[[------------------SPAGHETTICODE-------------------]]--
--[[█▀█ ██▀ ▀█▀ █▀█ █▀█ █    ▄▄ ▄ ▄ ▄▄▄ ▄▄▄ █▄▄ ▄▄  ▄▄]]--
--[[█▀▄ █▄▄  █  █▀▄ █▄█ █▄▄ ▀▄█ █▄█ █ █ █▄▄ █ █ ██▄ █ ]]--
--[[------------------- v1.0/rev2 --------------------]]--

--- Capa de compatibilidad Enceladus 2024 <-> 2025+ ------------------------------------
--- La build de 2024 incluida en Prism define FREAD/FWRITE/FCREATE, SET/CUR/END,
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

require("System/core/devices")

--- Deteccion de la build: la tabla global "IOP" solo existe en Enceladus reciente. ----
ENCELADUS_MODERNO = (IOP ~= nil)

--- Intenta cargar módulos "IRX". -------------------------------------------------------
--- Solo se intenta en la build reciente. En el ELF de 2024-10-20 incluido en
--- Prism, "Sif.loadModule" cuelga la consola en CUALQUIER llamada:
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

BDM_DEVICES = {}
BDM_ATA = {}   -- unidades que son el disco interno ATA, no un USB

require("System/core/log")

--- Identidad del soporte de arranque. -------------------------------------------------
--- El comportamiento depende de DESDE DONDE se ha lanzado el programa:
---   mc0:/mc1:    Memory Card.
---   massN:       BDM: un USB o el disco interno ATA. Se distinguen por el marcador.
---   hdd0:/pfs:   HDD interno con particiones APA (stack nativo, otro mundo).
---   host:        PCSX2 / ps2link.
--- El marcador "Roms/!Prism/internal-ata-disk.flag" se escribe desde el PC en
--- el disco interno. Hace falta porque la deteccion dinamica ("la unidad aparecio al
--- cargar ata_bd") no ve nada aparecer cuando se arranca DESDE el propio disco: en
--- ese caso los drivers ya estaban residentes, cargados por el lanzador.
MARCA_ATA = "/Roms/!Prism/internal-ata-disk.flag"

BOOT_DEV = ""            -- "mass0:", "mc0:", "hdd0:"...
BOOT_TIPO = "desconocido"
BOOT_ES_ATA = false      -- true si el programa arranca desde el disco interno

if true then
	local dir = System.currentDirectory()
	local pos = string.find(dir, ":", 1, true)
	if pos ~= nil then BOOT_DEV = string.sub(dir, 1, pos) end
	local base = string.lower(BOOT_DEV)
	if base == "mc0:" or base == "mc1:" then
		BOOT_TIPO = "Memory Card"
	elseif string.sub(base, 1, 4) == "mass" then
		if doesFileExist(dir .. MARCA_ATA) then
			BOOT_TIPO = "disco interno ATA en exFAT (marcador presente)"
			BOOT_ES_ATA = true
		else
			BOOT_TIPO = "BDM: USB (o disco interno sin marcador)"
		end
	elseif string.sub(base, 1, 3) == "hdd" or string.sub(base, 1, 3) == "pfs" then
		BOOT_TIPO = "HDD interno APA (stack nativo)"
	elseif base == "host:" then
		BOOT_TIPO = "host (PCSX2 / ps2link)"
	elseif base == "cdfs:" then
		BOOT_TIPO = "disco optico"
	end
	local build = "2024 (tabla Sif, sin tabla IOP)"
	if ENCELADUS_MODERNO then build = "2025+ (tabla IOP presente)" end
	-- La primera pregunta que hay que poder responder al abrir el log: de donde
	-- viene el ELF. Cambia todo lo demas -- si hace falta el argumento de arranque,
	-- si RetroArch podra leerse a si mismo, si hay que transbordar las ROMs.
	if BOOT_ES_ATA == true then
		boot_log("ARRANCADO DESDE : DISCO INTERNO exFAT  (".. BOOT_DEV ..")")
	else
		boot_log("ARRANCADO DESDE : LLAVE USB / soporte externo  (".. BOOT_DEV ..")")
	end
	boot_log("Soporte de arranque : ".. BOOT_DEV .."  -> ".. BOOT_TIPO)
	boot_log("currentDirectory    : ".. dir)
	boot_log("Build de Enceladus  : ".. build)
	boot_log("Marcador ATA buscado: ".. dir .. MARCA_ATA)
	boot_log("")
end

require("System/core/drives")
irx_load()

--- Raices de busqueda de juegos ("append" USB + disco interno). -----------------------
--- RAICES[1] es SIEMPRE el soporte de arranque. Se anaden las unidades ATA que
--- contengan un directorio con el mismo nombre que el del launcher.
--- Ejemplo: arranque en "mass:/Prism", disco interno en "mass1:" con un
--- "mass1:/Prism" => se buscan los juegos en los dos.
RAICES = { System.currentDirectory() }

--- Nombre de la carpeta del lanzador, sea cual sea. Se guarda porque otras partes
--- necesitan construir la misma ruta en otro soporte, y dar por hecho que se llama
--- "Prism" fallaria en cuanto alguien la renombrase.
CARPETA_LANZADOR = "Prism"

if true then
	local actual = System.currentDirectory()
	local nombre_carpeta = actual
	local corte = string.find(string.reverse(actual), "/", 1, true)
	if corte ~= nil then nombre_carpeta = string.sub(actual, -corte+1) end
	CARPETA_LANZADOR = nombre_carpeta
	-- TODA unidad BDM con un directorio homonimo, sea ATA o USB. La restriccion "solo
	-- ATA" era correcta cuando el arranque venia siempre del USB; al arrancar DESDE el
	-- disco interno la situacion se invierte, y es la llave USB la que hay que sumar.
	for i = 1, #BDM_DEVICES do
		local candidata = BDM_DEVICES[i] .."/".. nombre_carpeta
		if System.listDirectory(candidata) ~= nil then
			table.insert(RAICES, candidata)
		end
	end
	local resumen = "\nRaices de busqueda:\n"
	for i = 1, #RAICES do resumen = resumen .."  ".. i ..". ".. RAICES[i] .."\n" end
	boot_log(resumen)
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

boot_log("POPS_RAIZ = ".. tostring(POPS_RAIZ))

--- Chequeo de la configuracion de POPStarter. ----------------------------------------
--- Los drivers USB de recambio (BDMAssault) SOLO sirven en la Memory Card:
--- "mc0:/POPSTARTER/usbd.irx" y "usbhdfsd.irx". Al arrancar, POPStarter aun no sabe
--- leer el USB -es justo lo que intenta montar- asi que un POPSTARTER/ en la llave
--- es letra muerta. Aqui se listan los nombres EXACTOS, porque ademas es sensible a
--- mayusculas.
if true then
	boot_log("")
	boot_log("Chequeo POPStarter (drivers de recambio):")
	for _i, mc in ipairs({"mc0:", "mc1:"}) do
		local c = System.listDirectory(mc .."/POPSTARTER")
		if c == nil then
			boot_log("  ".. mc .."/POPSTARTER/  no existe")
		else
			local linea = "  ".. mc .."/POPSTARTER/  (".. #c .." entradas)"
			local vistos = {}
			for i = 1, #c do
				if c[i].directory == false then
					linea = linea .."\n      ".. c[i].name .."  (".. tostring(c[i].size) .." bytes)"
					vistos[string.lower(c[i].name)] = c[i].name
				end
			end
			for _j, esperado in ipairs({"usbd.irx", "usbhdfsd.irx"}) do
				local real = vistos[esperado]
				if real == nil then
					linea = linea .."\n      FALTA ".. esperado
				elseif real ~= esperado then
					linea = linea .."\n      OJO: '".. real .."' deberia llamarse '".. esperado .."' (minusculas)"
				end
			end
			boot_log(linea)
		end
	end
	local pos_b = string.find(System.currentDirectory(), ":", 1, true)
	if pos_b ~= nil then
		local raiz_boot = string.sub(System.currentDirectory(), 1, pos_b)
		if System.listDirectory(raiz_boot .."/POPSTARTER") ~= nil then
			boot_log("  AVISO: existe ".. raiz_boot .."/POPSTARTER/ - ahi NO sirve de nada.")
			boot_log("  POPStarter solo puede leer esos drivers desde la Memory Card.")
		end
	end
end

boot_log("")
boot_log("Fin del arranque del sistema. Lo que sigue se anade sin flush por linea.")
BOOT_FLUSH = false
boot_flush()

--- Everything below is definitions: paths, then one module per emulator. Nothing
--- runs until inventario() further down, so their order only follows the drive.
require("System/core/paths")
require("System/emu/pops")
require("System/library/exfatdb")
require("System/emu/retroarch")
require("System/emu/ember")
require("System/emu/retroarch_shuttle")
require("System/emu/ps2")

--- El inventario usa ES_RAIZ_ATA, asi que se llama DESPUES de definirla. -------------
inventario()

--- La carpeta "retroarch/" que RetroArch exige. Se monta AQUI, al arrancar el
--- lanzador, y no dentro de FORZAR_CONF_RETROARCH: asi sigue funcionando aunque se
--- desactiven los ajustes forzados, y el usuario solo tiene que descomprimir la
--- nightly en "LibretroPS2Files/" sin preguntarse nada mas.
LIBRETRO_REPARAR()

--- Diagnostico de la instalacion de RetroArch, al arrancar. --------------------------
--- Es la pregunta que decide si los juegos libretro van a funcionar, asi que conviene
--- que quede escrita antes de cualquier intento.
if true then
	local base_ra = RUTA_LIBRETRO()
	if base_ra == nil then
		boot_log("")
		boot_log("RETROARCH  NO ENCONTRADO. Ningun soporte lleva LibretroPS2Files/cores.")
		boot_log("           Los sistemas libretro no se ofreceran.")
	elseif ES_RAIZ_ATA(base_ra) == true then
		boot_log("")
		boot_log("RETROARCH  instalado en el DISCO INTERNO : ".. base_ra)
		boot_log("           AVISO: un core oficial no podra leerlo. Al arrancar hace")
		boot_log("           SifIopReset, el IOP se vacia y el disco interno deja de")
		boot_log("           existir para el: se queda sin cores, sin config y sin")
		boot_log("           assets, y muere antes de dibujar nada. Pantalla negra.")
		boot_log("           Solucion: mover LibretroPS2Files a una llave USB.")
		boot_log("           (Funciona tal cual con cores recompilados con ata_bd.)")
	else
		boot_log("")
		boot_log("RETROARCH  ".. base_ra .."  (soporte legible por los cores)")
	end
	boot_flush()
end

usb_inventory()

--- Vuelta del puente de partidas: se llama justo al arrancar, que es cuando se
--- vuelve de un juego. Necesita RAICES y BDM_DEVICES, de ahi que este aqui.
SAVES_RECUPERAR()

require("System/ui/loading")

--- Pantalla de carga y comprobación de directorio. -------------------------------------
if true then
	local res_x, res_y = 640, 448
	--- Reubicacion: eliminada. ----------------------------------------------------------
	--- Aqui se comparaba la ruta guardada en "System/Respaldo/RetroarchPS2/
	--- retroarch-salamander.cfg" con la ruta actual del lanzador, y si no coincidian se
	--- ejecutaba "System/relocation.lua", que reescribia veinticuatro "retroarch.cfg"
	--- -- doce sistemas por NTSC y PAL -- porque cada uno llevaba veinte rutas absolutas
	--- del tipo "mass:/Prism/System/RetroarchPS2/<sistema>/retroarch/...".
	--- Ya no queda ninguna ruta absoluta: RetroArch deduce todas sus carpetas de su
	--- propio directorio, asi que cambiar el lanzador de unidad o de carpeta no obliga
	--- a reescribir nada. La reubicacion, y las 2989 lineas que la implementaban, sobran.
	if doesFileExist("System/Defaults/PAL") == false and doesFileExist("System/Defaults/NTSC") == false then
		local VMODE = System.openFile("System/Defaults/NTSC", FCREATE)
		System.closeFile(VMODE)
	elseif doesFileExist("System/Defaults/PAL") then
		Screen.setMode(PAL, 640, 512, CT24, INTERLACED, FIELD)
		res_x, res_y = 640, 512
	end
	-- Nada de esto es local: la pantalla de carga tiene que poder repintarse desde
	-- cualquier punto del arranque para decir en que paso va. Se libera al final,
	-- justo antes de entrar en el menu.
	LOAD_RES_X, LOAD_RES_Y = res_x, res_y
	LOAD_BG = Graphics.loadImage("System/Medias/Default/FONDO.png")
	LOAD_IMG = Graphics.loadImage("System/Medias/Default/LOADING.png")

	-- La fuente se carga UNA vez: la pantalla se repinta decenas de veces y no tiene
	-- sentido releer el TTF cada vez.
	-- Todo entre pcall: esto es informacion, no puede tumbar el arranque.
	LOAD_FONT = nil
	pcall(function()
		Font.ftInit()
		LOAD_FONT = Font.ftLoad("System/Medias/Font/PublicPixel.ttf")
		Font.ftSetPixelSize(LOAD_FONT, 14, 14)
	end)

	load_step("loading screen ready")
	boot_log("BOOT   pantalla de carga pintada")
	boot_flush()
	if doesFileExist("System/Medias/Sound/Background/music.adp") == true and doesFileExist("System/Medias/Sound/Background/music0.adp") == true then
		System.removeFile("System/Medias/Sound/Background/music.adp")
	end
end

--- Formato de audio. -------------------------------------------------------------------
Sound.setFormat(16, 48000, 3)

require("System/ui/sound")

--- Cargar variables y configuraciones. -------------------------------------------------
require("System/language")
lang_select()
require("System/menu")
-- The former funciones.lua, one file per responsibility. All definitions, no code run.
require("System/ui/draw")
require("System/ui/sprites")
require("System/ui/theme_editor")
require("System/ui/credits")
require("System/ui/launch_screen")
require("System/menus/settings")
require("System/menus/game_menu")
require("System/menus/pops_menu")
require("System/menus/ps2_menu")
require("System/library/scan")
require("System/launch/run")
require("System/core/settings_io")
boot_log("BOOT   modules loaded (language, menu, ui, menus, library, launch, config)")
boot_flush()

-- Guarda las listas / últimos movimientos / límite de captura. -------------------------
PRE_CARGADAS = {}
LAST_MOVE = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
JOYSTICK_LIMITE = 0

require("System/core/state")

--- Cargar variables y configuraciones. -------------------------------------------------
load_step("reading configuration")
cargar_config()

--- Ejecutar Prism. -------------------------------------------------------------
-- El valor con el que se entra al menu, para no volver a preguntarse si el
-- interruptor guarda o no: aqui queda escrito, junto con lo que dice su fichero.
boot_log("BOOT   SEE_INDEX = ".. tostring(OPCIONES.SEE_INDEX)
	.."   SeeIndex.cfg = ".. tostring(see_index_load()))
load_step("entering menu")
boot_log("BOOT   listas construidas, entrando en el menu")
boot_flush()
load_end()
while true do
	dibujar()
	refrescar(false)
	CONTROL.FPS = Screen.getFPS(1)
end
--[[------------------SPAGHETTICODE-------------------]]--