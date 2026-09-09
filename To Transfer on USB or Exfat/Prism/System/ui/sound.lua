-- Prism PS2 Launcher - ui/sound.lua
-- Menu sounds and background music: loading, voices, volume.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- Carga y verificación de sonidos. ----------------------------------------------------
--- Y se apunta en el journal lo que ha cargado y cuanto pesa. -------------------------
--- Sound.loadADPCM no dice por que falla, y audsrv_load_adpcm falla EN SILENCIO cuando
--- SifAllocIopHeap no consigue el bloque: pide el fichero entero de una vez y el IOP
--- tiene 2 MB contando los modulos. Un fichero que cabe de sobra en la SPU2 puede no
--- cargar por eso -- una pista de 1,2 MB no cargo, y sin esta linea no hay manera de
--- distinguir "no hay fichero", "el fichero no cabe" y "el volumen esta a cero".
function verificar_sonidos(sonido, dir)
	local actual = System.currentDirectory()
	sonido = nil
	if doesFileExist(actual .."/".. dir) then
		local bytes = nil
		pcall(function()
			local h = System.openFile(actual .."/".. dir, FREAD)
			bytes = System.sizeFile(h)
			System.closeFile(h)
		end)
		sonido = Sound.loadADPCM(dir)
		if boot_log ~= nil then
			local estado = "handle nulo"
			if sonido ~= nil then estado = "handle ".. tostring(sonido) end
			boot_log("SONIDO ".. dir .."  ".. tostring(bytes) .." bytes  -> ".. estado)
		end
	end
	return sonido
end

--- Sonido preferido, con respaldo. -----------------------------------------------------
-- Los ficheros "2" son el juego de sonidos en uso. Los originales de Boon siguen
-- en la carpeta y se cargan solos si los "2" faltan, asi que borrar un fichero "2"
-- basta para volver al sonido de antes.
function preferred_sound(sonido, preferido, respaldo)
	local elegido = verificar_sonidos(sonido, preferido)
	if elegido == nil then
		elegido = verificar_sonidos(sonido, respaldo)
	end
	return elegido
end

-- Carga de sonidos. --------------------------------------------------------------------
S_MOVER = preferred_sound(S_MOVER, "System/Medias/Sound/Menu/move2.adp", "System/Medias/Sound/Menu/move.adp");
S_EJECUTAR = preferred_sound(S_EJECUTAR, "System/Medias/Sound/Menu/run2.adp", "System/Medias/Sound/Menu/run.adp");
S_CANCELAR = preferred_sound(S_CANCELAR, "System/Medias/Sound/Menu/back2.adp", "System/Medias/Sound/Menu/back.adp");
S_NETX = preferred_sound(S_NETX, "System/Medias/Sound/Menu/next2.adp", "System/Medias/Sound/Menu/next.adp");
S_MUSICA = verificar_sonidos(S_MUSICA, "System/Medias/Sound/Background/music.adp");
if boot_log ~= nil and S_MUSICA == nil then
	-- El nombre importa: "music0.adp" es el nombre que tiene la pista cuando esta
	-- APAGADA, y es el unico que traia la instalacion. El programa solo busca
	-- "music.adp", asi que de fabrica no suena nada de fondo -- no porque falle, sino
	-- porque nunca estuvo encendida.
	boot_log("SONIDO  sin musica de fondo: falta System/Medias/Sound/Background/music.adp"
		.."  (music0.adp = pista apagada)")
end

--- Una voz SPU2 por sonido de menu. ----------------------------------------------------
--- Los cuatro sonidos se reproducian en la voz 1: los 166 sitios que llaman a repro_sfx
--- pasan "1". Y audsrv no mezcla dos sonidos en una voz -- audsrv_ch_play_adpcm mira el
--- bit ENDX de la voz pedida y, si todavia esta sonando, devuelve
--- -AUDSRV_ERR_NO_MORE_CHANNELS sin reproducir nada:
---
---     if (ch >= 0 && ch < 24) {
---         endx = sceSdGetSwitch(SD_CORE_1 | SD_SWITCH_ENDX);
---         if (!(endx & (1 << ch))) return -AUDSRV_ERR_NO_MORE_CHANNELS;
---
--- Con las muestras de origen, de 0,18 s, hacia falta moverse muy deprisa para notarlo.
--- Cuanto mas largas son las muestras, mas se pisan.
---
--- La voz 2 es la musica y la 3 las intros, asi que los sonidos del menu van de la 4 en
--- adelante. El volumen hay que ponerlo en TODAS: audsrv_adpcm_init deja las 24 voces a
--- 0x3fff, de modo que una voz a la que nadie le baja el volumen suena al maximo.
SFX_CHANNELS = {}
SFX_VOICES = {1, 4, 5, 6, 7}

function sfx_voice(sonido, canal)
	if sonido ~= nil and SFX_CHANNELS[sonido] ~= nil then return SFX_CHANNELS[sonido] end
	return canal
end

function sfx_volume(volumen)
	for i = 1, #SFX_VOICES do
		pcall(Sound.setADPCMVolume, SFX_VOICES[i], volumen)
	end
end

if S_MOVER ~= nil then SFX_CHANNELS[S_MOVER] = 4 end
if S_EJECUTAR ~= nil then SFX_CHANNELS[S_EJECUTAR] = 5 end
if S_CANCELAR ~= nil then SFX_CHANNELS[S_CANCELAR] = 6 end
if S_NETX ~= nil then SFX_CHANNELS[S_NETX] = 7 end
