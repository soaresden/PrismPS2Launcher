-- Prism PS2 Launcher - library/exfatdb.lua
-- exfatdb.json: the inventory of the internal disk written for the PC tools.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- Database of what the console really sees: "exfatdb.json", beside the ELF. ---------
--- It fills up as the systems are walked and is rewritten on every change.
--- It exists mainly to tune the PC scripts: it is the only reliable source for what
--- the PS2 finds, with the drive names exactly as it sees them.
EXFATDB_ON = true
EXFATDB = {}
EXFATDB_SUCIA = false

--- Escapes a string for JSON. -------------------------------------------------------
function json_txt(s)
	s = tostring(s)
	s = string.gsub(s, "\\", "\\\\")
	s = string.gsub(s, "\"", "\\\"")
	s = string.gsub(s, "[\r\n\t]", " ")
	return "\"".. s .."\""
end

--- Records an explored directory and its contents. ----------------------------------
--- "clave" allows grouping under a name other than ROMS_DIR[identidad]: PS1 uses
--- a single identity for two sources ("POPS" and "Ember").
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
	-- MERGE, do not replace. The same directory appears several times in the search
	-- list: under its own name and again as an EmulationStation alias. On the second
	-- pass the games are already in "vistos", so the list arrives empty; replacing
	-- the record wiped out everything found on the first pass.
	for i = 1, #entradas do
		reg.juegos[entradas[i].fichero] = entradas[i].titulo
	end
	EXFATDB_SUCIA = true
end

--- Dumps the file. ------------------------------------------------------------------
--- Grouped by medium ("USB" / "ATA") and by system, not by directory: on a file
--- system that ignores case, "Roms/nes" and "roms/nes" are the same folder and used
--- to appear twice. Here they are merged, and the repeated games with them.
function exfatdb_escribir()
	if EXFATDB_ON ~= true or EXFATDB_SUCIA ~= true then return end
	EXFATDB_SUCIA = false
	pcall(function()
		-- Regroup: medium -> system -> set of files.
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
				-- "POPS" lives at the root of the drive, not under "roms/".
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

		--- Drive associated with each medium, so the full path can be rebuilt.
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
