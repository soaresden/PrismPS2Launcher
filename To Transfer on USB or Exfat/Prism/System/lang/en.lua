-- Prism PS2 Launcher - lang/en.lua
-- English: every text of the interface. Fills the TEXT_* tables.
-- Split from the original language.lua (RETROLauncher, Spaghetticode / Boon Tobias).

function lang_en(actual)
	if doesFileExist(actual .."/System/Defaults/ENG") == false then
		local lang_arc = System.openFile(actual .."/System/Defaults/ENG", FCREATE)
		System.closeFile(lang_arc)
	end
	-- Note. ------------------------------------------------------------------------
	-- Avoid using words or phrases that exceed the character limit of the originals, to avoid text outside the frame.
	-- ...? - It is a question that can vary, so it ends in another part of the code; in these cases, omit the "?" character at the end.
	-- \n - It's a line break, so there should be no space between them and the word that follows them.
	-- \" - It is used to escape a special character used by the code that could cause conflicts.

	-- General use texts. -----------------------------------------------------------
	TEXT_GEN = {
		"Quit"; -- 1
		"Off"; -- 2
		"On"; -- 3
		"Back"; -- 4
		"Select"; -- 5
		"Cancel"; -- 6
		"Exit"; -- 7
		"Change"; -- 8
		"No"; -- 9
		"Yes"; -- 10
		"Reset"; -- 11
		"Save"; -- 12
		"Enabled"; -- 13
		"Disabled"; -- 14
	};

	-- Settings menu for PS1 games. -------------------------------------------------
	TEXT_M_PS1 = {
		"Install \"CHEATS.TXT\" file"; -- 1
		"Searching for \"CHEATS.TXT\" files"; -- 2
		"Description"; -- 3
		"Code control"; -- 4
		"Save selected codes"; -- 5 ...?
		"Saving codes"; -- 6
		"Installing patches"; -- 7
		"Looking for patches"; -- 8
		"Loading game settings"; -- 9
		"Cleaning game settings"; -- 10
		"General use patches found"; -- 11
		"Patches with the same name will be replaced."; -- 12
		"Game patches found"; -- 13
		"All previous patches will be removed."; -- 14
		"Install patch"; -- 15
		"Name of the patch to be installed"; -- 16
		"Install"; -- 17
		"Install selected patches"; -- 18 ...?
		"Install patches for specific games"; -- 19
		"Install general patches"; -- 20
		"Extra settings"; -- 21
		"Clear game settings"; -- 22
		"Select the configuration type"; -- 23
		"Only patches"; -- 24
		"Only codes"; -- 25
		"All configurations"; -- 26
		"Clear selected settings"; -- 27 ...?
		"Clean"; -- 28
		"\"CHEATS.TXT\" of games found"; -- 29
		"The previous \"CHEATS.TXT\" will be deleted."; -- 30
		"Install \"CHEATS.TXT\" selected"; -- 31 ...?
		"\"CHEATS.TXT\" of the game to be installed"; -- 32
		"Installing \"CHEATS.TXT\""; -- 33
	};

	-- Descriptions for POPStarter options. -----------------------------------------
	TEXT_POPS_DESCR = {
		-- Description of codes for POPStarter. -------------------------------------
		"Disables the cheat engine and only activate\nit after POPS has left the PS1 OSD.\nShould be always ON."; -- 1
		"Enables the smooth texture mapping at\nstartup."; -- 2
		"Sets up the PFS wrapper USB delay.\nFor USB devices that have problems running\n\"POPStarter\"."; -- 3
		"Forces the activation of the PAL patcher\nand patches the region code to Euro.\nUseful for PAL VCDs that don’t have a valid\nlicense text in their bootsector."; -- 4
		"Disables POPStarters PAL patcher.\nNot meant to convert NTSC games to PAL."; -- 5
		"Centers the screen vertically.\nNo default value, depends on the game, you\nhave to experiment. The higher the value\nis, the more the screen moves down."; -- 6
		"Centers the screen horizontally.\nDefault value is 640; value lower than 640\nwill move the screen on the left, value\nhigher than 640 will move it to the right."; -- 7
		"Stretches the display horizontally to\nyour screen. Default value is 2559;\nincrease it to stretch the screen on the\nright, decrease it for the left."; -- 8
		"Reduces/expands the display area width.\nMaximum value is 2560; decrease it to crop\nthe screen on the right."; -- 9
		"Enables the scanlines generator.\nThe games are seen with this type of lines\nthat the old TVs and tube monitors had."; -- 10
		"The control remains in Digital Mode.\nEnables joystick support for games that\ndoesn’t support it natively."; -- 11
		"The control remains in Analog Mode.\nEnables joystick support for games that\ndoesn’t support it natively."; -- 12
		"Helps with the HDTVs that can’t deal with\nthe interlaced resolutions thru component.\nNot compatible with some CRT TVs."; -- 13
		"Mute VAB/VAG/VB+VH based sounds/music on\ngames. May be useful for these old games\nwhich output distorted SFX, wrong audio\nsamples or noises."; -- 14
		"Opens the IGR menu.\nCombination:\nL1 + L2 + R1 + R2 + X + DOWN"; -- 15
		"Opens the IGR menu.\nCombination:\nSELECT + START"; -- 16
		"Opens the IGR menu.\nCombination:\nL1 + L2 + R1 + R2 + SELECT + START"; -- 17
		"The \"IGR\" combination ends POPS\n(there is no \"IGR\" menu).\nCombination:\nL1 + L2 + R1 + R2 + X + DOWN"; -- 18
		"The \"IGR\" combination ends POPS\n(there is no \"IGR\" menu).\nCombination:\nSELECT + START"; -- 19
		"The \"IGR\" combination ends POPS\n(there is no \"IGR\" menu).\nCombination:\nL1 + L2 + R1 + R2 + SELECT + START"; -- 20
		"Disables the IGR menu."; -- 21
		"Loads a null LibCrypt magic word into the\ncop0 register. May be needed by some discs\nthat have a messed up LibCrypt protection."; -- 22
		"Enables POPS GTE widescreen hack and\nforces 16:9. Does not deal with stuff like\nHUDs, texts/fonts, menus, 2D backgrounds\n(This hack is not finished)."; -- 23
		"Same as WIDESCREEN, but wider field of\nvision. Does not deal with stuff like HUDs,\ntexts/fonts, menus, 2D backgrounds\n(This hack is not finished)."; -- 24
		"Same as WIDESCREEN, with 3×16:9 aspect\nratio. Does not deal with stuff like HUDs,\ntexts/fonts, menus, 2D backgrounds\n(This hack is not finished)."; -- 25
		"Force 480p. Not compatible with XPOS, YPOS,\nDWSTRETCH, or DWCROP.\nAvoid using it, it's unreliable."; -- 26
		"Use only \"Virtual Memory Card 1\"."; -- 27
		"Use only \"Virtual Memory Card 0\"."; -- 28
		"Prevents POPStarter from activating game\nfixes. This command may not work in some\ngames."; -- 29
		"Helps restoring the music/voices in several\ngames.\nDisable if using \".bin\" patches."; -- 30
		"A variant of mode 0×01, with a second hack\nfor not breaking the MDECoding of FMVs\n(was designed for the Colony Wars series).\nDisable if using \".bin\" patches."; -- 31
		"Can be used if the mode 0×01 doesn’t\nprovide the expected results.\nDisable if using \".bin\" patches."; -- 32
		"Fixes slowdowns, flickering, and many other\nglitches.\nDisable if using \".bin\" patches."; -- 33
		"Made for fixing the cutscenes of the\nResident Evil: Director’s Cut (PAL).\nDisable if using \".bin\" patches."; -- 34
		"Disables the OSD shell of the\nemulator’s built-in BIOS, making some games\nthat freeze on startup run.\nDisable if using \".bin\" patches."; -- 35
		-- Description of patches for POPStarter. -----------------------------------
		"Possibly fixes games with 3D/2D issues.\nHack / +4 brightness / DQA, DQB"; -- 36
		"Possibly fixes games with 3D/2D issues.\nHack / Normal brightness / DQA, DQB"; -- 37
		"Possibly fixes games with 3D/2D issues.\nHack / -4 brightness / DQA, DQB"; -- 38
		"Possibly fixes games with 3D/2D issues.\nHack / -16 brightness / DQA, DQB"; -- 39
		"Possibly fixes games with 3D/2D issues.\nHack / DQA, DQB"; -- 40
		"Possibly fixes games with 3D/2D issues.\nHack / IR0"; -- 41
		"Possibly fixes games with 3D/2D issues.\nThe most compatible and recommended."; -- 42
		"Fixes crashes at the Recompiler level\ninvery few cases, only when the problem is\nbad updating of the code in the recompiler\ninstruction cache."; -- 43
		"These mods prevent audio glitches.\nIt's recommended to use \"SPU_IRQ_ON_STABLE\",\nas it's the most stable; the audio will be\nskipped, so you won't hear it."; -- 44
		"This applies overclocks to the emulator,\nsupporting both PAL and NTSC.\nCaution:\nValues above +40 may cause save issues."; -- 45
		"No GPU overclocking. Required for some CPU\noverclocking combinations."; -- 46
		"It may fix some sections of the game, but\nits use should be compensated by\noverclocking. It is recommended that the\nGPU clock be 20% lower than the CPU clock."; -- 47
		"Disable Dithering, this is a special filter\nused in PS1 games."; -- 48
		"No description."; -- 49
	};

	-- Settings menu for PS2 games. -------------------------------------------------
	TEXT_M_PS2 = {
		"Search for game settings"; -- 1
		"Use virtual memory card"; -- 2
		"No virtual memory card"; -- 3
		"Compatibility modes"; -- 4
		"IOP: Fast Reads"; -- 5
		"Dummy"; -- 6
		"IOP: Sync Reads"; -- 7
		"EE : Unhook Syscalls"; -- 8
		"IOP: Emulate DVD-DL"; -- 9
		"IOP: Fix game buffer overrun"; -- 10
		"Graphics synthesizer mode"; -- 11
		"Force video mode"; -- 12
		"Compatibility mode"; -- 13
		"Unused"; -- 14
		"Save game settings"; -- 15
		"OPL"; -- 16
		"Neutrino"; -- 17
		"Virtual memory card not found"; -- 18
		"Saving game settings"; -- 19
		"Accurate Reads"; -- 20
		"Synchronous Reads"; -- 21
		"Unhook Syscalls"; -- 22
		"Skip videos"; -- 23
		"Emulate DVD-DL"; -- 24
		"Disable IGR"; -- 25
		"Horizontal adjustment"; -- 26
		"Vertical adjustment"; -- 27
		"Save settings?"; -- 28
		"WARNING:\nIt is recommended that you configure your games\nwithin \"OPL\", as there may be conflicts between\ndifferent versions of \"OPL\" and their\nconfiguration files."; -- 29
	};

	-- Browser menu. ----------------------------------------------------------------
	TEXT_M_EXP = {
		"The folder is empty or the files are not supported"; -- 1
		"No valid files"; -- 2
		"Items"; -- 3
	};

	-- Settings menu for Prism. ---------------------------------------------
	TEXT_M_CON = {
		"RGB Effect"; -- 1
		"Color in backgrounds"; -- 2
		"Fixed color in backgrounds"; -- 3
		"Red"; -- 4
		"Green"; -- 5
		"Blue"; -- 6
		"List style"; -- 7
		"Font type"; -- 8
		"Change the background"; -- 9
		"Clean GUI"; -- 10
		"Force garbage collection"; -- 11
		"Custom APP/ELF output"; -- 12
		"Directory"; -- 13
		"See full route in the APPS menu"; -- 14
		"Sound in the menu"; -- 15
		"Sound volume"; -- 16
		"Screenshot as background"; -- 17
		"Video mode"; -- 18
		"Vibration in menu"; -- 19
		"Extra directories"; -- 20
		"Reset all settings"; -- 21
		"Credits"; -- 22
		"Save settings"; -- 23
		"Page 1"; -- 24
		"Page 2"; -- 25
		"Unsaved changes. Do you want to exit?"; -- 26
		"All changes made will be lost upon reboot."; -- 27
		"Select search device"; -- 28
		"Search"; -- 29
		"Set width"; -- 30
		"Set height"; -- 31
		"Set text background"; -- 32
		"Set the start of the text scroll"; -- 33
		"Increase or decrease the minimum number of scrolls until the number \"0\" is visible next to the right frame of the color box."; -- 34
		"Text font setting"; -- 35
		"Try to fit all the text into the dark boxes"; -- 36
		"Try placing the \"0\" in the color box"; -- 37
		"Try to make the dark bar cover the text"; -- 38
		"Fixed text example"; -- 39
		"Default values"; -- 40
		"Set values"; -- 41
		"Release rest of lists?"; -- 42
		"When enabled, list movement will be smoother"; -- 43
		"at the cost of pauses in system changes."; -- 44
		"Disable \"wLaunchELF\"?"; -- 45
		"Please wait"; -- 46
		"Background music loop?"; -- 47
		"Use only if RetroArch has audio cuts or if"; -- 48
		"you have no other means to change the format"; -- 49
		"Reset"; -- 50 ...?
		"Deleting saved states?"; -- 51
		"Change video mode to"; -- 52 ...?
		"Reset all settings?"; -- 53
		"Standard"; -- 54
		"(enable debug colors)"; -- 55
		"Simple"; -- 56
		"Cover art"; -- 57
		"Full art"; -- 58
		"Big cover"; -- 59
		"Big art"; -- 60
		"Big list"; -- 61
		"Custom"; -- 62
		"Zoom level"; -- 63
		"Activate systems"; -- 64
		"Transparency"; -- 65
		"Transparency off"; -- 66
		"Select application"; -- 67
		"Select OPL version"; -- 68
		"(set by user)"; -- 69
		"Deleting saved states"; -- 70
		"Restarting"; -- 71
		"Changing video settings"; -- 72
		"Loading game lists and settings"; -- 73
		"Restarting all settings"; -- 74
		"W"; -- 75 Example for font configuration.
		"M"; -- 76 Example for font configuration.
		"Columns"; -- 77
		"Rows"; -- 78
		"Number of animations"; -- 79
		"Rename image for auto-configuration"; -- 80 ...?
		"Current name"; -- 81
		"New name"; -- 82
		"POPStarter setup"; -- 83
		"\"IGR\" exits to \"OSDSYS\""; -- 84
		"Disable \"Dithering\" in games"; -- 85
		"Install translation in \"IGR\""; -- 86
		"Configure layer animation"; -- 87
		"Type of animation"; -- 88
		"Animation speed"; -- 89
		"Speed multiplier"; -- 90
		"Type of transparency"; -- 91
		"Level of transparency"; -- 92
		"Transparency speed"; -- 93
		"Type of rotation"; -- 94
		"Rotation speed"; -- 95
		"Affected layers"; -- 96
		"Turn right"; -- 97
		"Turn left"; -- 98
		"Alternate\ndirection"; -- 99
		"Fixed\ntransparency"; -- 100
		"Alternate\nminimum/maximum"; -- 101
		"Alternate\nhalf/maximum"; -- 102
		"Alternate layers\nminimum/maximum"; -- 103
		"Alternate layers\nhalf/maximum"; -- 104
		"Show game indexes?"; -- 105
		"Sprite configuration"; -- 106
		"Enable sprites in the menu"; -- 107
		"Sprite corresponding to"; -- 108
		"Type of animation"; -- 109
		"Animation speed"; -- 110
		"Transparencies in animation"; -- 111
		"Rotations in animation"; -- 112
		"Flip sprites"; -- 113
		"White"; -- 114
		"Radius size"; -- 115
		"Select settings menu"; -- 116
		"Style editor"; -- 117
		"Sprite configuration"; -- 118
		"Transparency of screenshots"; -- 119
		"Always show the alternative execution menu"; -- 120
		"Color of the shadows behind the elements"; -- 121
	};

	-- Nombre de los estilos de animación para los sprites. -------------------------
	TEXT_SPR_T = {
		"Still\nsprite"; -- 1
		"Move right\non the\nhorizontal\naxis"; -- 2
		"Move left\non the\nhorizontal\naxis"; -- 3
		"Move right\non the\nhorizonta\naxis\n+zigzag on\nthe vertical\naxis (short)"; -- 4
		"Move left\non the\nhorizontal\naxis\n+zigzag on\nthe vertical\naxis (short)"; -- 5
		"Move right\non the\nhorizontal\naxis\n+zigzag on\nthe vertical\naxis (long)"; -- 6
		"Move left\non the\nhorizontal\naxis\n+zigzag on\nthe vertical\naxis (long)"; -- 7
		"Move from\nright to\nleft on the\nhorizontal\naxis (short)"; -- 8
		"Move from\nright to\nleft on the\nhorizontal\naxis (half)"; -- 9
		"Move from\nright to\nleft on the\nhorizontal\naxis (long)"; -- 10
		"Move from\nright to\nleft on the\nhorizontal\naxis (short)\n+zigzag on\nthe vertical\naxis"; -- 11
		"Move from\nright to\nleft on the\nhorizontal\naxis (half)\n+zigzag on\nthe vertical\naxis"; -- 12
		"Move from\nright to\nleft on the\nhorizontal\naxis (long)\n+zigzag on\nthe vertical\naxis"; -- 13
		"Go down on\nthe vertical\naxis"; -- 14
		"Climb on the\nvertical axis"; -- 15
		"Go down on\nthe vertical\naxis\n+zigzag\non the\nhorizontal\naxis (short)"; -- 16
		"Climb on the\nvertical axis\n+zigzag\non the\nhorizontal\naxis (short)"; -- 17
		"Go down on\nthe vertical\naxis\n+zigzag\non the\nhorizontal\naxis (long)"; -- 18
		"Climb on the\nvertical axis\n+zigzag\non the\nhorizontal\naxis (long)"; -- 19
		"Going up\nand down on\nthe vertical\naxis (short)"; -- 20
		"Going up\nand down on\nthe vertical\naxis (half)"; -- 21
		"Going up\nand down on\nthe vertical\naxis (long)"; -- 22
		"Going up\nand down on\nthe vertical\naxis (short)\n+zigzag\non the\nhorizontal\naxis"; -- 23
		"Going up\nand down on\nthe vertical\naxis (half)\n+zigzag\non the\nhorizontal\naxis"; -- 24
		"Going up\nand down on\nthe vertical\naxis (long)\n+zigzag\non the\nhorizontal\naxis"; -- 25
		"Acceleration\nwhen going\ndown to the\nright"; -- 26
		"Acceleration\nwhen going\ndown to the\nleft"; -- 27
		"Acceleration\nwhen going\nup the right"; -- 28
		"Acceleration\nwhen going\nup on the\nleft"; -- 29
		"Acceleration\nfrom right\nto left"; -- 30
		"Acceleration\nfrom left\nto right"; -- 31
		"Acceleration\nfrom right\nto left\n+change in\nthe vertical\naxis"; -- 32
		"Acceleration\nfrom left\nto right\n+change in\nthe vertical\naxis"; -- 33
		"Decelerate\nfrom right\nto left"; -- 34
		"Decelerate\nfrom left\nto right"; -- 35
		"Acceleration\nwhen going\ndown to the\nleft"; -- 36
		"Acceleration\nwhen going\nup on the\nleft"; -- 37
		"Acceleration\nwhen going\ndown to the\nright"; -- 38
		"Acceleration\nwhen going\nup the right"; -- 39
		"Acceleration\non downhill"; -- 40
		"Acceleration\non the\nupwards"; -- 41
		"Acceleration\non downhill\n+change\nin the\nhorizontal\naxis"; -- 42
		"Acceleration\non the\nupwards\n+change\nin the\nhorizontal\naxis"; -- 43
		"Slow\ndownwards"; -- 44
		"Slow down\nwhen going\nup"; -- 45
		"Floating\ndiagonal\nversion 1"; -- 46
		"Floating\ndiagonal\nversion 2"; -- 47
		"Diagonal\ndown right"; -- 48
		"Diagonal\ndown left"; -- 49
		"Diagonal\nupper right"; -- 50
		"Diagonal\nupper left"; -- 51
		"Move around\nthe screen\nclockwise"; -- 52
		"Move around\nthe screen\ncounter\nclockwise"; -- 53
		"Going around\nin circles\nclockwise\n(short)"; -- 54
		"Going around\nin circles\ncounter\nclockwise\n(short)"; -- 55
		"Going around\nin circles\nclockwise\n(half)"; -- 56
		"Going around\nin circles\ncounter\nclockwise\n(half)"; -- 57
		"Going around\nin circles\nclockwise in\nfull screen"; -- 58
		"Going around\nin circles\ncounter\nclockwise in\nfull screen"; -- 59
		"Bounce\naround\nthe screen"; -- 60
		"Zoom in\n(short)"; -- 61
		"Zoom in\n(half)"; -- 62
		"Control\nsprite\nwith the\nright stick"; -- 63
		"Set level of\ntransparency"; -- 64
		"Alternate\nbetween\nminimum and\nmaximum"; -- 65
		"Alternate\nbetween\nhalf and\nmaximum"; -- 66
		"Reflect the\nhorizontal\naxis\naccording to\nthe movement"; -- 67
		"Reflect the\nvertical\naxis\naccording to\nthe movement"; -- 68
		"Reflect\nboth axes\naccording to\nthe movement"; -- 69
		"Manually\nreflect the\nhorizontal\naxis through\nthe right\nstick"; -- 70
		"Manually\nreflect the\nvertical\naxis through\nthe right\nstick"; -- 71
		"Manually\nreflect both\naxes via the\nright stick"; -- 72
		"Fix the\nreflex\non the\nhorizontal\naxis"; -- 73
		"Fix the\nreflex\non the\nvertical\naxis"; -- 74
		"Fix the\nreflex\non both axes"; -- 75
		"Enter the\nnumber of\ncolumns that\ncontain\nthe image\n(vertical)"; -- 76
		"Enter the\nnumber of\nrows\ncontaining\nthe image\n(horizontal)"; -- 77
	};

	-- Names of the animation styles for the layers. --------------------------------
	TEXT_LAY_T = {
		"Fixed layers"; -- 1
		"Right\nhorizontal v1"; -- 2
		"Left\nhorizontal v1"; -- 3
		"Right zigzag\nvertical"; -- 4
		"Left zigzag\nvertical"; -- 5
		"Right\nfrontal"; -- 6
		"Left\nfrontal"; -- 7
		"Center zigzag\nhorizontal v1"; -- 8
		"Right\nhorizontal v2"; -- 9
		"Left\nhorizontal v2"; -- 10
		"Left\nfrontal v2"; -- 11
		"Right\nfrontal v2"; -- 12
		"Right\nfrontal v3"; -- 13
		"Left\nfrontal v3"; -- 14
		"Right\npanoramic v1"; -- 15
		"Left\npanoramic v1"; -- 16
		"Right\npanoramic v2"; -- 17
		"Left\npanoramic v2"; -- 18
		"Cross\nhorizontal"; -- 19
		"Center zigzag\nhorizontal v2"; -- 20
		"Down\nvertical v1"; -- 21
		"Up\nvertical v1"; -- 22
		"Down zigzag\nhorizontal"; -- 23
		"Up zigzag\nhorizontal"; -- 24
		"Up\nfrontal v1"; -- 25
		"Down\nfrontal v1"; -- 26
		"Center zigzag\nvertical v1"; -- 27
		"Down\nvertical v2"; -- 28
		"Up\nvertical v2"; -- 29
		"Up\nfrontal v2"; -- 30
		"Down\nfrontal v2"; -- 31
		"Up\nfrontal v3"; -- 32
		"Down\nfrontal v3"; -- 33
		"Panoramic\ndown v1"; -- 34
		"Panoramic\nup v1"; -- 35
		"Panoramic\ndown v2"; -- 36
		"Panoramic\nup v2"; -- 37
		"Cross\nvertical"; -- 38
		"Center zigzag\nvertical v2"; -- 39
		"Right\nwhirl"; -- 40
		"Left\nwhirl"; -- 41
		"Zoom 3-4\nPixel zoom"; -- 42
		"Zoom 1-2\nPixel zoom"; -- 43
		"Zoom 2-3\nPixel zoom"; -- 44
		"Zoom 1-4\nPixel zoom"; -- 45
		"Zoom 1-3-4\nPixel zoom"; -- 46
		"Zoom 1-2-3\nPixel zoom"; -- 47
		"Zoom 2-3-4\nPixel zoom"; -- 48
		"Zoom 1-2-4\nPixel zoom"; -- 49
		"Zoom 1-2-3-4\nPixel zoom"; -- 50
		"Zoom 3-4 v2\nPixel zoom"; -- 51
		"Zoom 1-2 v2\nPixel zoom"; -- 52
		"Zoom 2-3 v2\nPixel zoom"; -- 53
		"Zoom 1-4 v2\nPixel zoom"; -- 54
		"Zoom 1-3-4 v2\nPixel zoom"; -- 55
		"Zoom 1-2-3 v2\nPixel zoom"; -- 56
		"Zoom 2-3-4 v2\nPixel zoom"; -- 57
		"Zoom 1-2-4 v2\nPixel zoom"; -- 58
		"Zoom 1-2-3-4 v2\nPixel zoom"; -- 59
		"Right\nhorizontal v3"; -- 60
		"Left\nhorizontal v3"; -- 61
		"Down\nvertical v3"; -- 62
		"Up\nvertical v3"; -- 63
	};

	-- Style editor menu. -----------------------------------------------------------
	TEXT_M_STI = {
		"Example of game name.zip"; -- 1
		"Center / Example of game name.zip"; -- 2
		"Right / Example of game name.zip"; -- 3
		"Left / Example of game name.zip"; -- 4
		"Found games"; -- 5
		"Press to exit"; -- 6
		"Press to config"; -- 7
		"Change art"; -- 8
		"Full screen"; -- 9
		"Run game"; -- 10
		"Update list"; -- 11
		"List"; -- 12
		"Art"; -- 13
		"Extra art"; -- 14
		"Cover flow"; -- 15
		"Logo"; -- 16
		"Cross button"; -- 17
		"Triangle button"; -- 18
		"Square button"; -- 19
		"L1 button"; -- 20
		"R1 button"; -- 21
		"R3 button"; -- 22
		"START button"; -- 23
		"SELECT button"; -- 24
		"Transition type"; -- 25
		"Transition speed"; -- 26
		"Restore all items"; -- 27
		"Save style"; -- 28
		"Exit edit menu"; -- 29
		"Lock item"; -- 30
		"Line guide"; -- 31
		"Position"; -- 32
		"Resize"; -- 33
		"Pixels"; -- 34
		"Restore"; -- 35
		"Next item"; -- 36
		"Prev item"; -- 37
		"Help"; -- 38
		"Menu item"; -- 39
		"Save style"; -- 40
		"Menu"; -- 41
		"Pixels"; -- 42
		"Activate elements"; -- 43
		"Shadow"; -- 44
		"Extra options"; -- 45
		"Reset all elements?"; -- 46
		"Save changes?"; -- 47
		"When saving, if a previous configuration\nexists, a backup of it will be created\n(replacing the last backup if it exists)."; -- 48
	};

	-- Main menu. -------------------------------------------------------------------
	TEXT_M_PRI = {
		"-Loading Art-"; -- 1
		"Press to exit"; -- 2
		"Press to config"; -- 3
		"Change art"; -- 4
		"Full screen"; -- 5
		"Run game"; -- 6
		"Update list"; -- 7
		"Game settings"; -- 8
		"Menu"; -- 9
		"Art"; -- 10
		"Zoom"; -- 11
		"Play"; -- 12
		"Loading"; -- 13
		"No games found"; -- 14
		"Error!"; -- 15
		"Games or RetroArch"; -- 16
		"Application or ELF"; -- 17
		"POPS or Binaries"; -- 18
		"Neutrino/OPL or ISO"; -- 19
		"Not found!"; -- 20
		"Found games"; -- 21
		"Found APPS"; -- 22
		"Reset Prism?"; -- 23
		"Quit Prism?"; -- 24
		"WARNING!"; -- 25
		"All RetroArch options will reset"; -- 26
		"-Loading Art-"; -- 27
		"Where to create the game executable?"; -- 28
		"Directory \"POPS\""; -- 29
		"Directory \"APPS\""; -- 30
		"Game setup"; -- 31
		"Alternative"; -- 32
		"Variant"; -- 33
		"Explorer"; -- 34
		"Select the device to examine"; -- 35
		"Ember or Bios/CUE"; -- 36
	};

	-- Relocation Menu. -------------------------------------------------------------
	TEXT_M_REL = {
		"WARNING\nThis program was created to run from the first\nport (USB) of PS2.\nPlease, reconnect the USB to the first port and\nrestart the program."; -- 1
		"WARNING\nA device was detected on the second port (USB).\nPlease, disconnect the USB from the second port\nand restart the program."; -- 2
		"The current directory does not match\nyour configuration.\nDo you want to relocate the\nconfigurations to this directory?\nWARNING!\nAll RetroArch Options will reset"; -- 3
		"Relocate"; -- 4
		"Relocating"; -- 5
		"Relocating all settings"; -- 6
	};
end
