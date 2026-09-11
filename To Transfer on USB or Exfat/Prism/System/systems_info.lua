-- Prism PS2 Launcher - systems_info.lua
-- What systems.lua cannot know: the name people actually say, who made the machine,
-- the year it came out, and its logo. systems.lua is GENERATED from the cores' .info
-- files and must not be hand-edited; this file is the hand-written half, and the two
-- are joined by the folder name.
--
--   short   what the systems column shows after the folder name
--   maker   for sorting by manufacturer; falls back to the part of the libretro name
--           before the " - " when absent here
--   year    the machine's first release, for sorting by age. nil sorts last.
--   logo    a picture in System/Medias/Logos/, drawn small beside the name
--
-- A system missing from this table still works: it keeps its libretro name, sorts
-- under its parsed maker, and shows no icon.

SYSTEM_INFO = {
	-- Atari ------------------------------------------------------------------------------
	atari2600  = { short = "Atari 2600",      maker = "Atari",    year = 1977, logo = "Atari2600.png" },
	atari5200  = { short = "Atari 5200",      maker = "Atari",    year = 1982 },
	atari7800  = { short = "Atari 7800",      maker = "Atari",    year = 1986 },
	lynx       = { short = "Atari Lynx",      maker = "Atari",    year = 1989, logo = "AtariLynx.png" },
	jaguar     = { short = "Jaguar",          maker = "Atari",    year = 1993 },

	-- Nintendo ---------------------------------------------------------------------------
	nes        = { short = "NES",             maker = "Nintendo", year = 1983, logo = "Famicom.png" },
	fds        = { short = "Famicom Disk",    maker = "Nintendo", year = 1986, logo = "Famicom.png" },
	snes       = { short = "Super Nintendo",  maker = "Nintendo", year = 1990, logo = "SuperFamicom.png" },
	gb         = { short = "Game Boy",        maker = "Nintendo", year = 1989, logo = "GameBoy.png" },
	gbc        = { short = "Game Boy Color",  maker = "Nintendo", year = 1998, logo = "GameBoyColor.png" },
	gba        = { short = "Game Boy Advance",maker = "Nintendo", year = 2001, logo = "GameBoyAdvance.png" },
	virtualboy = { short = "Virtual Boy",     maker = "Nintendo", year = 1995 },
	pokemini   = { short = "Pokemon Mini",    maker = "Nintendo", year = 2001 },
	n64        = { short = "Nintendo 64",     maker = "Nintendo", year = 1996 },

	-- Sega -------------------------------------------------------------------------------
	sg1000       = { short = "SG-1000",       maker = "Sega",     year = 1983, logo = "SegaSG1000.png" },
	mastersystem = { short = "Master System", maker = "Sega",     year = 1985, logo = "MasterSystem.png" },
	megadrive    = { short = "Mega Drive",    maker = "Sega",     year = 1988, logo = "Megadrive.png" },
	gamegear     = { short = "Game Gear",     maker = "Sega",     year = 1990, logo = "GameGear.png" },
	segacd       = { short = "Mega-CD",       maker = "Sega",     year = 1991, logo = "Megadrive.png" },
	sega32x      = { short = "32X",           maker = "Sega",     year = 1994, logo = "Megadrive.png" },
	saturn       = { short = "Saturn",        maker = "Sega",     year = 1994 },

	-- Sony -------------------------------------------------------------------------------
	psx        = { short = "PlayStation",     maker = "Sony",     year = 1994, logo = "PlayStation.png" },
	ps2        = { short = "PlayStation 2",   maker = "Sony",     year = 2000, logo = "PlayStation2.png" },

	-- NEC, SNK, Bandai ---------------------------------------------------------------------
	pcengine   = { short = "PC Engine",       maker = "NEC",      year = 1987 },
	supergrafx = { short = "SuperGrafx",      maker = "NEC",      year = 1989 },
	pcfx       = { short = "PC-FX",           maker = "NEC",      year = 1994 },
	neogeo     = { short = "Neo Geo",         maker = "SNK",      year = 1990 },
	ngp        = { short = "Neo Geo Pocket",  maker = "SNK",      year = 1998, logo = "NeoGeoPocket.png" },
	ngpc       = { short = "Neo Geo Pocket Color", maker = "SNK", year = 1999, logo = "NeoGeoPocket.png" },
	wswan      = { short = "WonderSwan",      maker = "Bandai",   year = 1999 },
	wswanc     = { short = "WonderSwan Color",maker = "Bandai",   year = 2000 },

	-- Others -------------------------------------------------------------------------------
	colecovision  = { short = "ColecoVision",   maker = "Coleco",     year = 1982 },
	intellivision = { short = "Intellivision",  maker = "Mattel",     year = 1979 },
	vectrex       = { short = "Vectrex",        maker = "GCE",        year = 1982 },
	channelf      = { short = "Channel F",      maker = "Fairchild",  year = 1976 },
	odyssey2      = { short = "Odyssey 2",      maker = "Magnavox",   year = 1978 },
	arcadia       = { short = "Arcadia 2001",   maker = "Emerson",    year = 1982 },
	c64           = { short = "Commodore 64",   maker = "Commodore",  year = 1982 },
	amiga         = { short = "Amiga",          maker = "Commodore",  year = 1985 },
	amstradcpc    = { short = "Amstrad CPC",    maker = "Amstrad",    year = 1984 },
	zxspectrum    = { short = "ZX Spectrum",    maker = "Sinclair",   year = 1982 },
	zx81          = { short = "ZX81",           maker = "Sinclair",   year = 1981 },
	msx           = { short = "MSX",            maker = "Microsoft",  year = 1983 },
	msx2          = { short = "MSX2",           maker = "Microsoft",  year = 1985 },
	x1            = { short = "Sharp X1",       maker = "Sharp",      year = 1982 },

	-- Not machines, but they live in the same list ------------------------------------------
	apps       = { short = "Applications",    maker = "Homebrew", logo = "Apps.png" },
	arcade     = { short = "Arcade",          maker = "Arcade" },
	mame       = { short = "Arcade (MAME)",   maker = "Arcade" },
	fbneo      = { short = "Arcade (FBNeo)",  maker = "Arcade" },
	scummvm    = { short = "ScummVM",         maker = "PC" },
	dos        = { short = "DOS",             maker = "PC" },
}

--- What the systems view says about a machine. ----------------------------------------
--- Written here rather than copied from a theme: the PlayStation-X theme has beautiful
--- console sheets, and they are CC BY-NC-SA, which cannot travel inside a GPL project.
--- Facts are nobody's property; these sentences are ours.
---
---   cpu     the processor, because on these machines it IS the machine
---   units   how many were sold, rounded the way people say it
---   desc    two or three lines: what it was, what it was up against, what it left
SYSTEM_ABOUT = {
	atari2600 = { cpu = "MOS 6507 at 1.19 MHz", units = "30 million",
		desc = "The console that invented the cartridge, and very nearly ended the industry with it. Its 128 bytes of RAM forced programmers to draw the screen one scanline at a time, by hand, in step with the beam." },
	lynx = { cpu = "65SC02 at 4 MHz", units = "2 million",
		desc = "Atari's answer to the Game Boy: colour, backlit, and able to scale sprites in hardware, years before anyone else. It ate six batteries in four hours, and that was the end of it." },
	nes = { cpu = "Ricoh 2A03 at 1.79 MHz", units = "62 million",
		desc = "Sold as a toy to shops that would not touch another games machine after 1983, and it rebuilt the whole market. Nintendo's lockout chip is why the cartridge slot is shaped like that." },
	snes = { cpu = "Ricoh 5A22 at 3.58 MHz", units = "49 million",
		desc = "Sixteen bits, a colour palette nobody had seen on a television, and a sound chip designed by Sony. Its war with the Mega Drive is the one everyone who was there still argues about." },
	gb = { cpu = "Sharp LR35902 at 4.19 MHz", units = "119 million",
		desc = "Four shades of green and eight days of play on four AA batteries. It beat colour rivals by simply not needing to be plugged in, and Tetris did the rest." },
	gbc = { cpu = "Sharp LR35902 at 8.4 MHz", units = "(counted with the Game Boy)",
		desc = "The same machine, twice the clock and a real palette, still playing every cartridge that came before it. Eight years of back catalogue on day one." },
	gba = { cpu = "ARM7TDMI at 16.8 MHz", units = "81 million",
		desc = "A 32-bit ARM in a handheld, which is why so much of it still feels modern. The first model had no light at all: you held it under a lamp and complained." },
	megadrive = { cpu = "Motorola 68000 at 7.6 MHz", units = "34 million",
		desc = "Sega put an arcade processor in a home console and built a marketing campaign around saying so. Blast processing was nonsense; the 68000 was not." },
	mastersystem = { cpu = "Zilog Z80 at 3.58 MHz", units = "13 million",
		desc = "Better hardware than the NES and beaten by it everywhere except Brazil and Europe, where it outlived its own successor by a decade." },
	gamegear = { cpu = "Zilog Z80 at 3.58 MHz", units = "11 million",
		desc = "A Master System folded into a handheld, with a backlit colour screen and an appetite for six AA batteries every three hours." },
	sg1000 = { cpu = "Zilog Z80 at 3.58 MHz", units = "2 million",
		desc = "Sega's first home console, released the same day as the Famicom and buried by it. Its architecture survived, straight into the Master System." },
	ngp = { cpu = "Toshiba TLCS-900H at 6.14 MHz", units = "2 million",
		desc = "SNK's handheld, with the best directional stick ever put on one - a true microswitched click. It arrived as the Game Boy Color did, and lasted two years." },
	psx = { cpu = "MIPS R3000A at 33.9 MHz", units = "102 million",
		desc = "Born from a Nintendo CD add-on that Nintendo walked away from. It made 3D ordinary, made the CD the format, and sold to people who had never bought a console." },
	ps2 = { cpu = "Emotion Engine at 294 MHz", units = "155 million",
		desc = "The best-selling console ever made, and the machine this launcher runs on. It played DVDs, which in 2000 was reason enough on its own to own one." },
}

--- A colour per manufacturer, for the mark in the systems column. ----------------------
--- A console logo squeezed into 20x16 pixels is a smudge; a colour is read instantly
--- and groups the column the way the eye wants it grouped.
MAKER_COLOR = {
	Nintendo  = Color.new(228, 60, 60),
	Sega      = Color.new(60, 120, 230),
	Sony      = Color.new(190, 195, 205),
	Atari     = Color.new(235, 150, 40),
	SNK       = Color.new(235, 200, 60),
	NEC       = Color.new(120, 200, 140),
	Bandai    = Color.new(200, 110, 190),
	Homebrew  = Color.new(140, 150, 170),
	Arcade    = Color.new(240, 110, 80),
}

function system_color(s)
	if s.virtual == true then return THEME.exfat end
	return MAKER_COLOR[system_maker(s)] or THEME.text_dim
end

--- The photo of the machine: System/Medias/Consoles/<folder>.<png|jpg>. ---------------
--- Both extensions, because HelperScripts/GetConsolePhotos.ps1 saves whatever Wikimedia
--- serves and Enceladus reads BMP, JPG and PNG alike. Nothing is converted for nothing.
function system_photo(s)
	if s.virtual == true then return nil end
	local base = "System/Medias/Consoles/".. s.folder
	if doesFileExist(base ..".png") then return base ..".png" end
	if doesFileExist(base ..".jpg") then return base ..".jpg" end
	return nil
end

--- The name to show: short if known, else the part after "Maker - ". ------------------
function system_short_name(s)
	local info = SYSTEM_INFO[s.folder]
	if info ~= nil and info.short ~= nil then return info.short end
	return string.match(s.name or "", "^.-%s%-%s(.+)$") or s.name or s.folder
end

--- What the systems column shows: "lynx - Atari Lynx". The folder name comes first
--- because it is what you type on the PC when you put a game there: seeing it in the
--- interface is what tells you which folder a system is fed from.
function system_label(s)
	if s.virtual == true then return s.name end
	return s.folder .." - ".. system_short_name(s)
end

function system_maker(s)
	local info = SYSTEM_INFO[s.folder]
	if info ~= nil and info.maker ~= nil then return info.maker end
	return string.match(s.name or "", "^(.-)%s%-%s") or "Other"
end

function system_year(s)
	local info = SYSTEM_INFO[s.folder]
	if info ~= nil then return info.year end
	return nil
end

--- Path of the console logo, or nil. ---------------------------------------------------
function system_logo(s)
	if s.virtual == true then return nil end
	local info = SYSTEM_INFO[s.folder]
	if info == nil or info.logo == nil then return nil end
	return "System/Medias/Logos/".. info.logo
end
