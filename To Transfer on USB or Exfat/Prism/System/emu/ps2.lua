-- Prism PS2 Launcher - emu/ps2.lua
-- PlayStation 2: per-game launcher choice, virtual memory cards.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- VMC (tarjeta de memoria virtual) por juego para PS2 / Neutrino. -------------------
--- Una sola tarjeta compartida -y peor, una de 64 MB- es justo lo que corrompe las
--- partidas: muchos juegos rechazan o danan tarjetas de mas de 8 MB, y una tarjeta
--- unica deja que un juego pise los datos de otro. La cura es una tarjeta de 8 MB POR
--- JUEGO, que ademas es lo que Neutrino espera (-mc0=<fichero>).
--- El launcher no sabe formatear una tarjeta PS2 en Lua (formato con ECC/FAT), asi que
--- lleva un molde vacio ya formateado, "Bios/vmc-template.bin" (8 MB raw), y lo COPIA
--- a "VMC/<ID>.bin" la primera vez que se lanza el juego. Neutrino la rellena luego.
--- Poner a false para volver al comportamiento clasico (tarjeta manual o real).
VMC_AUTO_ON = true

--- Con que se lanza cada ISO de PS2: Neutrino o OPL. ---------------------------------
--- Se guarda por juego en "System/Config/Launcher.cfg", una linea "<fichero>=opl".
--- Solo se anota lo que se aparta de la norma: sin linea, Neutrino.
---
--- La eleccion existia ya, pero habia que MANTENER CRUZ+CIRCULO al lanzar, o poner
--- RUN_DEFAULT a 1 para que preguntara en cada juego. Ninguna de las dos se descubre
--- sola, y una combinacion de botones no es un ajuste.
LAUNCHER_GAMES = {}
launcher_cfg_loaded = false

function launcher_cfg_path()
	return System.currentDirectory() .."/System/Config/Launcher.cfg"
end

function launcher_cfg_load()
	if launcher_cfg_loaded == true then return end
	launcher_cfg_loaded = true
	local f = launcher_cfg_path()
	if doesFileExist(f) == false then return end
	pcall(function()
		local h = System.openFile(f, FREAD)
		System.seekFile(h, 0, SET)
		local t = System.readFile(h, System.sizeFile(h))
		System.closeFile(h)
		if t == nil then return end
		for linea in string.gmatch(t .."\n", "([^\n]*)\n") do
			local clave, valor = string.match(linea, "^([^=]+)=(.*)$")
			if clave ~= nil then
				valor = string.gsub(valor, "%s+$", "")
				if valor ~= "" then LAUNCHER_GAMES[clave] = valor end
			end
		end
	end)
end

function launcher_cfg_save()
	pcall(function()
		local t = ""
		for juego, valor in pairs(LAUNCHER_GAMES) do
			t = t .. juego .."=".. valor .."\n"
		end
		local h = System.openFile(launcher_cfg_path(), FCREATE)
		System.writeFile(h, t, string.len(t))
		System.closeFile(h)
	end)
end

--- True si ESTE juego debe lanzarse con OPL en vez de Neutrino. -----------------------
function launcher_is_opl(nombre)
	if nombre == nil then return false end
	launcher_cfg_load()
	return LAUNCHER_GAMES[nombre] == "opl"
end

--- Tarjeta virtual: UN solo ajuste, por juego, sin ambiguedad. -----------------------
--- "System/Config/VMC.cfg" guarda una linea por juego, "<ID>=<valor>", donde el valor
--- es una de estas tres cosas:
---
---   (ausente)               automatico -- se busca una tarjeta cuyo nombre empiece
---                           por el ID, en el VMC de CADA unidad montada; si no hay
---                           ninguna, se crea en la unidad de la ISO.
---   none                    ningun "-mc0=": Neutrino usa las tarjetas REALES.
---   mass1:/VMC/xxx.bin      esa tarjeta y ninguna otra.
---
--- Habia aqui un ajuste global "donde crear las tarjetas" ademas de esto, y un segundo
--- selector de fichero que duplicaba el de Boon. Tres formas de decidir la misma cosa,
--- ninguna de las cuales decia que fichero se iba a usar de verdad. Queda una.
VMC_GAMES = {}
vmc_cfg_loaded = false

function vmc_cfg_path()
	return System.currentDirectory() .."/System/Config/VMC.cfg"
end

function vmc_cfg_load()
	if vmc_cfg_loaded == true then return end
	vmc_cfg_loaded = true
	local f = vmc_cfg_path()
	if doesFileExist(f) == false then return end
	pcall(function()
		local h = System.openFile(f, FREAD)
		System.seekFile(h, 0, SET)
		local t = System.readFile(h, System.sizeFile(h))
		System.closeFile(h)
		if t == nil then return end
		for linea in string.gmatch(t .."\n", "([^\n]*)\n") do
			local clave, valor = string.match(linea, "^([^=]+)=(.*)$")
			if clave ~= nil then
				clave = string.gsub(clave, "%s+$", "")
				valor = string.gsub(valor, "%s+$", "")
				if valor ~= "" then VMC_GAMES[clave] = valor end
			end
		end
	end)
end

function vmc_cfg_save()
	pcall(function()
		local t = ""
		for id, valor in pairs(VMC_GAMES) do
			t = t .. id .."=".. valor .."\n"
		end
		local h = System.openFile(vmc_cfg_path(), FCREATE)
		System.writeFile(h, t, string.len(t))
		System.closeFile(h)
	end)
end

--- Las unidades donde puede vivir una carpeta VMC. ------------------------------------
function vmc_drives()
	local out, vistos = {}, {}

	local function anadir(dev)
		if dev == nil or vistos[dev] == true then return end
		if string.lower(string.sub(dev, 1, 4)) ~= "mass" then return end
		vistos[dev] = true
		out[#out + 1] = dev
	end

	-- EL SOPORTE DE ARRANQUE PRIMERO, y es todo el problema que habia aqui.
	--
	-- "BDM_DEVICES" no contiene la unidad desde la que corre el lanzador: se llena con
	-- "if unidad ~= propio then table.insert(...)". Recorrerla sola dejaba fuera
	-- justamente el disco donde esta el lanzador -- y donde estan las tarjetas. De ahi
	-- que no se encontrara ninguna VMC, y que ni siquiera se ofreciera crearla en el
	-- disco interno. El resto del programa ya lo hacia bien: RUTA_ART anade la unidad
	-- propia antes de recorrer BDM_DEVICES.
	local actual = System.currentDirectory()
	local pos = string.find(actual, ":", 1, true)
	if pos ~= nil then anadir(string.sub(actual, 1, pos)) end

	if BDM_DEVICES ~= nil then
		for i = 1, #BDM_DEVICES do anadir(BDM_DEVICES[i]) end
	end
	return out
end

--- Las formas en que un mismo ID puede estar escrito en un nombre de fichero. --------
--- "SLES-51191" es la convencion de las tarjetas, "SLES_511.91" la de las ISO de OPL,
--- y por el camino aparecen las dos con el otro separador. Comparar con una sola forma
--- es lo que dejaba la lista vacia aunque la carpeta tuviera las tarjetas delante.
function vmc_id_variants(id)
	if id == nil then return {} end
	local reg, num = string.match(id, "^(%a%a%a%a)%-(%d%d%d%d%d)")
	if reg == nil then return {string.lower(id)} end
	local n3, n2 = string.sub(num, 1, 3), string.sub(num, 4, 5)
	return {string.lower(reg .."-".. num),        -- SLES-51191
	        string.lower(reg .."_".. num),        -- SLES_51191
	        string.lower(reg .."_".. n3 ..".".. n2),   -- SLES_511.91
	        string.lower(reg .."-".. n3 ..".".. n2),   -- SLES-511.91
	        string.lower(reg .. num)}             -- SLES51191
end

--- TODAS las tarjetas de TODAS las unidades. -----------------------------------------
--- Las que parecen ser de este juego van primero; las demas van detras en vez de
--- desaparecer. Una lista vacia frente a una carpeta llena no informa de nada, y
--- ademas hay quien nombra sus tarjetas a mano, sin ningun ID.
--- Devuelve dos tablas: rutas, y si cada una corresponde al juego.
function vmc_candidates(id)
	local propias, otras = {}, {}
	local variantes = vmc_id_variants(id)
	local unidades = vmc_drives()
	for i = 1, #unidades do
		local dir = unidades[i] .."/VMC"
		local c = System.listDirectory(dir)
		if c ~= nil then
			for j = 1, #c do
				local n = c[j].name
				if c[j].directory == false and string.lower(string.sub(n, -4)) == ".bin" then
					local nlow = string.lower(n)
					local mio = false
					-- El ID puede estar en CUALQUIER parte del nombre, no solo al
					-- principio. "SCES-50295 Dark Cloud Data (Europe).bin" empieza por
					-- el ID, pero "Dark Cloud SCES-50295.bin" no, y es la misma partida.
					-- Comparar solo el principio dejaba fuera la mitad de las tarjetas
					-- nombradas a mano.
					for v = 1, #variantes do
						if string.find(nlow, variantes[v], 1, true) ~= nil then
							mio = true
						end
					end
					if mio then propias[#propias + 1] = dir .."/".. n
					else otras[#otras + 1] = dir .."/".. n end
				end
			end
		end
	end
	local todas = {}
	for i = 1, #propias do todas[#todas + 1] = propias[i] end
	for i = 1, #otras do todas[#todas + 1] = otras[i] end
	return todas, #propias
end

--- Crea una tarjeta vacia de 8 MB y devuelve su ruta, o nil. --------------------------
--- "fichero" es el nombre COMPLETO con su ".bin". Antes se recibia el ID y se le
--- pegaba la extension aqui, lo que impedia elegir el nombre desde el menu.
function vmc_create(dev, fichero)
	if dev == nil or fichero == nil then return nil end
	local dir = dev .."/VMC"
	if System.listDirectory(dir) == nil then pcall(System.createDirectory, dir) end
	if System.listDirectory(dir) == nil then return nil end
	local dest = dir .."/".. fichero
	if doesFileExist(dest) then return dest end
	local molde = RUTA_BIOS("vmc-template.bin", "")
	if doesFileExist(molde) == false then return nil end
	pcall(System.copyFile, molde, dest)
	if doesFileExist(dest) then return dest end
	return nil
end

--- ID normalizado del juego a partir del nombre del fichero de la ISO. ----------------------------
--- "SCES_502.40.Extermination.iso" -> "SCES-50240", la convencion de OPL y de las
--- carpetas de guardado. nil si el nombre no lleva un ID reconocible.
function vmc_id(nombre)
	if nombre == nil then return nil end
	local reg, n1, n2 = string.match(nombre, "^(%a%a%a%a)_(%d%d%d)%.(%d%d)")
	if reg ~= nil then return reg .."-".. n1 .. n2 end
	-- variante con guion o sin punto: "SLES-51044", "SLUS_20946"
	local reg2, num = string.match(nombre, "^(%a%a%a%a)[_%- ]?(%d%d%d%d%d)")
	if reg2 ~= nil then return reg2 .."-".. num end
	return nil
end

--- El ID tal y como lo escribe OPL: "SCES_502.95". ------------------------------------
--- Es la forma que llevan las ISO, y la que se usa para bautizar una tarjeta nueva, de
--- modo que el nombre del fichero se parezca al del juego que tiene al lado.
function vmc_id_opl(nombre)
	local id = vmc_id(nombre)
	if id == nil then return nil end
	local reg, num = string.match(id, "^(%a%a%a%a)%-(%d%d%d%d%d)")
	if reg == nil then return id end
	return reg .."_".. string.sub(num, 1, 3) ..".".. string.sub(num, 4, 5)
end

--- El titulo que va detras del ID en el nombre de la ISO. -----------------------------
--- "SCES_502.95.Dark Cloud.iso" -> "Dark Cloud". Devuelve "" si no se reconoce nada,
--- y en ese caso la tarjeta se queda solo con el ID y el numero.
function vmc_title(nombre)
	if nombre == nil then return "" end
	local t = nombre
	t = string.gsub(t, "%.[Ii][Ss][Oo]$", "")
	t = string.gsub(t, "^%a%a%a%a[_%- ]?%d%d%d%.?%d%d%.?", "")
	t = string.gsub(t, "^%s+", "")
	t = string.gsub(t, "%s+$", "")
	-- Fuera todo lo que no sea seguro en un nombre de fichero en exFAT.
	t = string.gsub(t, "[^%w%s%-_%(%)%[%]]", "")
	if string.len(t) > 40 then t = string.sub(t, 1, 40) end
	t = string.gsub(t, "%s+$", "")
	return t
end

--- Nombre propuesto para una tarjeta nueva: "SCES_502.95_Dark Cloud-1.bin". -----------
--- El numero del final lo mueve el usuario con arriba / abajo, para poder tener varias
--- partidas del mismo juego sin que una pise a la otra.
function vmc_new_name(nombre, n)
	local idopl = vmc_id_opl(nombre)
	if idopl == nil then return nil end
	if n == nil or n < 1 then n = 1 end
	local titulo = vmc_title(nombre)
	if titulo == "" then return idopl .."-".. n ..".bin" end
	return idopl .."_".. titulo .."-".. n ..".bin"
end

--- Devuelve el argumento "-mc0=<ruta>" para el juego, creando la tarjeta si falta.
--- "unidad_iso" es el prefijo de unidad donde Neutrino leera la ISO, para poner la
--- tarjeta en el MISMO soporte (con -bsd=ata todo es "mass:"). nil si no procede.
function vmc_auto(nombre, unidad_iso)
	if VMC_AUTO_ON ~= true then return nil end
	vmc_cfg_load()
	local id = vmc_id(nombre)
	if id == nil then return nil end

	local elegido = VMC_GAMES[id]

	-- "none" quiere decir NINGUNA tarjeta, y tiene que ganar sobre todo lo demas.
	-- Aqui estaba el sinsentido: desactivar la tarjeta en el menu de Boon deja el
	-- juego sin ".vmcd", o sea sin eleccion manual, y esta funcion lo tomaba por
	-- "no ha elegido nada, le creo una". El juego arrancaba con una tarjeta que el
	-- usuario acababa de quitar.
	if elegido == "none" then return nil end

	-- Una ruta concreta, si sigue existiendo.
	if elegido ~= nil and doesFileExist(elegido) then
		return "-mc0=".. elegido
	end

	-- Automatico: la primera tarjeta que sea DE ESTE JUEGO.
	--
	-- vmc_candidates devuelve ahora todos los ".bin" de las carpetas, para que la
	-- lista del menu no aparezca vacia delante de una carpeta llena. Pero aqui no se
	-- elige a ciegas: el segundo valor dice cuantas de las primeras llevan el ID del
	-- juego, y solo esas pueden usarse sin que el usuario lo haya pedido. Coger la
	-- primera de la carpeta seria arrancar con la partida de otro juego.
	local cand, propias = vmc_candidates(id)
	if propias >= 1 then return "-mc0=".. cand[1] end

	-- Ninguna tarjeta, y ninguna eleccion: el juego arranca SIN "-mc0=".
	--
	-- Antes se creaba una aqui mismo, en silencio, la primera vez que se lanzaba un
	-- juego. Es justo lo que hacia el asunto incomprensible: aparecian tarjetas que
	-- nadie habia pedido, en una unidad que nadie habia elegido. Crear una es ahora
	-- una accion explicita del menu del juego, y solo eso.
	return nil
end
