--[[-----------------------------------------------------------------------------------
PRISMBOOT/boot.lua - arranque directo desde el disco interno exFAT, sin llave USB.

Uso: el lanzador (OSDMenu, FMCB, OSD-XMB...) lanza el ELF del disco
   massX:/Prism/Prism.elf
con UN ARGUMENTO:
   mc0:/PRISMBOOT/boot.lua

Por que hace falta: Enceladus, al arrancar, recarga su propia pila USB (sin
ata_bd) y el disco del que venia desaparece. Pero si recibe un argumento,
ejecuta ESE script en lugar de su boot integrado - y la Memory Card siempre es
legible. Este script (3 KB) carga los drivers del disco desde mc0:/PRISMBOOT/
(24 KB), espera a que el disco gire, y le cede el control.

Journal, linea a linea: <soporte del ELF>/log/PRISMBOOT.txt si ese soporte se deja
escribir (llave USB); si no (ELF en el disco interno, aun ilegible),
mc0:/PRISMBOOT/BOOT_LOG.txt. Sin disco interno, arranca la instalacion local.
-------------------------------------------------------------------------------------]]

if FREAD   == nil and O_RDONLY ~= nil then FREAD   = O_RDONLY end
if FCREATE == nil and O_CREAT  ~= nil then FCREATE = O_RDWR | O_CREAT | O_TRUNC end
if SET == nil then SET = 0 end
if Sif == nil and IOP ~= nil then Sif = IOP end

-- Rutas ABSOLUTAS en todas partes: el directorio corriente (el disco) es ilegible aun.
local BASE = "mc0:/PRISMBOOT"
local MARCA = "/Roms/!Prism/internal-ata-disk.flag"

-- Journal: en el soporte que lanzo el ELF si se deja escribir (llave USB), y solo si
-- no (el ELF venia del disco interno, ilegible aun) en la Memory Card.
local LOCAL = tostring(System.currentDirectory())
local LOG_PATH = BASE .."/BOOT_LOG.txt"
pcall(function()
	if System.listDirectory(LOCAL .."/log") == nil then pcall(System.createDirectory, LOCAL .."/log") end
	local cand = LOCAL .."/log/PRISMBOOT.txt"
	local f = System.openFile(cand, FCREATE)
	System.writeFile(f, "", 0)
	System.closeFile(f)
	if doesFileExist(cand) then LOG_PATH = cand end
end)

local LOG = "PRISMBOOT - journal\n===================\n\n"
local function log(linea)
	LOG = LOG .. linea .. "\n"
	pcall(function()
		local f = System.openFile(LOG_PATH, FCREATE)
		System.writeFile(f, LOG, string.len(LOG))
		System.closeFile(f)
	end)
end

log("Lanzado con argumento; directorio corriente: ".. LOCAL)
log("Journal en: ".. LOG_PATH)

if IOP == nil then
	log("ERROR: build 2024 de Enceladus, sin IOP.loadModuleBuffer.")
	error("PRISMBOOT: build de Enceladus demasiado antigua")
end

-- El disco puede estar ya montado si el lanzador dejo ata_bd residente.
local visible = false
for n = 0, 5 do
	if doesFileExist("mass".. n ..":/Prism".. MARCA) then visible = true end
end

if visible then
	log("El disco ya esta montado: no se cargan IRX.")
else
	for _i, nombre in ipairs({"dev9_ns.irx", "ata_bd.irx"}) do
		local ruta = BASE .."/".. nombre
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

-- Lanzado desde una instalacion completa (llave USB): ese soporte ya tiene su propio
-- pre-boot, System/index.lua, con la unica politica de eleccion que existe (disco
-- interno si aparece, si no la instalacion local). Se le cede el control ya, con los
-- IRX marcados como cargados para que no los recargue.
if doesFileExist(LOCAL .."/System/index.lua") then
	PREBOOT_IRX_HECHO = true
	PREBOOT_ORIGEN = BASE
	log("Instalacion completa en ".. LOCAL ..": se cede el control a su System/index.lua")
	dofile(LOCAL .."/System/index.lua")
	return
end

-- Lanzado desde el disco interno (ilegible aun): hay que esperar a que gire.
log("Esperando el disco interno...")
local cible = nil
for intento = 1, 20 do
	for n = 0, 5 do
		local raiz = "mass".. n ..":/Prism"
		if cible == nil and doesFileExist(raiz .."/System/system.lua")
		   and doesFileExist(raiz .. MARCA) then
			cible = raiz
			log("Disco encontrado (intento ".. intento .."): ".. cible)
		end
	end
	if cible ~= nil then break end
	log("  intento ".. intento .."/20")
	if System.sleep ~= nil then System.sleep(1) end
end

if cible == nil then
	-- Sin disco interno: si el ELF venia de una llave USB completa, se arranca esa.
	-- Asi el kit puede quedarse en la entrada de FMCB aunque se arranque desde USB.
	if doesFileExist(LOCAL .."/System/system.lua") then
		cible = LOCAL
		log("Disco interno ausente: se arranca la instalacion local ".. cible)
	else
		log("ERROR: el disco interno no ha aparecido. Ver conexion/alimentacion.")
		error("PRISMBOOT: disco interno no encontrado (".. LOG_PATH ..")")
	end
end

PREBOOT_IRX_HECHO = true
PREBOOT_ORIGEN = BASE
System.currentDirectory(cible)
log("currentDirectory: ".. tostring(System.currentDirectory()))
log("Cediendo el control a ".. cible .."/System/system.lua")
dofile(cible .."/System/system.lua")
