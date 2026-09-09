-- Prism PS2 Launcher - emu/ember.lua
-- Ember: roots, game folders, BIOS copy, per-game PS1 settings.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- Despliegue de Ember junto a los juegos. -------------------------------------------
--- Ember resuelve el .cue RELATIVO a su propio directorio: el original le pasaba solo
--- el nombre del fichero y lo lanzaba desde la carpeta de los juegos. Al mover el
--- emulador a "Bios/" se rompio ese contrato, y Ember arrancaba en la pantalla del
--- BIOS por no encontrar el disco. Se restaura el montaje de origen: "ember.elf" y
--- "bios.bin" se colocan junto a los .cue, copiados desde "Bios/" la primera vez.
--- Son dos ficheros pequenos y una sola vez por carpeta.
--- Ember Beta 1: carpeta propia, un directorio por juego. ------------------------------
--- La version demo se lanzaba desde la carpeta de las ROM y recibia el nombre del .cue.
--- Beta 1 cambia las dos cosas:
---
---     Ember/
---     |- ember.elf          el emulador
---     |- bios.bin           lo pone el usuario
---     |- settings.txt       opcional:  display: 480  |  display: 240
---     `- games/
---        `- Spyro/          UN DIRECTORIO POR JUEGO, con el nombre que sea
---           |- Spyro.cue
---           |- Spyro.bin
---           |- MC1.vmc      las crea Ember sola, una pareja por juego
---           |- MC2.vmc
---           `- SharedMC.txt opcional, una linea: el nombre de otra carpeta
---
--- Y el argumento ya no es un fichero sino el NOMBRE DE LA CARPETA dentro de "games".
--- Todo lo demas lo resuelve Ember relativo a donde este su propio ELF, asi que la
--- carpeta entera es portatil: vale en el USB, en el disco interno o en una MMCE.
EMBER_SUB = "/Ember"

--- Las carpetas "Ember" que existen de verdad, en orden de raiz. ----------------------
function ember_roots()
    local out = {}
    if RAICES == nil then return out end
    for i = 1, #RAICES do
        local dir = RAICES[i] .. EMBER_SUB
        if doesFileExist(dir .."/ember.elf") then out[#out + 1] = dir end
    end
    return out
end

--- Donde vive un juego de Ember, o nil. -----------------------------------------------
--- "carpeta" es el nombre del directorio dentro de "games", que es exactamente lo que
--- se le pasa como argumento al ELF.
function ember_game(carpeta)
    if carpeta == nil then return nil, nil end
    local raices = ember_roots()
    for i = 1, #raices do
        local dir = raices[i] .."/games/".. carpeta
        if System.listDirectory(dir) ~= nil then return raices[i], dir end
    end
    return nil, nil
end

--- bios.bin beside ember.elf: copied from Bios/ once, and never touched again. ---------
--- Ember wants the BIOS next to its own ELF and nowhere else. The launcher keeps one
--- copy of every system file in Bios/, so the first launch puts a copy where Ember
--- looks; from then on the file is Ember's and the launcher only checks it is there.
--- Returns true when Ember has what it needs.
function ember_bios(raiz_emb)
	if raiz_emb == nil then return false end
	local dest = raiz_emb .."/bios.bin"
	if doesFileExist(dest) then return true end
	local origen = RUTA_BIOS("bios.bin", "")
	if doesFileExist(origen) == false then
		log_event("FILE", "Ember: no bios.bin in ".. raiz_emb .." and none in Bios/ to copy")
		return false
	end
	log_event("FILE", "Ember: copying ".. origen .." -> ".. dest)
	pcall(System.copyFile, origen, dest)
	return doesFileExist(dest)
end

--- Que hay dentro de una carpeta de juego: ".cue", ".bin", ".chd" o nil. --------------
--- Ember toma el .cue si lo hay y si no el .bin. Un .chd NO le sirve, y conviene saberlo
--- antes de arrancar en vez de aterrizar en el shell de la BIOS sin explicacion.
function ember_contents(dir)
    local c = System.listDirectory(dir)
    if c == nil then return nil end
    local tiene_cue, tiene_bin, tiene_chd = false, false, false
    for i = 1, #c do
        if c[i].directory == false then
            local ext = string.lower(string.sub(c[i].name, -4))
            if ext == ".cue" then tiene_cue = true
            elseif ext == ".bin" then tiene_bin = true
            elseif ext == ".chd" then tiene_chd = true end
        end
    end
    if tiene_cue then return "cue" end
    if tiene_bin then return "bin" end
    if tiene_chd then return "chd" end
    return nil
end

--- Clave de un juego de PS1, para no listarlo dos veces. ------------------------------
--- El mismo juego puede estar como .VCD para POPStarter y como carpeta para Ember, y
--- son dos formas de arrancar UNA cosa. Se comparan sin extension, sin el prefijo de
--- OPL ("SCES_009.84.") y sin nada que no sea letra o cifra, porque los dos nombres
--- vienen de sitios distintos y rara vez coinciden al caracter.
function ps1_key(nombre)
    if nombre == nil then return nil end
    local n = nombre
    n = string.gsub(n, "%.[A-Za-z]%.?[A-Za-z]?[A-Za-z]?$", "")
    n = string.gsub(n, "^%a%a%a%a[_%- ]%d%d%d%.%d%d%.", "")
    n = string.lower(n)
    n = string.gsub(n, "[^%a%d]", "")
    if n == "" then return string.lower(nombre) end
    return n
end

--- Con que arranca ESTE juego de PS1: "ember" o "pops". -------------------------------
--- Un fichero por decision, como Launcher.cfg para PS2 y VMC.cfg para las tarjetas.
PS1_GAMES = {}
ps1_cfg_loaded = false

function ps1_cfg_path()
    return System.currentDirectory() .."/System/Config/PS1.cfg"
end

function ps1_cfg_load()
    if ps1_cfg_loaded == true then return end
    ps1_cfg_loaded = true
    local f = ps1_cfg_path()
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
                local v = string.gsub(valor, "%s+$", "")
                if v ~= "" then PS1_GAMES[clave] = v end
            end
        end
    end)
end

function ps1_cfg_save()
    pcall(function()
        local t = ""
        for k, v in pairs(PS1_GAMES) do t = t .. k .."=".. v .."\n" end
        local h = System.openFile(ps1_cfg_path(), FCREATE)
        System.writeFile(h, t, string.len(t))
        System.closeFile(h)
    end)
end
