-- Prism PS2 Launcher - emu/pops.lua
-- POPStarter: POPS/ roots, .VCD lookup, USB delay patch, MC drivers.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- PlayStation 1 / POPStarter. --------------------------------------------------------
--- POPStarter lee siempre el .VCD y escribe la tarjeta de memoria virtual en
--- "<unidad>/POPS/<nombre del juego>/", este donde este su ELF (por eso funciona el
--- montaje con el ELF en "APPS/"). Los .VCD viven SOLO en "POPS/", en la raiz de la
--- unidad: es el unico sitio donde POPStarter los busca. Las imagenes y los titulos de
--- PS1, sea cual sea el formato del juego, estan en "Roms/psx/", como en EmulationStation.

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

--- Ruta real del .VCD en el "POPS/" de cada unidad. nil si no esta en ninguna.
function RUTA_VCD(nombre)
	local u = POPS_UNIDADES()
	for i = 1, #u do
		if doesFileExist(u[i] .."/POPS/".. nombre) then
			return u[i] .."/POPS/".. nombre
		end
	end
	return nil
end

--- true si el .VCD esta en el "POPS/" de la unidad de POPStarter. Antes trasladaba el
--- fichero desde una biblioteca en "Roms/"; ya no hay biblioteca: o esta, o no esta.
function VCD_A_POPS(nombre)
	return doesFileExist(POPS_RAIZ .."/POPS/".. nombre)
end

--- Retardo de acceso al USB de POPStarter. -------------------------------------------
--- POPStarter da por perdido el dispositivo si tarda en responder, y entonces escribe
--- "Opening mass:/POPS/... FAILED / No POPS directory ? / Increase the USB access
--- delay". El valor vive en un solo byte de su tabla de configuracion, offset 0x413,
--- y hay que parchearlo en CADA "XX.<juego>.ELF": cada atajo es un POPStarter
--- completo. De fabrica vale 3, poco para muchas llaves. 0 = no tocar nada.
--- Con los drivers modernos en la Memory Card la llave monta rapido: 20 basta y no
--- alarga el arranque. Subir hacia 60 solo si volviera el fallo de montaje.
POPS_USB_DELAY = 20

--- Lee el byte del retardo, para poder ESCRIBIRLO EN EL JOURNAL: sin esto no hay
--- forma de saber si el parche se aplico de verdad. nil = fichero ilegible.
function LEE_USB_DELAY(ruta)
	local valor = nil
	pcall(function()
		local f = System.openFile(ruta, FREAD)
		System.seekFile(f, 0x413, SET)
		local b = System.readFile(f, 1)
		System.closeFile(f)
		if b ~= nil and string.len(b) >= 1 then valor = string.byte(b, 1) end
	end)
	return valor
end

function PARCHE_USB_DELAY(ruta)
	if POPS_USB_DELAY == nil or POPS_USB_DELAY <= 0 then return end
	if ruta == nil or doesFileExist(ruta) == false then return end
	pcall(function()
		local f = System.openFile(ruta, FRDWR)
		-- Comprobacion de firma: los bytes que rodean al retardo. El primero varia
		-- entre builds (0x00 en la Rev 13 principal, 0xFF en las "USBDELAY" de la
		-- comunidad); el resto del marco es estable.
		System.seekFile(f, 0x410, SET)
		local marco = System.readFile(f, 8)
		local b1 = (marco ~= nil and string.len(marco) >= 8) and string.byte(marco, 1) or -1
		if marco == nil or string.len(marco) < 8
		   or (b1 ~= 0 and b1 ~= 0xFF)
		   or string.byte(marco, 2) ~= 0 or string.byte(marco, 3) ~= 0
		   or string.byte(marco, 5) ~= 0x40 or string.byte(marco, 8) ~= 1 then
			System.closeFile(f)
			return
		end
		System.seekFile(f, 0x413, SET)
		System.writeFile(f, string.char(POPS_USB_DELAY), 1)
		System.closeFile(f)
	end)
end

--- Drivers USB de recambio de POPStarter, en la Memory Card. -------------------------
--- Hallazgo comprobado en esta consola: POPStarter solo monta ciertas llaves si
--- encuentra "mc0:/POPSTARTER/usbd.irx" y "usbhdfsd.irx" (BDMAssault) - y los nombres
--- van en MINUSCULAS, con mayusculas no los ve y cae en sus drivers internos de 2019,
--- que fallan con "Opening mass:/POPS/... FAILED".
--- Esta funcion REPARA la instalacion antes de cada lanzamiento: crea el directorio,
--- copia los ficheros que falten (desde SYS-CONF de la propia tarjeta, o desde un
--- POPSTARTER/ en cualquier raiz) y corrige el nombre si la caja no es la esperada.
--- Devuelve un texto multilinea para el journal de lanzamiento.
function POPSTARTER_DRIVERS_MC()
	local dir = "mc0:/POPSTARTER"
	local lineas = {"Drivers de recambio en ".. dir .." (minusculas obligatorias):"}

	local function listar()
		local reales = {}
		local c = System.listDirectory(dir)
		if c ~= nil then
			for i = 1, #c do
				if c[i].directory == false then
					reales[string.lower(c[i].name)] = c[i].name
				end
			end
		end
		return reales, (c ~= nil)
	end

	local reales, existe = listar()
	if existe == false then
		pcall(System.createDirectory, dir)
		reales, existe = listar()
		table.insert(lineas, "  directorio creado: ".. tostring(existe))
	end

	for _i, nombre in ipairs({"usbd.irx", "usbhdfsd.irx"}) do
		local real = reales[nombre]
		if real == nombre then
			table.insert(lineas, "  ".. nombre .." : ok")
		elseif real ~= nil then
			-- Mala caja. Renombrar directamente puede fallar en mcman cuando solo
			-- cambia la caja, asi que se pasa por un nombre intermedio.
			pcall(System.copyFile, dir .."/".. real, dir .."/fix.tmp")
			pcall(System.removeFile, dir .."/".. real)
			if System.rename ~= nil then
				pcall(System.rename, dir .."/fix.tmp", dir .."/".. nombre)
			end
			if listar()[nombre] ~= nombre then
				pcall(System.copyFile, dir .."/fix.tmp", dir .."/".. nombre)
				pcall(System.removeFile, dir .."/fix.tmp")
			end
			local ahora = listar()[nombre]
			table.insert(lineas, "  ".. nombre .." : renombrado desde '".. real .."' -> ".. tostring(ahora == nombre))
		else
			-- Ausente: copiar desde la primera fuente que exista.
			local fuentes = {"mc0:/SYS-CONF/".. string.upper(nombre),
				"mc0:/SYS-CONF/".. nombre}
			local pos = string.find(System.currentDirectory(), ":", 1, true)
			if pos ~= nil then
				local raiz = string.sub(System.currentDirectory(), 1, pos)
				table.insert(fuentes, raiz .."/POPSTARTER/".. string.upper(nombre))
				table.insert(fuentes, raiz .."/POPSTARTER/".. nombre)
			end
			if RAICES ~= nil then
				for r = 1, #RAICES do
					-- Los dos IRX se reparten con el lanzador, en la carpeta "IRX/" de la
					-- raiz. Se conserva la ruta historica detras, por si alguien los tiene
					-- ya colocados a la vieja usanza.
					table.insert(fuentes, RAICES[r] .."/IRX/".. nombre)
					table.insert(fuentes, RAICES[r] .."/Bios/POPSTARTER/".. nombre)
				end
			end
			local hecho = false
			for f = 1, #fuentes do
				if hecho == false and doesFileExist(fuentes[f]) then
					pcall(System.copyFile, fuentes[f], dir .."/".. nombre)
					hecho = (listar()[nombre] == nombre)
					if hecho then
						table.insert(lineas, "  ".. nombre .." : copiado desde ".. fuentes[f])
					end
				end
			end
			if hecho == false then
				table.insert(lineas, "  ".. nombre .." : AUSENTE y sin fuente para copiarlo.")
				table.insert(lineas, "    Sin el, POPStarter usa sus drivers de 2019 y")
				table.insert(lineas, "    puede no montar la llave USB.")
			end
		end
	end
	return table.concat(lineas, "\n")
end

--- Reinicio del IOP para POPStarter y Ember: NUNCA. ----------------------------------
--- Confirmado en hardware real y por el autor del proyecto: "restarting the IOP
--- causes the .ELF file to be lost, resulting in the game immediately closing and
--- returning to the PS2 menu". El reset descarga los drivers USB y el cargador ya no
--- puede leer el propio ELF que debe lanzar -> vuelta al menu de la consola.
--- El valor 1 fue una hipotesis de diagnostico para los VCD; el culpable real era el
--- retardo de acceso USB de POPStarter (POPS_USB_DELAY), no el estado del IOP.
IOP_REBOOT_POPS = 0
IOP_REBOOT_EMBER = 0
