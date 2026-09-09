-- Prism PS2 Launcher - core/devices.lua
-- Drive names: mass:/massN: normalisation, which device a core can read.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- Normaliza el prefijo de unidad de una ruta. ---------------------------------------
--- "mass:/X" y "mass0:/X" designan lo mismo, pero el nombre depende de QUIEN lanza el
--- programa: desde el OSD o FMCB se obtiene "mass:", desde uLaunchELF "mass0:".
--- Sin esto, el launcher cree que la instalacion ha cambiado de sitio y propone
--- reubicar las configuraciones (perdiendo los ajustes de RetroArch) a cada cambio
--- de metodo de arranque.
function NORM_DEV(ruta)
	if ruta == nil then return "" end
	local pos = string.find(ruta, ":", 1, true)
	if pos == nil then return string.lower(ruta) end
	local dev = string.sub(ruta, 1, pos-1)
	while string.len(dev) > 0 and string.match(string.sub(dev, -1), "%d") ~= nil do
		dev = string.sub(dev, 1, -2)
	end
	return string.lower(dev ..":".. string.sub(ruta, pos+1))
end

--- Quita la numeracion del prefijo de unidad y DEJA EL RESTO INTACTO. ----------------
--- "mass0:/POPS/Juego.VCD" -> "mass:/POPS/Juego.VCD".
--- No confundir con NORM_DEV, que ademas pasa todo a minusculas porque sirve para
--- comparar rutas; aqui eso destrozaria el nombre del fichero.
--- Hace falta porque Enceladus 2025 monta los dispositivos como "mass0:", "mass1:",
--- mientras que el homebrew anterior a BDM -POPStarter v13, Neutrino, RetroArch-
--- solo conoce "mass:". La build de 2024 sobre la que se escribio Prism
--- reportaba "mass:", y de ahi que aquello funcionara sin tocar nada.
function DEV_SIN_NUM(ruta)
	if ruta == nil then return nil end
	local pos = string.find(ruta, ":", 1, true)
	if pos == nil then return ruta end
	local dev = string.sub(ruta, 1, pos-1)
	while string.len(dev) > 0 and string.match(string.sub(dev, -1), "%d") ~= nil do
		dev = string.sub(dev, 1, -2)
	end
	return dev ..":".. string.sub(ruta, pos+1)
end

--- Cores capaces de leer el disco interno ATA. ---------------------------------------
--- El mismo disco tiene DOS nombres, segun quien mire:
---     Enceladus, con su propia pila BDM ....... mass0:
---     un core de RetroArch .................... ata0:
--- No es un capricho. "ps2atad.c" da al disco ATA el nombre "ata" ("g_ata_bd[i].path"),
--- y el "bdmfs_fatfs" actual registra un dispositivo iomanX por cada nombre distinto,
--- tratando "mass" aparte. El USB no declara nombre y se queda en "mass". El
--- "bdmfs_fatfs" que lleva Enceladus es anterior y mete todo en "mass". De ahi los dos
--- nombres para el mismo disco.
--- Solo los cores compilados con el parche saben de "ata0:". Para los demas -las 57
--- nightlies oficiales- el disco interno sigue sin existir, y hay que transbordar la
--- ROM a un soporte que si lean. De ahi esta lista: lo que no esta en ella se
--- transborda, que es el comportamiento seguro.
--- Al recompilar mas cores, anadirlos aqui.
--- A false: NINGUN core lee el disco interno, todo pasa por el transbordo. Es lo
--- correcto con las nightlies oficiales, que no llevan ata_bd. Poner a true solo si
--- se usan cores recompilados con el parche, y listarlos en CORES_ATA.
CORES_ATA_ON = false
CORES_ATA = {
	"fceumm_libretro_ps2.elf",
	"gambatte_libretro_ps2.elf",
	"picodrive_libretro_ps2.elf",
	"snes9x2002_libretro_ps2.elf",
}

function CORE_LEE_ATA(ruta_core)
	if CORES_ATA_ON ~= true or ruta_core == nil then return false end
	local n = string.lower(nombre_fichero(ruta_core))
	for i = 1, #CORES_ATA do
		if n == string.lower(CORES_ATA[i]) then return true end
	end
	return false
end

--- Nombre del disco interno tal como lo vera el core. ---------------------------------
--- Comprobado en consola: con una llave USB conectada, el disco interno sale en
--- "mass1:"; sin llave, en "mass0:". No es azar, es el orden en que RetroArch carga
--- los drivers en "init_drivers()": primero usbmass_bd, luego mx4sio, y ata_bd al
--- final. Los volumenes BDM se numeran por orden de conexion, asi que el indice del
--- disco interno es exactamente el numero de unidades USB que haya delante.
--- El lanzador ya sabe cuantas hay: BDM_DEVICES menos las marcadas en BDM_ATA.
---
--- Existe tambien un nombre estable, "ata0:", que un bdmfs_fatfs reciente registra a
--- partir de "bd->path". Es mejor cuando funciona, porque no depende de cuantas llaves
--- haya conectadas. Poner ATA_DEV_CORE = "ata0:" para usarlo; nil para calcular.
ATA_DEV_CORE = nil

function DEV_ATA_PARA_CORE()
	if ATA_DEV_CORE ~= nil then return ATA_DEV_CORE end
	local usb = 0
	local propio = ""
	local pos = string.find(System.currentDirectory(), ":", 1, true)
	if pos ~= nil then propio = string.sub(System.currentDirectory(), 1, pos) end
	if propio ~= "" and BDM_ATA[propio] ~= true then usb = usb + 1 end
	if BDM_DEVICES ~= nil then
		for i = 1, #BDM_DEVICES do
			if BDM_ATA[BDM_DEVICES[i]] ~= true and BDM_DEVICES[i] ~= propio then
				usb = usb + 1
			end
		end
	end
	return "mass".. tostring(usb) ..":"
end

--- Traduce una ruta del disco interno al nombre que usara el core. --------------------
function RUTA_ATA_CORE(ruta)
	if ruta == nil then return nil end
	local pos = string.find(ruta, ":", 1, true)
	if pos == nil then return ruta end
	return DEV_ATA_PARA_CORE() .. string.sub(ruta, pos+1)
end

--- Nombre de dispositivo tal como lo vera un core de RetroArch. ---------------------
--- Solo hay que quitar el numero a "massN:": RetroArch reinicia el IOP y monta su
--- propia pila, donde el USB se llama "mass:" sin numero. Pero "mc0:" se llama "mc0:"
--- en los dos lados, y "mc:" no existe: aplicar DEV_SIN_NUM a ciegas producia
--- "mc:/Prism/Saves", una ruta que RetroArch descarta por no ser un directorio,
--- y las partidas volvian a caer dentro de su propia carpeta.
function DEV_PARA_CORE(ruta)
	if ruta == nil then return nil end
	local pos = string.find(ruta, ":", 1, true)
	if pos == nil then return ruta end
	local dev = string.sub(ruta, 1, pos-1)
	if string.lower(string.sub(dev, 1, 4)) ~= "mass" then return ruta end
	return DEV_SIN_NUM(ruta)
end
