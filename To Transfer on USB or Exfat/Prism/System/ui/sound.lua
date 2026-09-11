-- Prism PS2 Launcher - ui/sound.lua
-- Menu sounds and background music: loading, voices, volume.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- Loading and checking of sounds. -----------------------------------------------------
--- And what loaded, and how big it is, is noted in the journal. -----------------------
--- Sound.loadADPCM does not say why it fails, and audsrv_load_adpcm fails SILENTLY when
--- SifAllocIopHeap cannot get the block: it asks for the whole file at once and the IOP
--- has 2 MB counting the modules. A file that fits easily in the SPU2 can fail to load
--- for that reason -- a 1.2 MB track did not load, and without this line there is no
--- way to tell apart "no file", "the file does not fit" and "the volume is at zero".
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
			local estado = "null handle"
			if sonido ~= nil then estado = "handle ".. tostring(sonido) end
			boot_log("SONIDO ".. dir .."  ".. tostring(bytes) .." bytes  -> ".. estado)
		end
	end
	return sonido
end

--- Preferred sound, with fallback. -----------------------------------------------------
-- The "2" files are the sound set in use. Boon's originals stay in the folder and
-- load by themselves if the "2" ones are missing, so deleting a "2" file is all it
-- takes to go back to the earlier sound.
function preferred_sound(sonido, preferido, respaldo)
	local elegido = verificar_sonidos(sonido, preferido)
	if elegido == nil then
		elegido = verificar_sonidos(sonido, respaldo)
	end
	return elegido
end

-- Sound loading. -----------------------------------------------------------------------
S_MOVER = preferred_sound(S_MOVER, "System/Medias/Sound/Menu/move2.adp", "System/Medias/Sound/Menu/move.adp");
S_EJECUTAR = preferred_sound(S_EJECUTAR, "System/Medias/Sound/Menu/run2.adp", "System/Medias/Sound/Menu/run.adp");
S_CANCELAR = preferred_sound(S_CANCELAR, "System/Medias/Sound/Menu/back2.adp", "System/Medias/Sound/Menu/back.adp");
S_NETX = preferred_sound(S_NETX, "System/Medias/Sound/Menu/next2.adp", "System/Medias/Sound/Menu/next.adp");
S_MUSICA = verificar_sonidos(S_MUSICA, "System/Medias/Sound/Background/music.adp");
if boot_log ~= nil and S_MUSICA == nil then
	-- The name matters: "music0.adp" is the name the track carries when it is SWITCHED
	-- OFF, and it is the only one the installation shipped. The program only looks for
	-- "music.adp", so out of the box nothing plays in the background -- not because it
	-- fails, but because it was never switched on.
	boot_log("SONIDO  no background music: System/Medias/Sound/Background/music.adp missing"
		.."  (music0.adp = track switched off)")
end

--- One SPU2 voice per menu sound. ------------------------------------------------------
--- The four sounds all played on voice 1: the 166 places that call repro_sfx pass "1".
--- And audsrv does not mix two sounds on one voice -- audsrv_ch_play_adpcm looks at the
--- ENDX bit of the requested voice and, if it is still sounding, returns
--- -AUDSRV_ERR_NO_MORE_CHANNELS without playing anything:
---
---     if (ch >= 0 && ch < 24) {
---         endx = sceSdGetSwitch(SD_CORE_1 | SD_SWITCH_ENDX);
---         if (!(endx & (1 << ch))) return -AUDSRV_ERR_NO_MORE_CHANNELS;
---
--- With the original samples, 0.18 s long, you had to move very fast to notice it.
--- The longer the samples, the more they tread on each other.
---
--- Voice 2 is the music and voice 3 the intros, so the menu sounds run from 4 upwards.
--- The volume has to be set on ALL of them: audsrv_adpcm_init leaves the 24 voices at
--- 0x3fff, so a voice whose volume nobody lowers plays at full blast.
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
