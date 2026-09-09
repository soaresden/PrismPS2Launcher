-- Prism PS2 Launcher - core/drives.lua
-- IRX loading and BDM drive probing: which unit is the internal disk.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- Sondeo de las unidades y clasificacion USB / ATA. ----------------------------------
--- "antes" es la foto de las unidades tomada ANTES de cargar ata_bd: una unidad que
--- no estaba y ahora esta ha sido montada por ata_bd, luego es el disco interno.
--- La otra via es el marcador, que funciona aunque los drivers ya fuesen residentes.
function sondear_bdm(antes)
	local actual = System.currentDirectory()
	local propio = ""
	local pos = string.find(actual, ":", 1, false)
	if pos ~= nil then propio = string.sub(actual, 1, pos) end
	boot_log("")
	boot_log("Unidades detectadas (propio = ".. propio ..") :")
	for n = -1, 5 do
		local unidad = "mass:"
		if n >= 0 then unidad = "mass".. n ..":" end
		-- En la build 2025 "mass:" es un ALIAS de "mass0:": sondear los dos duplica
		-- la unidad en BDM_DEVICES y de ahi en las raices de busqueda. Solo se mira
		-- "mass:" cuando "mass0:" no existe (build 2024).
		local contenido = nil
		if unidad == "mass:" and System.listDirectory("mass0:") ~= nil then
			boot_log("  mass:   alias de mass0: en esta build, omitido")
		else
			contenido = System.listDirectory(unidad)
		end
		if contenido ~= nil then
			local texto = "  ".. unidad .."  OK  (".. #contenido .." entradas)"
			for i = 1, math.min(#contenido, 30) do
				local marca = "   "
				if contenido[i].directory == true then marca = " d " end
				texto = texto .."\n      ".. marca .. contenido[i].name
			end
			if antes[unidad] ~= true then
				BDM_ATA[unidad] = true
				texto = texto .."\n      -> ATA (montada por ata_bd, NO es un USB)"
			elseif doesFileExist(unidad .."/Prism".. MARCA_ATA) then
				BDM_ATA[unidad] = true
				texto = texto .."\n      -> ATA (marcador del disco interno presente)"
			elseif unidad == BOOT_DEV and BOOT_ES_ATA == true then
				BDM_ATA[unidad] = true
				texto = texto .."\n      -> ATA (es el soporte de arranque)"
			else
				texto = texto .."\n      -> USB"
			end
			boot_log(texto)
			if unidad ~= propio then table.insert(BDM_DEVICES, unidad) end
		else
			boot_log("  ".. unidad .."  no montada")
		end
	end
	local mcs = {"mc0:", "mc1:"}
	for i = 1, #mcs do
		if System.listDirectory(mcs[i] .."/") ~= nil then
			boot_log("  ".. mcs[i] .."   OK (Memory Card)")
		else
			boot_log("  ".. mcs[i] .."   no accesible")
		end
	end
end

function irx_load()
	local actual = System.currentDirectory()

	-- Foto de las unidades antes de tocar nada.
	local antes = {}
	for n = -1, 5 do
		local u = "mass:"
		if n >= 0 then u = "mass".. n ..":" end
		if System.listDirectory(u) ~= nil then antes[u] = true end
	end

	-- El pre-boot (System/index.lua) ya ha cargado -o decidido no cargar- los IRX.
	-- Recargar un driver ya registrado cuelga la consola, asi que aqui solo se
	-- sondean las unidades.
	if PREBOOT_IRX_HECHO == true then
		boot_log("Pre-boot detectado (System/index.lua), origen: ".. tostring(PREBOOT_ORIGEN))
		boot_log("Los IRX ya fueron tratados alli: no se recargan.")
		sondear_bdm(antes)
		return
	end

	-- Arranque DESDE el disco interno: dev9 y ata_bd estan forzosamente residentes,
	-- cargados por el lanzador (wLaunchELF ISR u otro) - sin ellos este fichero no se
	-- habria podido leer. Registrar un driver dos veces cuelga la consola
	-- ("BDM: ERROR: Already registered!"), asi que aqui NO se carga nada.
	if BOOT_ES_ATA == true then
		boot_log("Arranque desde el disco interno: NO se carga ningun IRX.")
		boot_log("dev9/ata_bd ya estan residentes (los cargo el lanzador); recargarlos")
		boot_log("colgaria la consola.")
		BDM_ATA[BOOT_DEV] = true
		sondear_bdm(antes)
		return
	end

	-- Build 2024: Sif.loadModule cuelga la consola en CUALQUIER llamada. Probado con
	-- las formas de 1 y 3 argumentos y hasta con un fichero que no es un IRX: se
	-- congela antes de la inicializacion de video, sin mensaje.
	if IRX_CARGA_ACTIVA ~= true then
		boot_log("Build 2024: no se cargan IRX (Sif.loadModule cuelga en esta build).")
		boot_log("Sin ata_bd no hay disco interno, salvo que el lanzador lo dejase cargado.")
		sondear_bdm(antes)
		return
	end

	local hecho = {}
	boot_log("Carga de modulos IRX desde IRX/ :")
	for i = 1, #IRX_IGNORAR do hecho[IRX_IGNORAR[i]] = "ignorar" end

	-- IMPORTANTE: NO usar Sif.loadModule(ruta). Esa funcion hace que el IOP resuelva
	-- la ruta con su modulo LOADFILE, que usa el viejo "ioman". Pero "mass:" lo aporta
	-- bdmfs_fatfs, que se registra en "iomanX". El IOP no sabe abrir la ruta y la
	-- llamada RPC nunca vuelve: la consola se congela. Comprobado con cualquier
	-- fichero, incluso uno que no es un IRX, y en las builds de 2024 y de 2025.
	-- Solucion: leer el fichero desde el EE y enviar los bytes con loadModuleBuffer.
	local function cargar(nombre)
		local ruta = actual .."/IRX/".. nombre
		boot_log("-> ".. nombre)

		local okl, datos, tam = pcall(function()
			local fd = System.openFile(ruta, FREAD)
			local size = System.sizeFile(fd)
			System.seekFile(fd, 0, SET)
			local buf = System.readFile(fd, size)
			System.closeFile(fd)
			return buf, size
		end)

		if okl == false or datos == nil then
			boot_log("   ERROR de lectura: ".. tostring(datos))
			return
		end
		-- Parentesis obligatorios: string.byte("") no devuelve NINGUN valor (ni
		-- siquiera nil) y tostring() sin argumento es un error de ejecucion.
		boot_log("   leidos ".. tostring(tam) .." bytes, primer byte = ".. tostring((string.byte(datos, 1))) .." (127 = ELF valido)")

		local okc, ID = pcall(Sif.loadModuleBuffer, datos, tam)
		boot_log("   loadModuleBuffer ok=".. tostring(okc) .."  ID=".. tostring(ID))
	end

	for i = 1, #IRX_ORDEN do
		if doesFileExist(actual .."/IRX/".. IRX_ORDEN[i]) then
			cargar(IRX_ORDEN[i])
			hecho[string.lower(IRX_ORDEN[i])] = "hecho"
		end
	end

	local buscar_irx = System.listDirectory(actual.. "/IRX")
	if buscar_irx ~= nil and #buscar_irx >= 1 then
		for elementos = 1, #buscar_irx do
			local nombre = buscar_irx[elementos].name
			local clave = string.lower(nombre)
			if string.lower(string.sub(nombre, -4)) == ".irx" then
				if hecho[clave] == "ignorar" then
					boot_log("-- ignorado ".. nombre)
				elseif hecho[clave] == nil then
					cargar(nombre)
				end
			end
		end
	end

	if System.sleep ~= nil then System.sleep(1) end
	sondear_bdm(antes)
end
