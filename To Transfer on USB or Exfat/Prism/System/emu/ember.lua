-- Prism PS2 Launcher - emu/ember.lua
-- Ember: roots, game folders, BIOS copy, per-game PS1 settings.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- Ember is laid out beside the games. -----------------------------------------------
--- Ember resolves the .cue RELATIVE to its own directory: the original passed it only
--- the file name and launched it from the games folder. Moving the emulator to
--- "Bios/" broke that contract, and Ember would boot to the BIOS screen because it
--- could not find the disc. The original layout is restored: "ember.elf" and
--- "bios.bin" are placed beside the .cue files, copied from "Bios/" the first time.
--- Two small files, and only once per folder.
--- Ember Beta 1: its own folder, one directory per game. -------------------------------
--- The demo version launched from the ROM folder and was handed the .cue file name.
--- Beta 1 changes both of those:
---
---     Ember/
---     |- ember.elf          the emulator
---     |- bios.bin           supplied by the user
---     |- settings.txt       optional:  display: 480  |  display: 240
---     `- games/
---        `- Spyro/          ONE DIRECTORY PER GAME, named whatever you like
---           |- Spyro.cue
---           |- Spyro.bin
---           |- MC1.vmc      Ember creates these itself, one pair per game
---           |- MC2.vmc
---           `- SharedMC.txt optional, one line: the name of another folder
---
--- And the argument is no longer a file but the NAME OF THE FOLDER inside "games".
--- Everything else Ember resolves relative to where its own ELF sits, so the whole
--- folder is portable: it works on USB, on the internal drive or on an MMCE.
EMBER_SUB = "/Ember"

--- The "Ember" folders that really exist, in root order. ------------------------------
function ember_roots()
    local out = {}
    if RAICES == nil then return out end
    for i = 1, #RAICES do
        local dir = RAICES[i] .. EMBER_SUB
        if doesFileExist(dir .."/ember.elf") then out[#out + 1] = dir end
    end
    return out
end

--- Where an Ember game lives, or nil. -------------------------------------------------
--- "carpeta" is the name of the directory inside "games", which is exactly what
--- gets passed to the ELF as its argument.
function ember_game(carpeta)
    if carpeta == nil then return nil, nil end
    local raices = ember_roots()
    for i = 1, #raices do
        local dir = raices[i] .."/games/".. carpeta
        if System.listDirectory(dir) ~= nil then return raices[i], dir end
    end
    return nil, nil
end

--- The names a PlayStation 1 BIOS actually arrives under. ------------------------------
--- Nobody's BIOS is called "bios.bin" when they get it: it is called scph1001.bin, or
--- SCPH5501.BIN, or whatever the machine it was dumped from was. Ember wants it as
--- "bios.bin" next to its ELF, which is Ember's business, not the user's - so every
--- name a PS1 BIOS is normally found under is looked for, and the copy is renamed on
--- the way in. Case matters on some filesystems, hence both spellings.
PS1_BIOS_NAMES = {
	"bios.bin", "BIOS.BIN",
	"scph1001.bin", "SCPH1001.BIN", "scph1000.bin", "SCPH1000.BIN",
	"scph1002.bin", "SCPH1002.BIN", "scph101.bin", "SCPH101.BIN",
	"scph5500.bin", "SCPH5500.BIN", "scph5501.bin", "SCPH5501.BIN",
	"scph5502.bin", "SCPH5502.BIN", "scph5552.bin", "SCPH5552.BIN",
	"scph7001.bin", "SCPH7001.BIN", "scph7002.bin", "SCPH7002.BIN",
	"scph7502.bin", "SCPH7502.BIN", "scph9001.bin", "SCPH9001.BIN",
	"scph9002.bin", "SCPH9002.BIN", "scph102a.bin", "SCPH102A.BIN",
	"scph102b.bin", "SCPH102B.BIN",
}

--- The PS1 BIOS in Bios/, whatever it is called, or nil. ------------------------------
function ember_bios_source()
	local dir = System.currentDirectory() .."/Bios/"
	for i = 1, #PS1_BIOS_NAMES do
		local p = dir .. PS1_BIOS_NAMES[i]
		if doesFileExist(p) then return p, PS1_BIOS_NAMES[i] end
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
	local origen, nombre = ember_bios_source()
	if origen == nil then
		log_event("FILE", "Ember: no PS1 BIOS in Bios/ (scph1001.bin and the rest were looked for)")
		return false
	end
	log_event("FILE", "Ember: copying ".. origen .." -> ".. dest .."  (from ".. tostring(nombre) ..")")
	pcall(System.copyFile, origen, dest)
	return doesFileExist(dest)
end

--- Can Ember run anything at all, and if not, why. ------------------------------------
--- Asked BEFORE a launch, so the answer is on screen while there is still something to
--- be done about it, instead of after the launch has failed.
--- Returns true, nil  |  false, "one line saying what is missing"
function ember_ready()
	local roots = ember_roots()
	if #roots == 0 then
		return false, "Ember is not installed (no Ember/ember.elf on any drive)"
	end
	for i = 1, #roots do
		if doesFileExist(roots[i] .."/bios.bin") then return true, nil end
	end
	if ember_bios_source() ~= nil then return true, nil end
	return false, "No PlayStation 1 BIOS: put scph1001.bin (or any SCPH dump) in Bios/"
end

--- What is inside a game folder: ".cue", ".bin", ".chd" or nil. -----------------------
--- Ember takes the .cue if there is one, and the .bin if not. A .chd is no use to it, and
--- it is worth knowing before booting rather than landing in the BIOS shell unexplained.
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

--- Key for a PS1 game, so it is not listed twice. -------------------------------------
--- The same game can be there as a .VCD for POPStarter and as a folder for Ember, and
--- those are two ways of booting ONE thing. They are compared without the extension,
--- without the OPL prefix ("SCES_009.84.") and without anything but letters and digits,
--- because the two names come from different places and rarely match character for character.
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

--- What THIS PS1 game boots with: "ember" or "pops". ----------------------------------
--- One file per decision, like Launcher.cfg for PS2 and VMC.cfg for the memory cards.
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
