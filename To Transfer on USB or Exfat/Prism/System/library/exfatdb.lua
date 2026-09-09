-- Prism PS2 Launcher - library/exfatdb.lua
-- exfatdb.json: the inventory of the internal disk written for the PC tools.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

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
--- una sola identidad para dos origenes ("POPS" y "Ember").
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
		t = t .."  \"generado_por\": \"Prism PS2 Launcher\",\n"
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
