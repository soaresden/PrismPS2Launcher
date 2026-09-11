--[[-----------------------------------------------------------------------------------
Prism universal pre-boot.

The script built into Enceladus runs "System/index.lua" BEFORE
"System/system.lua". This file is identical in every copy of the program
-full install on USB, full install on the internal disk, and the
Memory Card mini-kit- and decides on each boot which install governs.

Media covered:
  USB FAT32 / USB exFAT   Enceladus reads them natively: boot happens right here.
  Memory Card             the mini-kit (ELF + this file + IRX) lives on mc0 and
                          chains on to the full install.
  Internal ATA exFAT disk Enceladus does NOT read it at boot (its BDM stack does
                          not include ata_bd): the ELF cannot be launched from it.
                          It is reached via the mini-kit or via a USB install.

Rule for choosing the governing install (PREFERIR_DISCO_INTERNO=true):
  1. the INTERNAL DISK, recognised by its marker
     "Roms/!Prism/internal-ata-disk.flag" - never by drive name.
     It is waited for up to 10 s (it is spinning up). Settings, saves, VMC and
     journals live on it; the USB only boots and contributes secondary games.
  2. the LOCAL one on the boot medium, if the disk does not show up;
  3. any complete "massN:/Prism", as a last resort.

Everything goes to "Prism.log" next to the ELF, with the PRE category in front.
-------------------------------------------------------------------------------------]]

-- Minimal compatibility layer (identical to the one in system.lua).
if FREAD   == nil and O_RDONLY ~= nil then FREAD   = O_RDONLY end
if FCREATE == nil and O_CREAT  ~= nil then FCREATE = O_RDWR | O_CREAT | O_TRUNC end
if SET == nil then SET = 0 end
if Sif == nil and IOP ~= nil then Sif = IOP end

local base = System.currentDirectory()

-- One single journal for the whole launcher. This writes BEFORE system.lua does, so
-- whatever was there has to be kept: it is read once, trimmed from the start and
-- becomes the prefix. system.lua will do the same afterwards and find these lines
-- already inside. Without this, the pre-boot would wipe the launch history on every
-- power-on, which is exactly what is needed when a failed attempt hands control
-- back to uLaunchELF.
local RUTA_LOG = base .."/Prism.log"
local PREVIO = ""
pcall(function()
	if doesFileExist(RUTA_LOG) then
		local f = System.openFile(RUTA_LOG, FREAD)
		local tam = System.sizeFile(f)
		System.seekFile(f, 0, SET)
		local t = System.readFile(f, tam)
		System.closeFile(f)
		if t ~= nil then
			if string.len(t) > 24000 then
				t = "[...start trimmed...]\n".. string.sub(t, string.len(t) - 24000)
			end
			PREVIO = t
		end
	end
end)

local LOG = "\n--- pre-boot (System/index.lua) ---\n"

local function log(linea)
	LOG = LOG .. "PRE    " .. linea .. "\n"
	pcall(function()
		local f = System.openFile(RUTA_LOG, FCREATE)
		local t = PREVIO .. LOG
		System.writeFile(f, t, string.len(t))
		System.closeFile(f)
	end)
end

local MARCA = "/Roms/!Prism/internal-ata-disk.flag"

local function instalacion_completa(raiz)
	return doesFileExist(raiz .."/System/system.lua")
end

log("Boot medium         : ".. tostring(base))
log("Enceladus build     : ".. ((IOP ~= nil) and "2025+ (IOP table)" or "2024 (Sif table)"))

-- Is the internal disk already mounted? That happens when the launcher left ata_bd
-- resident, or on a warm restart. Loading it again would be fatal.
local disco_visible = false
for n = 0, 5 do
	if doesFileExist("mass".. n ..":/Prism".. MARCA) then disco_visible = true end
end
-- It can also be told without the marker: on a cold boot only the boot drive
-- exists. If a second BDM drive is already mounted, the drivers are resident
-- (warm restart after an error) and reloading them hangs the console.
if disco_visible == false then
	local montadas = 0
	for n = 0, 5 do
		if System.listDirectory("mass".. n ..":/") ~= nil then montadas = montadas + 1 end
	end
	if montadas >= 2 then
		disco_visible = true
		log("There are ".. montadas .." BDM drives mounted before loading anything: drivers already resident.")
	end
end

local EN_HOST = (string.lower(string.sub(tostring(base), 1, 5)) == "host:")

if IOP == nil then
	log("2024 build: IRX are not loaded (Sif.loadModule hangs on this build).")
elseif EN_HOST then
	log("host: (PCSX2 / ps2link): no internal disk, IRX are not loaded.")
elseif PREBOOT_IRX_HECHO == true then
	log("IRX already loaded by the Memory Card kit (".. tostring(PREBOOT_ORIGEN) .."): not reloaded.")
elseif disco_visible == true then
	log("The internal disk is already mounted: the IRX are not reloaded.")
else
	-- Load dev9 + ata_bd into the Enceladus BDM stack. The order is mandatory.
	for _i, nombre in ipairs({"dev9_ns.irx", "ata_bd.irx"}) do
		local ruta = base .."/IRX/".. nombre
		if doesFileExist(ruta) == false then
			log("-> ".. nombre .."  MISSING from IRX/, skipped")
		else
			log("-> ".. nombre)
			local ok, err = pcall(function()
				local fd = System.openFile(ruta, FREAD)
				local tam = System.sizeFile(fd)
				System.seekFile(fd, 0, SET)
				local datos = System.readFile(fd, tam)
				System.closeFile(fd)
				local id = IOP.loadModuleBuffer(datos, tam)
				LOG = LOG .."   ".. tostring(tam) .." bytes, ID = ".. tostring(id) .."\n"
			end)
			if ok == false then log("   ERROR: ".. tostring(err)) end
		end
	end
end

-- Policy for choosing the governing install.
--   true : the exFAT internal disk RULES when it is present. Settings, saves,
--          VMC and journals live on it; the USB is left as a boot springboard and
--          a secondary source of games. It gets up to 10 seconds to spin up.
--   false: classic behaviour, the local install on the boot medium governs.
local PREFERIR_DISCO_INTERNO = true

local cible = nil
local local_ok = instalacion_completa(base)
log("Local install complete: ".. tostring(local_ok))

if EN_HOST then
	log("host: there is no internal disk to wait for.")
elseif PREFERIR_DISCO_INTERNO then
	log("Policy: the internal disk governs if it is present. Waiting for it...")
	local espera = local_ok and 10 or 20
	for intento = 1, espera do
		for n = 0, 5 do
			local raiz = "mass".. n ..":/Prism"
			if cible == nil and instalacion_completa(raiz) and doesFileExist(raiz .. MARCA) then
				cible = raiz
				log("Internal disk found (attempt ".. intento .."): ".. cible)
			end
		end
		if cible ~= nil then break end
		log("  attempt ".. intento .."/".. espera ..", the disk is not answering yet")
		if System.sleep ~= nil then System.sleep(1) end
	end
	if cible == nil then
		log("Internal disk absent after ".. espera .." s.")
	end
end

if cible == nil and local_ok then
	cible = base
	log("The local install governs: ".. cible)
end
if cible == nil then
	for n = 0, 5 do
		local raiz = "mass".. n ..":/Prism"
		if cible == nil and instalacion_completa(raiz) then
			cible = raiz
			log("Last resort, USB install: ".. cible)
		end
	end
end

if cible == nil then
	log("")
	log("ERROR: no complete install found, on any medium.")
	log("Check: the internal disk is connected and carries the marker in")
	log("Roms/!Prism/; or there is a complete Prism on a USB.")
	error("Prism: install not found (see Prism.log)")
end

-- State shared with system.lua: the IRX are already dealt with here, and the
-- real boot origin is recorded even when chaining on to another medium.
PREBOOT_IRX_HECHO = true
PREBOOT_ORIGEN = base

if cible ~= base then
	System.currentDirectory(cible)
	log("currentDirectory   : ".. tostring(System.currentDirectory()))
end
log("Handing control to ".. cible .."/System/system.lua")
dofile(cible .."/System/system.lua")
