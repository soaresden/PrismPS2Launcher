--[[------------------SPAGHETTICODE-------------------]]--
--[[█▀█ ██▀ ▀█▀ █▀█ █▀█ █    ▄▄ ▄ ▄ ▄▄▄ ▄▄▄ █▄▄ ▄▄  ▄▄]]--
--[[█▀▄ █▄▄  █  █▀▄ █▄█ █▄▄ ▀▄█ █▄█ █ █ █▄▄ █ █ ██▄ █ ]]--
--[[------------------- v1.0/rev2 --------------------]]--

--[[Líneas para los idiomas de Prism.]]--
--- Crear listas de textos. -------------------------------------------------------------
function lang_select()
	local actual = System.currentDirectory()
	TEXT_GEN = {}
	TEXT_M_PS2 = {}
	TEXT_M_EXP = {}
	TEXT_M_CON = {}
	TEXT_SPR_T = {}
	TEXT_LAY_T = {}
	TEXT_M_STI = {}
	TEXT_M_PRI = {}
	TEXT_M_REL = {}
	TEXT_POPS_DESCR = {}
	TEXT_M_PS1 = {}
	local pre_spa = doesFileExist(actual .."/System/Defaults/SPA")
	local pre_por = doesFileExist(actual .."/System/Defaults/POR")
	local pre_eng = doesFileExist(actual .."/System/Defaults/ENG")
	if (pre_spa == true and pre_por == true) or (pre_eng == true and pre_por == true) or (pre_spa == true and pre_eng == true)
	or (pre_spa == false and pre_por == false and pre_eng == false) then
		if doesFileExist(actual .."/System/Defaults/SPA") then
			System.rename(actual .."/System/Defaults/SPA", actual .."/System/Defaults/ENG")
		end
		if doesFileExist(actual .."/System/Defaults/POR") then
			System.rename(actual .."/System/Defaults/POR", actual .."/System/Defaults/ENG")
		end
		if doesFileExist(actual .."/System/Defaults/ENG") == false then
			local pre_eng_create = System.openFile(actual .."/System/Defaults/ENG", FCREATE)
			System.closeFile(pre_eng_create)
		end
	end

	-------------------------------------------------------------------------------------
	-- Español. -------------------------------------------------------------------------
	-- One file per language under System/lang/. Each defines lang_<code>(actual)
	-- and fills the same TEXT_* tables; the marker file in System/Defaults/ picks it.
	if doesFileExist(actual .."/System/Defaults/SPA") then
		lang_es(actual)
	elseif doesFileExist(actual .."/System/Defaults/POR") then
		lang_pt(actual)
	else
		lang_en(actual)
	end
end

--- Define las imágenes usadas para cada idioma. ----------------------------------------
function img_lang(name, tipo)
	local actual = System.currentDirectory()
	if doesFileExist(actual .."/System/Defaults/SPA") and doesFileExist(actual .."/System/Medias/Default/COVER_DEFAULTSPA.png") and doesFileExist(actual .."/System/Medias/Default/SCREENSHOT_DEFAULTSPA.png") then
		if tipo == true then
			name = "COVER_DEFAULTSPA"
		else
			name = "SCREENSHOT_DEFAULTSPA"
		end
	elseif doesFileExist(actual .."/System/Defaults/POR") and doesFileExist(actual .."/System/Medias/Default/COVER_DEFAULTPOR.png") and doesFileExist(actual .."/System/Medias/Default/SCREENSHOT_DEFAULTPOR.png") then
		if tipo == true then
			name = "COVER_DEFAULTPOR"
		else
			name = "SCREENSHOT_DEFAULTPOR"
		end
	end
	return name
end
--[[------------------SPAGHETTICODE-------------------]]--