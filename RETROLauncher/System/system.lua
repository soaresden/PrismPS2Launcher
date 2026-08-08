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

--- Normaliza el prefijo de unidad de una ruta. ---------------------------------------
--- "mass:/X" y "mass0:/X" designan lo mismo, pero el nombre depende de QUIEN lanza el
--- programa: desde el OSD o FMCB se obtiene "mass:", desde uLaunchELF "mass0:".
--- Sin esto, el launcher cree que la instalacion ha cambiado de sitio y propone
--- reubicar las configuraciones (perdiendo los ajustes de RetroArch) a cada cambio
--- de metodo de arranque.
function NORM_DEV(ruta)
	if ruta == nil then return "" end
	local pos = string.find(ruta, ":", 1, true)
	if pos == nil then return string.lower(ruta) end
	local dev = string.sub(ruta, 1, pos-1)
	while string.len(dev) > 0 and string.match(string.sub(dev, -1), "%d") ~= nil do
		dev = string.sub(dev, 1, -2)
	end
	return string.lower(dev ..":".. string.sub(ruta, pos+1))
end

--- Quita la numeracion del prefijo de unidad y DEJA EL RESTO INTACTO. ----------------
--- "mass0:/POPS/Juego.VCD" -> "mass:/POPS/Juego.VCD".
--- No confundir con NORM_DEV, que ademas pasa todo a minusculas porque sirve para
--- comparar rutas; aqui eso destrozaria el nombre del fichero.
--- Hace falta porque Enceladus 2025 monta los dispositivos como "mass0:", "mass1:",
--- mientras que el homebrew anterior a BDM -POPStarter v13, Neutrino, RetroArch-
--- solo conoce "mass:". La build de 2024 sobre la que se escribio RETROLauncher
--- reportaba "mass:", y de ahi que aquello funcionara sin tocar nada.
function DEV_SIN_NUM(ruta)
	if ruta == nil then return nil end
	local pos = string.find(ruta, ":", 1, true)
	if pos == nil then return ruta end
	local dev = string.sub(ruta, 1, pos-1)
	while string.len(dev) > 0 and string.match(string.sub(dev, -1), "%d") ~= nil do
		dev = string.sub(dev, 1, -2)
	end
	return dev ..":".. string.sub(ruta, pos+1)
end

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

--- PlayStation 1 / POPStarter. --------------------------------------------------------
--- POPStarter lee siempre el .VCD y escribe la tarjeta de memoria virtual en
--- "<unidad>/POPS/<nombre del juego>/", este donde este su ELF (por eso funciona el
--- montaje con el ELF en "APPS/"). Aun asi se admite "<raiz>/Roms/psx-pops(vcd)/" como
--- biblioteca, para no tener que separar los juegos del resto: el fichero se traslada a
--- "POPS/" la primera vez que se lanza. Dentro de la misma unidad es un renombrado,
--- instantaneo sea cual sea el tamano; entre unidades distintas hay que copiar.
POPS_SUB = "/Roms/psx-pops(vcd)"

--- Unidades que pueden tener una carpeta "POPS" en su raiz: el soporte de arranque
--- y cada unidad BDM. La misma coleccion se usa para buscar y para lanzar.
function POPS_UNIDADES()
	local u = {}
	local actual = System.currentDirectory()
	local pos = string.find(actual, ":", 1, true)
	if pos ~= nil then table.insert(u, string.sub(actual, 1, pos)) end
	if BDM_DEVICES ~= nil then
		for i = 1, #BDM_DEVICES do
			local rep = false
			for j = 1, #u do if u[j] == BDM_DEVICES[i] then rep = true end end
			if rep == false then table.insert(u, BDM_DEVICES[i]) end
		end
	end
	return u
end

--- Unidad cuyo "POPS/" contiene ese fichero. POPStarter exige que el .VCD, su ELF
--- y la tarjeta de memoria esten en la MISMA unidad, asi que lanzar con POPS_RAIZ
--- fallaba cuando el juego vivia en el otro soporte.
function POPS_DE(nombre)
	if nombre ~= nil then
		local u = POPS_UNIDADES()
		for i = 1, #u do
			if doesFileExist(u[i] .."/POPS/".. nombre) then return u[i] end
		end
	end
	return POPS_RAIZ
end

--- Ruta real del .VCD: primero "POPS/" de cada unidad, luego la biblioteca de cada
--- raiz. nil si no esta en ninguna parte.
function RUTA_VCD(nombre)
	local u = POPS_UNIDADES()
	for i = 1, #u do
		if doesFileExist(u[i] .."/POPS/".. nombre) then
			return u[i] .."/POPS/".. nombre
		end
	end
	for i = 1, #RAICES do
		if doesFileExist(RAICES[i] .. POPS_SUB .."/".. nombre) then
			return RAICES[i] .. POPS_SUB .."/".. nombre
		end
	end
	return nil
end

--- Lleva el .VCD a "POPS/" si todavia no esta ahi. Devuelve true si al final si esta.
function VCD_A_POPS(nombre)
	local destino = POPS_RAIZ .."/POPS/".. nombre
	if doesFileExist(destino) then return true end
	local origen = RUTA_VCD(nombre)
	if origen == nil then return false end
	-- Comparacion de unidad SIN normalizar: "mass0:" y "mass1:" son discos distintos.
	local function unidad(p)
		local pos = string.find(p, ":", 1, true)
		if pos == nil then return "" end
		return string.lower(string.sub(p, 1, pos))
	end
	if unidad(origen) == unidad(destino) and System.rename ~= nil then
		pcall(System.rename, origen, destino)
	end
	if doesFileExist(destino) == false then
		pcall(System.copyFile, origen, destino)
	end
	return doesFileExist(destino)
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
--- 1 = reiniciar antes de entregar el ELF.
--- Se vuelve a 0. Razon: en esta consola Neutrino y POPStarter arrancan bien y ambos
--- se lanzan con 0; lo unico que se lanzaba con 1 son los cores, y son lo unico que
--- falla. Ademas RetroArch reinicia el IOP el mismo nada mas arrancar
--- ("reset_IOP()" en frontend_ps2_init), asi que hacerlo dos veces no aporta nada y
--- deja al cargador sin drivers para leer el propio ELF.
IOP_REBOOT_CORES = 0

--- Tamano maximo del historial. Al pasarlo se recorta por el PRINCIPIO, nunca por el
--- final: lo interesante es siempre lo ultimo. A ~700 bytes por entrada esto guarda
--- del orden de un centenar de lanzamientos, varias sesiones de pruebas.
LAUNCH_LOG_MAX = 60000

--- Marca de sesion: se escribe una vez por arranque, para separar en el fichero lo
--- que viene de un encendido y lo que viene del siguiente.
LAUNCH_LOG_SESION = false

function log_lanzamiento(titulo, campos)
	if LAUNCH_LOG_ON ~= true then return end
	pcall(function()
		-- HISTORIAL CONTINUO. El fichero nunca se vacia: se lee, se le anade la
		-- entrada nueva al final y se reescribe entero. Sobrevive por tanto a los
		-- reinicios, que es justo lo que hace falta cuando cada prueba fallida
		-- devuelve el control a uLaunchELF.
		local previo = ""
		pcall(function()
			local ruta = System.currentDirectory() .."/LAUNCH_LOG.txt"
			if doesFileExist(ruta) then
				local f = System.openFile(ruta, FREAD)
				local tam = System.sizeFile(f)
				System.seekFile(f, 0, SET)
				previo = System.readFile(f, tam)
				System.closeFile(f)
				if string.len(previo) > LAUNCH_LOG_MAX then
					previo = "[...principio recortado...]\n"..
						string.sub(previo, string.len(previo) - LAUNCH_LOG_MAX + 1000)
				end
			end
		end)

		local t = previo
		if t == "" then
			t = "RETROLauncher - historial de lanzamientos\n"
			t = t .."=========================================\n"
			t = t .."Se anade una entrada por lanzamiento y no se borra nunca.\n"
			t = t .."LAUNCH_LOG_ON a false en system.lua lo desactiva.\n"
		end
		if LAUNCH_LOG_SESION == false then
			LAUNCH_LOG_SESION = true
			local sello = ""
			-- La PS2 tiene reloj, pero "os.date" no siempre esta expuesto: si falla,
			-- la marca se queda sin fecha y sigue sirviendo de separador.
			pcall(function() sello = "  ".. os.date("%Y-%m-%d %H:%M:%S") end)
			t = t .."\n============================================================\n"
			t = t .."ARRANQUE".. sello .."\n"
			t = t .."============================================================\n"
		end
		t = t .."\n------------------------------------------------------------\n"
		t = t .. titulo .."\n\n"
		for i = 1, #campos do
			t = t .. campos[i] .."\n"
		end
		if MEDIA_DIAG ~= nil and #MEDIA_DIAG >= 1 then
			t = t .."\nCaratula del juego seleccionado, rutas probadas en orden:\n"
			for i = 1, #MEDIA_DIAG do t = t .."  ".. MEDIA_DIAG[i] .."\n" end
		end
		t = t .."\n(si esta es la ultima entrada, el fallo esta en el ELF de arriba)\n"
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
--- Los genera el script "HelperScripts/MediaCopier.py" en un "titles.txt" por
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
		t = string.sub(limpio, 1, -CONTROL.EXTENSION)
	end
	if desde ~= nil and desde > 1 then return string.sub(t, desde) end
	return t
end

--- Base de datos de lo que la consola ve realmente: "exfatdb.json", junto al ELF. ----
--- Se rellena a medida que se recorren los sistemas y se reescribe en cada cambio.
--- Sirve sobre todo para ajustar los scripts del PC: es la unica fuente fiable de
--- lo que la PS2 encuentra, con los nombres de unidad tal como ella los ve.
EXFATDB_ON = true
EXFATDB = {}
EXFATDB_SUCIA = false

--- Escapa una cadena para JSON. -----------------------------------------------------
function json_txt(s)
	s = tostring(s)
	s = string.gsub(s, "\\", "\\\\")
	s = string.gsub(s, "\"", "\\\"")
	s = string.gsub(s, "[\r\n\t]", " ")
	return "\"".. s .."\""
end

--- Registra un directorio explorado y su contenido. ---------------------------------
--- "clave" permite agrupar bajo otro nombre que el de ROMS_DIR[identidad]: PS1 usa
--- una sola identidad para dos formatos ("psx-ember(bin and cue)" y "psx-pops(vcd)").
function exfatdb_dir(identidad, sistema, directorio, entradas, clave)
	if EXFATDB_ON ~= true or directorio == nil then return end
	local reg = EXFATDB[directorio]
	if reg == nil then
		reg = {
			identidad = identidad,
			sistema   = sistema,
			clave     = clave,
			ata       = ES_RAIZ_ATA(directorio),
			juegos    = {},
		}
		EXFATDB[directorio] = reg
	end
	-- FUSIONAR, no sustituir. Un mismo directorio aparece varias veces en la lista
	-- de busqueda: con su nombre propio y otra vez como alias EmulationStation. En
	-- la segunda pasada los juegos ya estan en "vistos", asi que la lista llega
	-- vacia; sustituir el registro borraba todo lo encontrado en la primera.
	for i = 1, #entradas do
		reg.juegos[entradas[i].fichero] = entradas[i].titulo
	end
	EXFATDB_SUCIA = true
end

--- Vuelca el fichero. ---------------------------------------------------------------
--- Agrupado por soporte ("USB" / "ATA") y por sistema, no por directorio: en un
--- sistema de ficheros que ignora mayusculas, "Roms/nes" y "roms/nes" son la misma
--- carpeta y aparecian dos veces. Aqui se fusionan, y los juegos repetidos tambien.
function exfatdb_escribir()
	if EXFATDB_ON ~= true or EXFATDB_SUCIA ~= true then return end
	EXFATDB_SUCIA = false
	pcall(function()
		-- Reagrupar: soporte -> sistema -> conjunto de ficheros.
		local grupo = {USB = {}, ATA = {}}
		for ruta, info in pairs(EXFATDB) do
			local soporte = "USB"
			if info.ata == true then soporte = "ATA" end
			local clave = info.clave or ROMS_DIR[info.identidad]
			if clave == nil then clave = tostring(info.sistema) end
			if grupo[soporte][clave] == nil then grupo[soporte][clave] = {} end
			local destino = grupo[soporte][clave]
			for fichero, titulo in pairs(info.juegos) do
				destino[fichero] = titulo
			end
		end

		local function bloque(soporte, sangria)
			local sistemas = {}
			for k, _v in pairs(grupo[soporte]) do table.insert(sistemas, k) end
			table.sort(sistemas)
			local s = ""
			for i = 1, #sistemas do
				local ficheros = {}
				for f, _t in pairs(grupo[soporte][sistemas[i]]) do
					table.insert(ficheros, f)
				end
				table.sort(ficheros)
				-- "POPS" vive en la raiz de la unidad, no bajo "roms/".
			local etiqueta = "roms/".. sistemas[i]
			if sistemas[i] == "POPS" then etiqueta = "POPS" end
			s = s .. sangria .."  ".. json_txt(etiqueta) ..": [\n"
				for j = 1, #ficheros do
					s = s .. sangria .."    ".. json_txt(ficheros[j])
					if j < #ficheros then s = s .."," end
					s = s .."\n"
				end
				s = s .. sangria .."  ]"
				if i < #sistemas then s = s .."," end
				s = s .."\n"
			end
			return s
		end

		--- Unidad asociada a cada soporte, para poder reconstruir la ruta completa.
		local u_usb, u_ata = "", ""
		local pos = string.find(System.currentDirectory(), ":", 1, true)
		if pos ~= nil then u_usb = string.sub(System.currentDirectory(), 1, pos) end
		for i = 1, #BDM_DEVICES do
			if BDM_ATA[BDM_DEVICES[i]] == true and u_ata == "" then
				u_ata = BDM_DEVICES[i]
			end
		end

		local t = "{\n"
		t = t .."  \"generado_por\": \"RETROLauncher fork - exFAT HDD\",\n"
		t = t .."  \"nota\": \"Rutas relativas a la carpeta del launcher en cada unidad. "
		t = t .."Solo aparecen los sistemas abiertos en el menu desde el ultimo arranque.\",\n"
		t = t .."  \"launcher\": ".. json_txt(System.currentDirectory()) ..",\n"
		t = t .."  \"USB\": {\n"
		t = t .."    \"unidad\": ".. json_txt(u_usb) ..",\n"
		t = t .."    \"juegos\": {\n".. bloque("USB", "    ") .."    }\n"
		t = t .."  },\n"
		t = t .."  \"ATA\": {\n"
		t = t .."    \"unidad\": ".. json_txt(u_ata) ..",\n"
		t = t .."    \"juegos\": {\n".. bloque("ATA", "    ") .."    }\n"
		t = t .."  }\n}\n"

		local f = System.openFile(System.currentDirectory() .."/exfatdb.json", FCREATE)
		System.writeFile(f, t, string.len(t))
		System.closeFile(f)
	end)
end

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
		local cand = RAICES[i] .."/Retroarch Extracted Files/raboot.elf"
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

--- Sobrecarga de cores RetroArch. ---------------------------------------------------
--- "Retroarch Extracted Files/cores/" recibe una nightly descomprimida tal cual.
--- Si un core esta ahi, sustituye al incluido en "System/RetroarchPS2/<sistema>/".
--- No se comparan fechas: la API Lua de PS2 no expone la fecha de un fichero, solo
--- nombre, tamano y tipo. La regla es "si esta aqui, gana".
--- Se busca en TODAS las raices, asi que la carpeta puede estar en el disco exFAT.
function RUTA_CORE(nombre_core, ruta_original)
	if nombre_core == nil or nombre_core == " " then return ruta_original end
	if RAICES ~= nil then
		for i = 1, #RAICES do
			local cand = RAICES[i] .."/Retroarch Extracted Files/cores/".. nombre_core
			if doesFileExist(cand) then return cand end
		end
	end
	return ruta_original
end

--- Nombres de carpeta de este fork, bajo "Roms/". -----------------------------------
ROMS_DIR = {
	"megadrive", "mastersystem", "gamegear", "nes", "gb", "gbc", "gba",
	"atari2600", "lynx", "sg1000", "ngp", "snes",
	"APPS-Media", "psx-ember(bin and cue)", "ps2-isos",
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

--- Extensiones declaradas por un core, leidas de su ".info". ------------------------
--- "picodrive_libretro_ps2.elf" -> "info/picodrive_libretro.info".
function CORE_EXTENSIONES(ruta_core)
	local n = nombre_fichero(ruta_core)
	if string.len(n) < 9 or string.sub(n, -8) ~= "_ps2.elf" then return nil end
	local info = string.sub(n, 1, -9) ..".info"
	if RAICES == nil then return nil end
	for i = 1, #RAICES do
		local p = RAICES[i] .."/Retroarch Extracted Files/info/".. info
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
	local sup = CORE_EXTENSIONES(ruta_core)
	if sup == nil then return false end
	sup = "|".. string.lower(sup) .."|"
	for i = 1, #exts do
		if string.find(sup, "|".. exts[i] .."|", 1, true) ~= nil then return true end
	end
	return false
end

--- Despliegue de Ember junto a los juegos. -------------------------------------------
--- Ember resuelve el .cue RELATIVO a su propio directorio: el original le pasaba solo
--- el nombre del fichero y lo lanzaba desde la carpeta de los juegos. Al mover el
--- emulador a "Bios/" se rompio ese contrato, y Ember arrancaba en la pantalla del
--- BIOS por no encontrar el disco. Se restaura el montaje de origen: "ember.elf" y
--- "bios.bin" se colocan junto a los .cue, copiados desde "Bios/" la primera vez.
--- Son dos ficheros pequenos y una sola vez por carpeta.
--- Devuelve la ruta del ELF listo para lanzar, o nil.
function EMBER_EN(carpeta)
	if carpeta == nil then return nil end
	local elf = carpeta .."/ember.elf"
	local bios = carpeta .."/bios.bin"
	if doesFileExist(elf) == false then
		local origen = RUTA_BIOS("psx-ember.elf", "")
		if doesFileExist(origen) == false then return nil end
		pcall(System.copyFile, origen, elf)
	end
	if doesFileExist(bios) == false then
		local origen = RUTA_BIOS("bios.bin", "")
		if doesFileExist(origen) then pcall(System.copyFile, origen, bios) end
	end
	if doesFileExist(elf) then return elf end
	return nil
end

--- Retardo de acceso al USB de POPStarter. -------------------------------------------
--- POPStarter da por perdido el dispositivo si tarda en responder, y entonces escribe
--- "Opening mass:/POPS/... FAILED / No POPS directory ? / Increase the USB access
--- delay". El valor vive en un solo byte de su tabla de configuracion, en el offset
--- 0x413, y por tanto hay que parchearlo en CADA copia "XX.<juego>.ELF", porque cada
--- atajo es un POPStarter completo. De fabrica vale 3, que es poco para muchas llaves.
--- 0 = no tocar nada.
POPS_USB_DELAY = 20

function PARCHE_USB_DELAY(ruta)
	if POPS_USB_DELAY == nil or POPS_USB_DELAY <= 0 then return end
	if ruta == nil or doesFileExist(ruta) == false then return end
	pcall(function()
		local f = System.openFile(ruta, FRDWR)
		-- Comprobacion de firma: los bytes que rodean al retardo en la Rev 13.
		System.seekFile(f, 0x410, SET)
		local marco = System.readFile(f, 8)
		if marco == nil or string.len(marco) < 8
		   or string.byte(marco, 1) ~= 0 or string.byte(marco, 2) ~= 0
		   or string.byte(marco, 3) ~= 0 or string.byte(marco, 5) ~= 0x40
		   or string.byte(marco, 8) ~= 1 then
			System.closeFile(f)
			return
		end
		System.seekFile(f, 0x413, SET)
		System.writeFile(f, string.char(POPS_USB_DELAY), 1)
		System.closeFile(f)
	end)
end

--- Reinicio del IOP para POPStarter y Ember. -----------------------------------------
--- Al contrario que los cores de RetroArch, estos dos son homebrew antiguo que carga
--- sus propios modulos. Este fork deja residentes "dev9_ns" y "ata_bd", que el
--- original nunca cargaba: es la unica diferencia de entorno que queda respecto a la
--- version de partida, y ambos son justamente los que dejaron de arrancar. Con 1 se
--- les entrega un IOP limpio, sin esos modulos.
IOP_REBOOT_POPS = 1
IOP_REBOOT_EMBER = 1

MEDIA_ALIAS = {
	"megadrive", "mastersystem", "gamegear", "nes", "gb", "gbc", "gba",
	"atari2600", "lynx", "sg1000", "ngp", "snes",
	"APPS-Media", "psx-ember(bin and cue)", "ps2-isos",
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
	local alias = {MEDIA_ALIAS[identidad]}
	if identidad == 14 then table.insert(alias, "psx-pops(vcd)") end
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

--- Rutas probadas para la ultima caratula. Se vuelcan en LAUNCH_LOG.txt al lanzar,
--- que es la unica forma de ver desde el PC lo que la consola ha mirado de verdad.
MEDIA_DIAG = {}

--- Traza de la carga de imagenes. --------------------------------------------------
--- "Graphics.loadImage" puede colgar la consola con un PNG que no le gusta o que no
--- cabe en VRAM, y entonces no queda ni mensaje ni log. Aqui se escribe la ruta
--- ANTES de cargarla: si la consola se congela, el ultimo renglon del fichero nombra
--- la imagen culpable. Poner a false cuando ya no haga falta, escribe en cada
--- cambio de seleccion.
ART_LOG_ON = true

function log_art(fase, ruta)
	if ART_LOG_ON ~= true then return end
	pcall(function()
		local t = "RETROLauncher - carga de imagenes\n"
		t = t .."=================================\n\n"
		t = t .."Si este fichero termina en \"-> cargando\", la consola se colgo\n"
		t = t .."al abrir esa imagen. Convertirla o reducirla resuelve el caso.\n\n"
		t = t .. fase .." -> ".. tostring(ruta) .."\n"
		local f = System.openFile(System.currentDirectory() .."/MEDIA_LOG.txt", FCREATE)
		System.writeFile(f, t, string.len(t))
		System.closeFile(f)
	end)
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

--- Recursos globales (fondos, fuentes). Nueva ubicacion: "Roms/!Retrolauncher/",
--- junto al resto del contenido. Se conserva "Multimedia/Others" como respaldo.
function RUTA_GLOBAL(que)
	local actual = System.currentDirectory()
	local nuevo = actual .."/Roms/!Retrolauncher/".. que
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
	-- Comparacion normalizada: solo el prefijo de unidad puede diferir segun el
	-- metodo de arranque, y eso no justifica reubicar nada.
	local esperado = NORM_DEV("libretro_path = \"".. actual .."/RETROLauncher.elf\"")
	if esperado ~= NORM_DEV(temp_dir) or usb2 then
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