-- Prism PS2 Launcher - core/drives.lua
-- IRX loading and BDM drive probing: which unit is the internal disk.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- Drive probing and USB / ATA classification. ----------------------------------------
--- "antes" is the snapshot of the drives taken BEFORE loading ata_bd: a drive that
--- was absent and is now present has been mounted by ata_bd, so it is the internal disk.
--- The other route is the marker, which works even if the drivers were already resident.
function sondear_bdm(antes)
	local actual = System.currentDirectory()
	local propio = ""
	local pos = string.find(actual, ":", 1, false)
	if pos ~= nil then propio = string.sub(actual, 1, pos) end
	boot_log("")
	boot_log("Drives detected (propio = ".. propio ..") :")
	for n = -1, 5 do
		local unidad = "mass:"
		if n >= 0 then unidad = "mass".. n ..":" end
		-- In the 2025 build "mass:" is an ALIAS of "mass0:": probing both duplicates
		-- the drive in BDM_DEVICES and from there in the search roots. "mass:" is only
		-- looked at when "mass0:" does not exist (2024 build).
		local contenido = nil
		if unidad == "mass:" and System.listDirectory("mass0:") ~= nil then
			boot_log("  mass:   alias of mass0: in this build, skipped")
		else
			contenido = System.listDirectory(unidad)
		end
		if contenido ~= nil then
			local texto = "  ".. unidad .."  OK  (".. #contenido .." entries)"
			for i = 1, math.min(#contenido, 30) do
				local marca = "   "
				if contenido[i].directory == true then marca = " d " end
				texto = texto .."\n      ".. marca .. contenido[i].name
			end
			if antes[unidad] ~= true then
				BDM_ATA[unidad] = true
				texto = texto .."\n      -> ATA (mounted by ata_bd, NOT a USB)"
			elseif doesFileExist(unidad .."/Prism".. MARCA_ATA) then
				BDM_ATA[unidad] = true
				texto = texto .."\n      -> ATA (internal disk marker present)"
			elseif unidad == BOOT_DEV and BOOT_ES_ATA == true then
				BDM_ATA[unidad] = true
				texto = texto .."\n      -> ATA (it is the boot device)"
			else
				texto = texto .."\n      -> USB"
			end
			boot_log(texto)
			if unidad ~= propio then table.insert(BDM_DEVICES, unidad) end
		else
			boot_log("  ".. unidad .."  not mounted")
		end
	end
	local mcs = {"mc0:", "mc1:"}
	for i = 1, #mcs do
		if System.listDirectory(mcs[i] .."/") ~= nil then
			boot_log("  ".. mcs[i] .."   OK (Memory Card)")
		else
			boot_log("  ".. mcs[i] .."   not accessible")
		end
	end
end

function irx_load()
	local actual = System.currentDirectory()

	-- Snapshot of the drives before touching anything.
	local antes = {}
	for n = -1, 5 do
		local u = "mass:"
		if n >= 0 then u = "mass".. n ..":" end
		if System.listDirectory(u) ~= nil then antes[u] = true end
	end

	-- The pre-boot (System/index.lua) has already loaded -or decided not to load- the IRX.
	-- Reloading an already registered driver hangs the console, so here the drives
	-- are only probed.
	if PREBOOT_IRX_HECHO == true then
		boot_log("Pre-boot detected (System/index.lua), origin: ".. tostring(PREBOOT_ORIGEN))
		boot_log("The IRX were already handled there: they are not reloaded.")
		sondear_bdm(antes)
		return
	end

	-- Booting FROM the internal disk: dev9 and ata_bd are necessarily resident,
	-- loaded by the launcher (wLaunchELF ISR or other) - without them this file could
	-- not have been read at all. Registering a driver twice hangs the console
	-- ("BDM: ERROR: Already registered!"), so NOTHING is loaded here.
	if BOOT_ES_ATA == true then
		boot_log("Booting from the internal disk: NO IRX is loaded.")
		boot_log("dev9/ata_bd are already resident (the launcher loaded them); reloading")
		boot_log("them would hang the console.")
		BDM_ATA[BOOT_DEV] = true
		sondear_bdm(antes)
		return
	end

	-- Build 2024: Sif.loadModule hangs the console on ANY call. Tested with both
	-- the 1 and 3 argument forms and even with a file that is not an IRX: it
	-- freezes before video initialisation, with no message.
	if IRX_CARGA_ACTIVA ~= true then
		boot_log("Build 2024: no IRX loaded (Sif.loadModule hangs in this build).")
		boot_log("Without ata_bd there is no internal disk, unless the launcher left it loaded.")
		sondear_bdm(antes)
		return
	end

	local hecho = {}
	boot_log("Loading IRX modules from IRX/ :")
	for i = 1, #IRX_IGNORAR do hecho[IRX_IGNORAR[i]] = "ignorar" end

	-- IMPORTANT: do NOT use Sif.loadModule(ruta). That function makes the IOP resolve
	-- the path with its LOADFILE module, which uses the old "ioman". But "mass:" comes
	-- from bdmfs_fatfs, which registers on "iomanX". The IOP cannot open the path and the
	-- RPC call never returns: the console freezes. Verified with any
	-- file, even one that is not an IRX, and on both the 2024 and the 2025 builds.
	-- Solution: read the file from the EE and send the bytes with loadModuleBuffer.
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
			boot_log("   READ ERROR: ".. tostring(datos))
			return
		end
		-- Parentheses are mandatory: string.byte("") returns NO value at all (not
		-- even nil) and tostring() with no argument is a runtime error.
		boot_log("   read ".. tostring(tam) .." bytes, first byte = ".. tostring((string.byte(datos, 1))) .." (127 = valid ELF)")

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
					boot_log("-- ignored ".. nombre)
				elseif hecho[clave] == nil then
					cargar(nombre)
				end
			end
		end
	end

	if System.sleep ~= nil then System.sleep(1) end
	sondear_bdm(antes)
end
