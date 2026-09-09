-- Prism PS2 Launcher - emu/retroarch_shuttle.lua
-- RetroArch on the USB shuttle: core and ROM copy, saves bridge.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- Transbordo de ROM para los cores de RetroArch. ------------------------------------
--- Los cores montan SU PROPIA pila de dispositivos al arrancar, y ahi no hay ata_bd:
--- "platform_ps2.c" solo inicializa memcard, usb, mx4sio, cdfs y el HDD nativo (APA).
--- Conclusion: una ROM que vive en el disco interno exFAT les es SIMPLEMENTE INVISIBLE.
--- No es un fallo del launcher ni de las rutas, es el alcance del port de RetroArch.
--- Solucion: copiar la ROM a un soporte que ellos si lean, por orden de preferencia
--- USB (rapido) y luego Memory Card (lenta y pequena, pero suficiente para 8/16 bits).
--- La copia se cachea: relanzar el mismo juego no vuelve a copiar.
--- Poner a false para desactivar el transbordo.
ROM_SHUTTLE_ON = true
--- Carpeta de paso en el soporte de transbordo. Misma forma que en el disco:
---   <soporte>/Prism/Roms/<consola>/<rom>
---   <soporte>/Prism/Saves/<consola>/<juego>.srm
---   <soporte>/Prism/SaveStates/<consola>/<juego>.state
---   <soporte>/Prism/Bios/
---   <soporte>/Prism/LibretroPS2Files/
---
--- O sea: EXACTAMENTE la misma estructura que en el disco interno. Hubo aqui una
--- carpeta "TempUSB/" en medio, y era un parche a un problema que ya no existe --
--- RUTA_LIBRETRO elegia la copia de trabajo como instalacion maestra, y esconderla
--- bajo otro nombre lo evitaba. Ahora la maestra se reconoce por estar junto al
--- lanzador (libretro_master_path), asi que la copia puede volver a su sitio y las
--- dos mitades del montaje se leen igual.
-- Del nombre REAL de la carpeta del lanzador, no del literal "Prism": si
-- alguien la renombra, el transbordo y la instalacion que se copia a su lado tienen
-- que seguir cayendo en el mismo sitio. CARPETA_LANZADOR se calcula al arrancar.
ROM_SHUTTLE_SUB = "/".. CARPETA_LANZADOR

function ROM_TAMANO(ruta)
	local tam = nil
	pcall(function()
		local f = System.openFile(ruta, FREAD)
		tam = System.sizeFile(f)
		System.closeFile(f)
	end)
	return tam
end

--- Soportes legibles por los cores, del mas rapido al mas lento. ---------------------
function ROM_DESTINOS()
	local out = {}
	local propio = ""
	local pos = string.find(System.currentDirectory(), ":", 1, true)
	if pos ~= nil then propio = string.sub(System.currentDirectory(), 1, pos) end
	-- El soporte de arranque, si no es el disco ATA (o sea: si es un USB).
	if propio ~= "" and BDM_ATA[propio] ~= true then table.insert(out, propio) end
	if BDM_DEVICES ~= nil then
		for i = 1, #BDM_DEVICES do
			if BDM_ATA[BDM_DEVICES[i]] ~= true and BDM_DEVICES[i] ~= propio then
				table.insert(out, BDM_DEVICES[i])
			end
		end
	end
	table.insert(out, "mc0:")
	table.insert(out, "mc1:")
	return out
end

--- Copia la ROM a un soporte legible. Devuelve (ruta_nueva, descripcion).
--- La Memory Card tiene 8 MB: una ROM de GBA no cabra, y hay que decirlo claro.
--- El numero de orden en la lista, guardado aparte. -----------------------------------
--- "System/Config/System.cfg" es una linea de cuarenta y nueve numeros releidos por
--- posicion, y una de las casillas guarda una RUTA. El lector extrae numeros con
--- "%d+": si esa ruta trae un digito de mas o de menos, TODO lo que viene detras se
--- lee corrido. Un interruptor de si/no no tiene por que depender de eso, asi que
--- vive en su propio fichero de un caracter.
function see_index_path()
	return System.currentDirectory() .."/System/Config/SeeIndex.cfg"
end

function see_index_load()
	local f = see_index_path()
	if doesFileExist(f) == false then return nil end
	local v = nil
	pcall(function()
		local h = System.openFile(f, FREAD)
		System.seekFile(h, 0, SET)
		local t = System.readFile(h, System.sizeFile(h))
		System.closeFile(h)
		if t ~= nil and string.find(t, "1", 1, true) ~= nil then v = 1 else v = 0 end
	end)
	return v
end

function see_index_save(valor)
	pcall(function()
		local t = tostring(valor)
		local h = System.openFile(see_index_path(), FCREATE)
		System.writeFile(h, t, string.len(t))
		System.closeFile(h)
	end)
end

--- Que ROMs estan YA en la llave. -----------------------------------------------------
--- Para pintarlas en verde en la lista: verde = no hay nada que copiar, arranca ya.
--- Una sola llamada a listDirectory por sistema, y solo cuando se cambia de sistema.
--- La carpeta guarda una ROM cada vez, asi que el indice es de un elemento.
CACHE_USB_IDX = nil
CACHE_USB_ID = nil

function usb_cache_refresh(identidad)
	CACHE_USB_ID = identidad
	CACHE_USB_IDX = {}
	-- Sin puente no hay copia que evitar: nada esta "en cache", todo arranca igual.
	if PUENTE_HACE_FALTA() == false then return end
	local consola = ROMS_DIR[identidad]
	if consola == nil then return end
	local destinos = ROM_DESTINOS()
	for i = 1, #destinos do
		local c = System.listDirectory(destinos[i] .. ROM_SHUTTLE_SUB .."/Roms/".. consola)
		if c ~= nil then
			for j = 1, #c do
				if c[j].directory == false then CACHE_USB_IDX[c[j].name] = true end
			end
		end
	end
end

--- Que cores estan YA en la llave. Mismo principio que usb_cached, y un solo
--- listado: la carpeta lleva a lo sumo un punado de cores.
CORES_LLAVE_IDX = nil

function core_on_usb(nombre_core)
	if nombre_core == nil then return false end
	if CORES_LLAVE_IDX == nil then
		CORES_LLAVE_IDX = {}
		local destinos = ROM_DESTINOS()
		for i = 1, #destinos do
			if string.lower(string.sub(destinos[i], 1, 4)) == "mass" then
				local dir = destinos[i] .."/".. CARPETA_LANZADOR .."/LibretroPS2Files/cores"
				local c = System.listDirectory(dir)
				if c ~= nil then
					for j = 1, #c do
						if c[j].directory == false then CORES_LLAVE_IDX[c[j].name] = true end
					end
				end
			end
		end
	end
	return CORES_LLAVE_IDX[nombre_core] == true
end

function usb_cached(identidad, nombre)
	if nombre == nil or identidad == nil or identidad > 12 then return false end
	if CACHE_USB_ID ~= identidad then usb_cache_refresh(identidad) end
	if CACHE_USB_IDX == nil then return false end
	-- El rastreo anade un espacio al final para las extensiones de tres letras.
	local limpio = nombre
	while string.sub(limpio, -1) == " " do limpio = string.sub(limpio, 1, -2) end
	return CACHE_USB_IDX[limpio] == true
end

--- Copia por trozos, con progreso. ----------------------------------------------------
--- "System.copyFile" no dice nada mientras trabaja, y en USB 1.1 -- 1 MB/s en el mejor
--- de los casos -- una ROM de Game Boy Advance son quince segundos de pantalla quieta,
--- indistinguibles de un cuelgue. Aqui se copia a trozos y se avisa entre trozo y
--- trozo. El trozo es grande a proposito: en USB 1.1 lo que cuesta es la latencia por
--- transferencia, no los bytes.
COPIA_TROZO = 262144

function copy_with_progress(origen, destino, etiqueta)
	local tam = ROM_TAMANO(origen)
	if tam == nil then return false end
	-- Por debajo de un trozo no hay nada que mostrar: copia directa.
	if tam <= COPIA_TROZO then
		local ok = pcall(System.copyFile, origen, destino)
		return ok == true and doesFileExist(destino)
	end
	local hechos = 0
	pcall(function()
		local fo = System.openFile(origen, FREAD)
		local fd = System.openFile(destino, FCREATE)
		System.seekFile(fo, 0, SET)
		while hechos < tam do
			local n = COPIA_TROZO
			if tam - hechos < n then n = tam - hechos end
			local datos = System.readFile(fo, n)
			if datos == nil then break end
			local largo = string.len(datos)
			if largo <= 0 then break end
			System.writeFile(fd, datos, largo)
			hechos = hechos + largo
			if copy_progress ~= nil then
				pcall(copy_progress, etiqueta, hechos, tam)
			end
		end
		System.closeFile(fd)
		System.closeFile(fo)
	end)
	return hechos >= tam
end

function ROM_TRANSBORDO(ruta_rom, nombre)
	if ROM_SHUTTLE_ON ~= true then return nil, "transbordo desactivado" end
	local tam = ROM_TAMANO(ruta_rom)
	if tam == nil then return nil, "ROM ilegible en el origen" end
	-- Nombre de la carpeta que contiene la ROM: "Roms/megadrive/juego.gen" -> "megadrive".
	-- La copia lo conserva porque RetroArch agrupa las partidas por ese nombre
	-- ("sort_savefiles_by_content_enable"). Sin esto, un juego transbordado guardaria
	-- en "Saves/Prism-TMP" en vez de "Saves/megadrive", y sus partidas
	-- quedarian separadas de las del mismo juego lanzado desde un USB.
	local consola = CARPETA_DE_RUTA(ruta_rom)

	local destinos = ROM_DESTINOS()
	for i = 1, #destinos do
		-- Bajo "Roms/", igual que en el disco. Estaban sueltas en la raiz de la
		-- carpeta de paso, mezcladas con Saves y SaveStates.
		local raiz_tmp = destinos[i] .. ROM_SHUTTLE_SUB .."/Roms"
		local sufijo = string.sub(ROM_SHUTTLE_SUB, 2) .."/Roms"
		if consola ~= nil then sufijo = sufijo .."/".. consola end
		pcall(CREAR_CADENA, destinos[i], sufijo)
		local dir = raiz_tmp
		if consola ~= nil then dir = raiz_tmp .."/".. consola end
		local contenido = System.listDirectory(dir)
		if contenido ~= nil then
			local dest = dir .."/".. nombre
			-- Cache: si ya esta ahi con el tamano correcto, no se recopia.
			if doesFileExist(dest) and ROM_TAMANO(dest) == tam then
				return dest, destinos[i] .." (ya en cache)"
			end
			-- Solo se guarda UNA ROM: se limpia lo anterior para no llenar el soporte.
			-- Hay que barrer TODAS las carpetas de consola, no solo la actual, o al
			-- cambiar de sistema se acumularian las ROMs anteriores. Ahora "raiz_tmp"
			-- es "Roms/", asi que aqui dentro solo hay ROMs: no hay nada que excluir.
			local previo = System.listDirectory(raiz_tmp)
			if previo ~= nil then
				for c = 1, #previo do
					local nom = previo[c].name
					if nom ~= "." and nom ~= ".." then
						if previo[c].directory == false then
							pcall(System.removeFile, raiz_tmp .."/".. nom)
						else
							local dentro = System.listDirectory(raiz_tmp .."/".. nom)
							if dentro ~= nil then
								for d = 1, #dentro do
									if dentro[d].directory == false then
										pcall(System.removeFile, raiz_tmp .."/".. nom .."/".. dentro[d].name)
									end
								end
							end
						end
					end
				end
			end
			copy_with_progress(ruta_rom, dest, "ROM")
			if doesFileExist(dest) and ROM_TAMANO(dest) == tam then
				return dest, destinos[i] .." (copiada, ".. tostring(tam) .." bytes)"
			end
			pcall(System.removeFile, dest)
		end
	end
	return nil, "ningun soporte legible con espacio (ROM de ".. tostring(tam) .." bytes)"
end

--- Puente de partidas entre el disco interno y el soporte de transbordo. -------------
--- Un core oficial no sabe leer el disco interno, asi que la ROM se le copia a la
--- llave USB. Sus partidas se escriben entonces TAMBIEN en la llave, y quedarian
--- desperdigadas ahi. El puente hace el viaje de vuelta:
---
---   antes de lanzar   la partida de ESTE juego sale del disco hacia la llave
---   el core juega     escribe en la llave, sin saber que hay un disco
---   al volver         el lanzador recoge todo lo escrito y lo devuelve al disco
---
--- Asi el disco sigue siendo el domicilio de las partidas y la llave solo un pasillo.
--- Sin el paso de ida, un juego arrancaria en blanco y machacaria lo guardado.
--- Todo esto solo se activa cuando el lanzador vive en el disco interno: en una llave
--- o en una tarjeta, las partidas ya estan donde el core las escribe.
SAVES_PUENTE_ON = true
SAVES_CARPETAS = {"Saves", "SaveStates"}

--- Crea una ruta completa, componente a componente. ---------------------------------
--- "System.createDirectory" no crea los padres, y la carpeta de paso tiene ahora dos
--- niveles ("Prism/Roms") mas la consola debajo.
function CREAR_CADENA(base, resto)
	if base == nil or resto == nil then return false end
	local ruta = base
	local desde = 1
	while true do
		local corte = string.find(resto, "/", desde, true)
		local trozo = nil
		if corte == nil then trozo = string.sub(resto, desde)
		else trozo = string.sub(resto, desde, corte-1) end
		if trozo ~= nil and trozo ~= "" then
			ruta = ruta .."/".. trozo
			if System.listDirectory(ruta) == nil then
				System.createDirectory(ruta)
				if System.listDirectory(ruta) == nil then return false end
			end
		end
		if corte == nil then break end
		desde = corte + 1
	end
	return true
end

--- Nombre de la carpeta que contiene un fichero: ".../Roms/gb/Tetris.zip" -> "gb". ---
function CARPETA_DE_RUTA(ruta)
	if ruta == nil then return nil end
	local fin = string.len(ruta)
	while fin > 0 and string.sub(ruta, fin, fin) ~= "/" do fin = fin - 1 end
	if fin <= 1 then return nil end
	local ini = fin - 1
	while ini > 0 and string.sub(ruta, ini, ini) ~= "/" do ini = ini - 1 end
	local n = string.sub(ruta, ini+1, fin-1)
	if n == "" or string.find(n, ":", 1, true) ~= nil then return nil end
	return n
end

--- Nombre de un fichero sin su extension: "Tetris (World).zip" -> "Tetris (World)". --
function SIN_EXTENSION(nombre)
	if nombre == nil then return nil end
	local punto = string.len(nombre)
	while punto > 0 and string.sub(nombre, punto, punto) ~= "." do punto = punto - 1 end
	if punto > 1 then return string.sub(nombre, 1, punto-1) end
	return nombre
end

--- Prefijo de unidad de una ruta: "mass0:/x/y" -> "mass0:". --------------------------
function DEV_DE_RUTA(ruta)
	if ruta == nil then return nil end
	local pos = string.find(ruta, ":", 1, true)
	if pos == nil then return nil end
	return string.sub(ruta, 1, pos)
end

--- Copia un arbol de ficheros, creando los directorios que falten. --------------------
--- "System.createDirectory" no crea los padres, de ahi la recursion en orden.
--- El limite de profundidad evita que un enlace raro cuelgue la consola.
function COPIAR_ARBOL(origen, destino, nivel)
	if nivel == nil then nivel = 0 end
	if nivel > 4 then return end
	local lista = System.listDirectory(origen)
	if lista == nil then return end
	if System.listDirectory(destino) == nil then
		System.createDirectory(destino)
	end
	for i = 1, #lista do
		local nom = lista[i].name
		if nom ~= "." and nom ~= ".." then
			if lista[i].directory == true then
				COPIAR_ARBOL(origen .."/".. nom, destino .."/".. nom, nivel + 1)
			else
				System.copyFile(origen .."/".. nom, destino .."/".. nom)
			end
		end
	end
end
--- Vacia un arbol de ficheros. El reverso de COPIAR_ARBOL. ---------------------------
--- Las carpetas se quedan, vacias: Enceladus expone "System.removeFile" pero no el
--- equivalente para directorios. No es un problema -- una carpeta vacia no estorba, y
--- "directorios_faltantes" cuenta justamente con que existan.
function BORRAR_ARBOL(ruta, nivel)
	if nivel == nil then nivel = 0 end
	if nivel > 4 then return end
	local lista = System.listDirectory(ruta)
	if lista == nil then return end
	for i = 1, #lista do
		local nom = lista[i].name
		if nom ~= "." and nom ~= ".." then
			if lista[i].directory == true then
				BORRAR_ARBOL(ruta .."/".. nom, nivel + 1)
			else
				pcall(System.removeFile, ruta .."/".. nom)
			end
		end
	end
end

--- Copia los ficheros de un directorio a otro. Devuelve cuantos. ---------------------
function COPIAR_PLANO(origen, destino, borrar)
	local lista = System.listDirectory(origen)
	if lista == nil then return 0 end
	if System.listDirectory(destino) == nil then System.createDirectory(destino) end
	if System.listDirectory(destino) == nil then return 0 end
	local n = 0
	for i = 1, #lista do
		if lista[i].directory == false then
			local ok = pcall(System.copyFile, origen .."/".. lista[i].name, destino .."/".. lista[i].name)
			if ok == true and doesFileExist(destino .."/".. lista[i].name) then
				n = n + 1
				if borrar == true then pcall(System.removeFile, origen .."/".. lista[i].name) end
			end
		end
	end
	return n
end

--- El lanzador vive en el disco interno? Solo entonces hace falta el puente. ----------
function PUENTE_HACE_FALTA()
	if SAVES_PUENTE_ON ~= true then return false end
	return ES_RAIZ_ATA(System.currentDirectory() .."/Saves")
end

--- IDA: saca del disco las partidas de un juego hacia el soporte de transbordo. ------
--- "consola" es la carpeta de ROMs ("gb", "nes"...), "base" el nombre del juego sin
--- extension. RetroArch nombra la partida como la ROM: "Tetris.zip" -> "Tetris.srm",
--- y los save states anaden un sufijo ("Tetris.state", "Tetris.state1"...). Por eso
--- se copia todo lo que EMPIEZA por el nombre del juego, no solo una extension.
function SAVES_DESPLEGAR(dev, consola, base)
	if PUENTE_HACE_FALTA() == false or dev == nil or base == nil then return 0 end
	local actual = System.currentDirectory()
	local n = 0
	for c = 1, #SAVES_CARPETAS do
		local origen = actual .."/".. SAVES_CARPETAS[c]
		local destino = dev .. ROM_SHUTTLE_SUB .."/".. SAVES_CARPETAS[c]
		if consola ~= nil then
			origen = origen .."/".. consola
			destino = destino .."/".. consola
		end
		local lista = System.listDirectory(origen)
		if lista ~= nil then
			local sufijo = string.sub(ROM_SHUTTLE_SUB, 2) .."/".. SAVES_CARPETAS[c]
			if consola ~= nil then sufijo = sufijo .."/".. consola end
			CREAR_CADENA(dev, sufijo)
			for i = 1, #lista do
				local nom = lista[i].name
				if lista[i].directory == false and string.sub(nom, 1, string.len(base)) == base then
					local ok = pcall(System.copyFile, origen .."/".. nom, destino .."/".. nom)
					if ok == true then n = n + 1 end
				end
			end
		end
	end
	return n
end

--- Ficheros sueltos: se les busca su consola antes de traerlos. -----------------------
--- "Zelda.state1" no dice de que sistema es, pero "Roms/<consola>/Zelda.*" si. Se
--- recorre ROMS_DIR buscando una ROM cuyo nombre sin extension coincida; si aparece,
--- la partida va a "<carpeta>/<consola>/", que es donde habria caido con la ordenacion
--- por contenido activa. Si no aparece, se queda en la raiz como antes.
function saves_relocate(origen, casa)
	local lista = System.listDirectory(origen)
	if lista == nil then return 0 end
	local actual = System.currentDirectory()
	local n = 0
	for i = 1, #lista do
		if lista[i].directory == false then
			local nom = lista[i].name
			local base = SIN_EXTENSION(nom)
			local consola = nil
			-- Los estados anaden un sufijo al nombre completo de la ROM:
			-- "Zelda.zip" -> "Zelda.state1", asi que hay que quitar DOS extensiones.
			local base2 = SIN_EXTENSION(base)
			for c = 1, #ROMS_DIR do
				if consola == nil then
					local dir = actual .."/Roms/".. ROMS_DIR[c]
					local roms = System.listDirectory(dir)
					if roms ~= nil then
						for r = 1, #roms do
							if roms[r].directory == false then
								local rb = SIN_EXTENSION(roms[r].name)
								if rb == base or rb == base2 then consola = ROMS_DIR[c] end
							end
						end
					end
				end
			end
			local destino = casa
			if consola ~= nil then
				destino = casa .."/".. consola
				if System.listDirectory(destino) == nil then
					System.createDirectory(destino)
				end
			end
			local ok = pcall(System.copyFile, origen .."/".. nom, destino .."/".. nom)
			if ok == true and doesFileExist(destino .."/".. nom) then
				n = n + 1
				pcall(System.removeFile, origen .."/".. nom)
				if consola ~= nil then
					boot_log("SAVES  ".. nom .." -> ".. consola .."/ (estaba suelto)")
				end
			end
		end
	end
	return n
end

--- VUELTA: recoge lo que los cores han escrito en los soportes y lo devuelve al disco.
--- Se llama al arrancar el lanzador, que es justo cuando se vuelve de un juego.
--- La copia del soporte SIEMPRE gana: acaba de escribirla el core, y la API Lua de PS2
--- no expone la fecha de un fichero, asi que no hay otra forma de decidir.
function SAVES_RECUPERAR()
	if PUENTE_HACE_FALTA() == false then return 0 end
	local actual = System.currentDirectory()
	local destinos = ROM_DESTINOS()
	local total = 0
	for d = 1, #destinos do
		for c = 1, #SAVES_CARPETAS do
			local raiz = destinos[d] .. ROM_SHUTTLE_SUB .."/".. SAVES_CARPETAS[c]
			if System.listDirectory(raiz) ~= nil then
				local casa = actual .."/".. SAVES_CARPETAS[c]
				if System.listDirectory(casa) == nil then System.createDirectory(casa) end
				-- Sueltos en la raiz. Pasa cuando un override de core desactiva la
				-- ordenacion por carpeta de contenido -- es lo que le ocurrio a Zelda
				-- DX, cuyo ".srm" cayo en "Saves/gbc/" y sus estados en la raiz de
				-- "SaveStates/". En vez de traerlos sueltos al disco, se busca a que
				-- consola pertenece cada uno preguntando por la ROM en "Roms/", y se
				-- guardan donde deberian haber estado.
				total = total + saves_relocate(raiz, casa)
				-- Y una carpeta por consola.
				local subs = System.listDirectory(raiz)
				if subs ~= nil then
					for i = 1, #subs do
						local nom = subs[i].name
						if subs[i].directory == true and nom ~= "." and nom ~= ".." then
							total = total + COPIAR_PLANO(raiz .."/".. nom, casa .."/".. nom, true)
						end
					end
				end
			end
		end
	end
	if total > 0 then
		boot_log("SAVES  ".. tostring(total) .." partida(s) devueltas al disco interno")
		boot_flush()
	end
	return total
end
