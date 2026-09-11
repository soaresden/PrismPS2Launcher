-- Prism PS2 Launcher - core/paths.lua
-- Resolving paths: roots, ROM folders, titles, artwork, wLaunchELF.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- Primera raiz donde exista la ruta relativa dada (empieza por "/"). ------------------
function RAIZ(rel)
	for i = 1, #RAICES do
		if doesFileExist(RAICES[i] .. rel) then return RAICES[i] end
	end
	return RAICES[1]
end

--- Origen de cada juego encontrado: ORIGEN["identidad|nombre"] = raiz. ---------------
--- Busqueda en el lector CD/DVD ("cdfs:"). -------------------------------------------
--- Spaghetticode (autor del proyecto) reporta que el programa se cuelga si se lanza
--- desde un wLaunchELF que ya haya cargado el modulo CD/DVD (consola Slim), y que el
--- problema desaparece si se omite todo lo relacionado con la busqueda en el lector.
--- false = no tocar el lector. true = comportamiento original.
BUSCAR_CDVD = false

--- Nombres de carpeta al estilo EmulationStation / Batocera, por sistema. ------------
--- Se aceptan ademas de la estructura propia "Roms/Roms <sistema>", tanto en
--- "<raiz>/roms/<alias>" como en "<unidad>/roms/<alias>" (disposicion Batocera).
ES_ALIAS = {
	{"megadrive", "genesis", "md"},
	{"mastersystem", "sms"},
	{"gamegear", "gg"},
	{"nes", "famicom", "fds"},
	{"gb", "gameboy"},
	{"gbc", "gameboycolor"},
	{"gba", "gameboyadvance"},
	{"atari2600"},
	{"lynx", "atarilynx"},
	{"sg1000", "sg-1000"},
	{"ngp", "ngpc", "neogeopocket"},
	{"snes", "sfc", "supernintendo"},
}

--- Ruta real de una ROM: el directorio memorizado durante el scan si existe, si no
--- la estructura propia resuelta sobre las raices.
function RUTA_ROM(identidad, sistema, nombre)
	local clave = tostring(identidad) .."|".. nombre
	if ORIGEN_DIR ~= nil and ORIGEN_DIR[clave] ~= nil then
		return ORIGEN_DIR[clave] .. nombre
	end
	return RUTA("/Roms/Roms ".. sistema .."/".. nombre)
end

--- Titulos reales de los juegos. TITULOS["identidad|fichero"] = titulo. -------------
--- Los genera el script "HelperScripts/BatoceraGamelistandBatoceraGamelistandMediaCopier.py" en un "titles.txt" por
--- carpeta, a partir del gamelist.xml de Batocera / Recalbox / EmulationStation.
--- Formato de cada linea: nombre_de_fichero|Titulo del juego
TITULOS = {}
TITULOS_LEIDOS = {}

function cargar_titulos(directorio, identidad)
	if directorio == nil then return end
	if TITULOS_LEIDOS[directorio] == true then return end
	TITULOS_LEIDOS[directorio] = true

	local ruta = directorio .."/titles.txt"
	if doesFileExist(ruta) == false then return end
	pcall(function()
		local fd = System.openFile(ruta, FREAD)
		local tam = System.sizeFile(fd)
		System.seekFile(fd, 0, SET)
		local datos = System.readFile(fd, tam)
		System.closeFile(fd)
		for linea in string.gmatch(datos, "[^\r\n]+") do
			local corte = string.find(linea, "|", 1, true)
			if corte ~= nil then
				local fichero = string.sub(linea, 1, corte-1)
				local titulo  = string.sub(linea, corte+1)
				if fichero ~= "" and titulo ~= "" then
					TITULOS[tostring(identidad) .."|".. fichero] = titulo
				end
			end
		end
	end)
end

--- Nombre a mostrar: el titulo real si se conoce, si no el nombre de fichero
--- recortado de su extension como hace el programa de origen.
function NOMBRE_VISIBLE(identidad, nombre, desde)
	if nombre == nil then return "" end
	local t = TITULOS[tostring(identidad) .."|".. nombre]
	if t == nil then
		local limpio = nombre
		while string.sub(limpio, -1) == " " do limpio = string.sub(limpio, 1, -2) end
		t = string.match(limpio, "^(.*)%.[^%.]+$") or limpio
	end
	if desde ~= nil and desde > 1 then return string.sub(t, desde) end
	return t
end

--- Cores RetroArch. -----------------------------------------------------------------
--- "LibretroPS2Files/cores/" recibe una nightly descomprimida tal cual, y es
--- el UNICO sitio donde se buscan los cores. Las copias por sistema que habia en
--- "System/RetroarchPS2/<sistema>/cores/" estan borradas: eran los mismos diez ficheros
--- repetidos trece veces, 36 MB.
--- Se busca en TODAS las raices, asi que la carpeta puede estar en el disco exFAT.
--- "ruta_original" se conserva como respaldo por si alguien reintroduce esas copias.
--- uLaunchELF, cualquiera que sea el nombre del ELF. ---------------------------------
--- Cada version se distribuye con un nombre distinto -- "WLE.ELF", "WLE-R3Z.ELF",
--- "WLE-R3Z-DS34.ELF"... -- asi que buscarlo por nombre fijo se rompe en cuanto el
--- usuario actualiza. Se coge el primer ".elf" de la carpeta.
--- Un nombre que empieza por "_" esta desactivado a proposito: es la marca que usa el
--- menu para esconder la aplicacion de la lista sin borrarla.
--- Devuelve (ruta, nombre, desactivado) o nil.
function RUTA_WLE(incluir_desactivado)
	local dir = System.currentDirectory() .."/uLaunchELF"
	local lista = System.listDirectory(dir)
	if lista == nil then return nil end
	local reserva, reserva_n = nil, nil
	for i = 1, #lista do
		local n = lista[i].name
		if lista[i].directory == false and string.lower(string.sub(n, -4)) == ".elf" then
			if string.sub(n, 1, 1) == "_" then
				if reserva == nil then reserva, reserva_n = dir .."/".. n, n end
			else
				return dir .."/".. n, n, false
			end
		end
	end
	if incluir_desactivado == true and reserva ~= nil then
		return reserva, reserva_n, true
	end
	return nil
end

--- Nombres de carpeta de este fork, bajo "Roms/". -----------------------------------
--- Rastreo de aplicaciones en la RAIZ de cada unidad. ---------------------------------
--- La lista de APPS se buscaba, ademas de en "APPS/" y "Roms/APPS", en la raiz misma
--- del disco, de la tarjeta mc0: y de mc1:, entrando UN NIVEL en cada carpeta que
--- encontrara alli. En un disco que ademas sirve para OPL eso significa listar "ART",
--- "THM", "CHT", "$RECYCLE.BIN" y "System Volume Information", que llevan miles de
--- ficheros cada una: el arranque se paraba ahi, en el sistema 13.
--- A false se buscan las aplicaciones solo donde tienen que estar: "APPS/" en cada
--- unidad, "mc0:/APPS", "mc1:/APPS" y "Roms/APPS". A true vuelve el rastreo completo.
APPS_RAIZ_ON = false

ROMS_DIR = {
	"megadrive", "mastersystem", "gamegear", "nes", "gb", "gbc", "gba",
	"atari2600", "lynx", "sg1000", "ngp", "snes",
	"APPS", "psx", "ps2",
}

--- Ficheros de sistema, agrupados en "Bios/" en la raiz del launcher. ---------------
--- Se conservan las ubicaciones historicas como respaldo.
function RUTA_BIOS(fichero, respaldo)
	local actual = System.currentDirectory()
	local cand = actual .."/Bios/".. fichero
	if doesFileExist(cand) then return cand end
	if respaldo ~= nil and doesFileExist(respaldo) then return respaldo end
	return cand
end

--- Nombre de fichero de una ruta. ---------------------------------------------------
function nombre_fichero(ruta)
	if ruta == nil then return "" end
	local i = string.len(ruta)
	while i > 0 and string.sub(ruta, i, i) ~= "/" do i = i - 1 end
	return string.sub(ruta, i+1)
end

--- Extensiones reales de cada sistema, para cruzarlas con las que declara cada core.
--- Faltan "zip" y "bin" a proposito: no distinguen nada. Ocho de los cores instalados
--- declaran "bin" (stella2014, gpsp, o2em, gearcoleco, freeintv, smsplus...), asi que
--- incluirlo daria por bueno casi cualquier core para casi cualquier sistema.
SISTEMA_EXTEN = {
	{"gen", "smd", "md"}, {"sms"}, {"gg"}, {"nes", "fds", "unf"},
	{"gb"}, {"gbc"}, {"gba"}, {"a26"}, {"lnx", "lyx"}, {"sg"},
	{"ngc", "ngp", "npc"}, {"sfc", "smc"},
}

MEDIA_ALIAS = {
	"megadrive", "mastersystem", "gamegear", "nes", "gb", "gbc", "gba",
	"atari2600", "lynx", "sg1000", "ngp", "snes",
	"APPS", "psx", "ps2",
}

--- Indice de las carpetas de medios. -------------------------------------------------
--- El manual avisa (pagina 46): "comprobar si una imagen existe en una carpeta de 500
--- elementos no es lo mismo que buscarla en una de mas de 1000". Cada cambio de
--- seleccion preguntaba por hasta seis rutas distintas, una llamada al sistema de
--- ficheros cada una, y este fork ha multiplicado las raices a explorar.
--- Aqui la carpeta se lista UNA vez y despues la comprobacion es una busqueda en
--- tabla, gratis. El indice se vacia al reconstruir una lista, que es cuando el
--- contenido puede haber cambiado.
MEDIA_INDICE = {}

function media_indice(directorio)
	local idx = MEDIA_INDICE[directorio]
	if idx ~= nil then return idx end
	idx = {}
	local c = System.listDirectory(directorio)
	if c ~= nil then
		for i = 1, #c do
			if c[i].directory == false then idx[c[i].name] = true end
		end
	end
	MEDIA_INDICE[directorio] = idx
	return idx
end

function media_indice_olvidar()
	MEDIA_INDICE = {}
end

--- Localizacion de caratulas y capturas. --------------------------------------------
--- Este fork busca PRIMERO junto a la propia ROM, lo que permite que los medios de
--- los juegos del disco exFAT vivan en el disco exFAT:
---   <carpeta de la rom>/media/covers/<fichero sin extension>.png
---   <carpeta de la rom>/media/screenshots/<fichero sin extension>.png
--- Si no hay nada, se usa la ubicacion historica del programa:
---   <launcher>/Multimedia/Covers/Covers <Sistema>/<fichero sin extension>.png
function RUTA_MEDIA(tipo, identidad, sistema, nombre, base)
	if nombre == nil then return "" end
	local carpeta = "covers"
	local clasico = "Covers/Covers "
	if tipo == "screenshot" then
		carpeta = "screenshots"
		clasico = "Screenshots/Screenshots "
	end

	-- 1. "Roms/<alias>/media/..." sobre cada raiz, EN ORDEN: RAICES[1] es siempre el
	--    soporte de arranque, asi que el USB gana. Un juego que vive en el disco
	--    exFAT usa la caratula del USB si esta ahi, lo que permite centralizar todas
	--    las imagenes en la llave sin duplicarlas en el disco.
	if tipo == "cover" then MEDIA_DIAG = {} end
	local function probar(dir, fichero)
		local hay = media_indice(dir)[fichero] == true
		if tipo == "cover" and #MEDIA_DIAG < 8 then
			table.insert(MEDIA_DIAG, (hay and "[ok]   " or "[FALTA] ") .. dir .."/".. fichero)
		end
		return hay
	end

	-- PS1 reune dos formatos bajo la misma identidad, y sus imagenes pueden estar en
	-- la carpeta de cualquiera de los dos. Se prueban ambas.
	local fichero = base ..".png"
	-- PlayStation: UNA sola carpeta de imagenes, "Roms/psx/media", como en
	-- EmulationStation. Un juego de PS1 puede ser un .VCD en "POPS/" o una carpeta
	-- en "Ember/games/", y es el mismo juego con la misma caratula: se guarda una vez.
	local alias = {MEDIA_ALIAS[identidad]}
	if RAICES ~= nil then
		for a = 1, #alias do
			if alias[a] ~= nil then
				for i = 1, #RAICES do
					local dir = RAICES[i] .."/Roms/".. alias[a] .."/media/".. carpeta
					if probar(dir, fichero) then return dir .."/".. fichero end
				end
			end
		end
	end

	-- 2. Junto a la propia ROM, este donde este.
	local orig = nil
	if ORIGEN_DIR ~= nil then orig = ORIGEN_DIR[tostring(identidad) .."|".. nombre] end
	if orig ~= nil then
		local dir = orig .."media/".. carpeta
		if probar(dir, fichero) then return dir .."/".. fichero end
	end

	-- 3. Ubicacion historica, por compatibilidad con instalaciones existentes.
	local dir = base_launcher() .."/Multimedia/".. clasico .. sistema
	probar(dir, fichero)
	return dir .."/".. fichero
end

--- Rutas probadas para la ultima caratula. Se vuelcan en el journal al lanzar,
--- que es la unica forma de ver desde el PC lo que la consola ha mirado de verdad.
MEDIA_DIAG = {}

--- Traza de la carga de imagenes. --------------------------------------------------
--- "Graphics.loadImage" puede colgar la consola con un PNG que no le gusta o que no
--- cabe en VRAM, y entonces no queda ni mensaje ni log. Aqui se escribe la ruta
--- ANTES de cargarla: si la consola se congela, el ultimo renglon del fichero nombra
--- la imagen culpable. Poner a false cuando ya no haga falta, escribe en cada
--- La ultima imagen abierta, como testigo de cuelgue. ---------------------------------
--- Si el journal termina en una linea ART que dice "cargando", la consola se colgo al
--- abrir esa imagen: convertirla o reducirla resuelve el caso.
--- ART_LOG_ON a false -- que es lo normal -- solo la guarda en memoria y la escribe
--- cuando algo mas provoque un volcado. A true la escribe en el acto, y entonces CADA
--- caratula reescribe el fichero entero: solo para cazar precisamente ese cuelgue.
ART_LOG_ON = false

function log_art(fase, ruta)
	ART_ULTIMA = tostring(fase) .." -> ".. tostring(ruta)
	if ART_LOG_ON == true then boot_flush() end
end

--- Carpeta "ART" de OPL. Esta en la RAIZ de la unidad, NO dentro del launcher, y
--- upstream solo miraba en el soporte de arranque. Aqui se recorren tambien las
--- unidades BDM, para que "<disco exFAT>/ART" sirva a los juegos que viven ahi.
function RUTA_ART(fichero)
	local cand = {}
	local actual = System.currentDirectory()
	local pos = string.find(actual, ":", 1, true)
	if pos ~= nil then table.insert(cand, string.sub(actual, 1, pos)) end
	if BDM_DEVICES ~= nil then
		for i = 1, #BDM_DEVICES do table.insert(cand, BDM_DEVICES[i]) end
	end
	-- "ART" de OPL puede tener cientos de imagenes: se indexa como las demas.
	for i = 1, #cand do
		if media_indice(cand[i] .."/ART")[fichero] == true then
			return cand[i] .."/ART/".. fichero
		end
	end
	if #cand >= 1 then return cand[1] .."/ART/".. fichero end
	return actual .."/ART/".. fichero
end

--- Recursos globales (fondos, fuentes). Nueva ubicacion: "Roms/!Prism/",
--- junto al resto del contenido. Se conserva "Multimedia/Others" como respaldo.
function RUTA_GLOBAL(que)
	local actual = System.currentDirectory()
	local nuevo = actual .."/Roms/!Prism/".. que
	if System.listDirectory(nuevo) ~= nil then return nuevo end
	return actual .."/Multimedia/Others/".. que
end

--- Carpeta del launcher (soporte de arranque). --------------------------------------
function base_launcher()
	return System.currentDirectory()
end

ERROR_DETALLE = nil   -- detalle del ultimo fallo de "existe()"

--- El cuadro de error solo dispone de UNA linea entre el titulo y el pie. Aqui se
--- devuelve un texto corto (solo los nombres de fichero, truncado si hace falta) y
--- se vuelca la version completa, con la ruta, en el journal.
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
