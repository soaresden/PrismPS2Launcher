-- Prism PS2 Launcher - ui/theme.lua
-- The one place that decides how the interface looks. Positions, sizes, colours,
-- fonts - the role theme.xml plays in EmulationStation. Nothing here is code that
-- runs; the views read this table. Coordinates are in a 640x448 space; PAL adds an
-- offset, see gfx.lua.
--
-- Colours: red, green, blue 0..255; alpha 0..128 (128 = opaque) on this platform.

local function C(r, g, b, a) return Color.new(r, g, b, a or 128) end

THEME = {
	-- Background: vertical gradient, PlayStation-X blue. ------------------------------
	bg_top     = C(14, 38, 92),
	bg_bottom  = C(4, 12, 36),

	-- Panels and bars. -----------------------------------------------------------------
	panel      = C(0, 0, 0, 60),          -- translucent black behind text areas
	panel_hi   = C(40, 80, 180, 60),      -- lighter panel (header)
	selector   = C(52, 140, 255, 90),     -- the selection bar; set by theme_selection()
	selector_edge = C(120, 200, 255, 128),
	line       = C(80, 120, 200, 128),    -- thin separators

	-- Text. ----------------------------------------------------------------------------
	text       = C(225, 230, 240),
	text_dim   = C(140, 150, 175),
	text_head  = C(255, 255, 255),
	text_sel   = C(255, 255, 255),
	shadow     = C(0, 0, 0, 90),

	-- Meaning colours: where a file lives, and whether it can run. --------------------
	exfat      = C(255, 205, 0),          -- yellow: the internal exFAT drive
	usb        = C(0, 200, 255),          -- cyan: a USB stick
	warn       = C(255, 70, 70),          -- red: nothing can open this
	ok         = C(90, 220, 120),

	-- Which PlayStation 1 emulator will run a game. Two emulators, two ways of storing
	-- the same disc, and the colour says which one you are looking at without reading.
	pops       = C(255, 120, 200),        -- pink: POPStarter, a .VCD
	ember      = C(255, 150, 60),         -- orange: Ember, a .cue/.bin folder

	-- PlayStation button colours, for the hints. ---------------------------------------
	btn_cross    = C(120, 170, 255),
	btn_circle   = C(255, 100, 100),
	btn_square   = C(230, 120, 235),
	btn_triangle = C(90, 220, 170),
	btn_neutral  = C(150, 150, 165),

	-- Fonts. -----------------------------------------------------------------------------
	-- The first entry whose file exists wins, and its sizes become the sizes below.
	-- So: to change the look of the whole interface, drop a .ttf in
	-- System/Medias/Font/ named UI.ttf. Delete it to go back to the shipped font.
	-- Nothing else to touch, and the repository still only carries PublicPixel.
	--
	-- proportional = false means a fixed-width pixel font. FreeType hints those onto
	-- whole pixels, so the advance per character is NOT proportional to the size
	-- (PublicPixel renders 7 wide at 8 px, and 13 wide at 12 px): every size used has
	-- to carry its measured advance in "adv". A normal font is measured per character
	-- instead - see char_rel() in ui/gfx.lua.
	fonts = {
		-- Yours, whatever it is. Never committed (see .gitignore): a font you own a
		-- licence for - VAG Rounded, Aptos Display, Sony's own SST - stays on your
		-- drive. Rename it UI.ttf and it wins over everything below.
		{ file = "System/Medias/Font/UI.ttf",
		  proportional = true,
		  title = 30, head = 18, text = 14, small = 11, row = 22 },
		-- The one Prism ships with when it is there: Dosis, SIL Open Font License,
		-- rounded and close in spirit to the PlayStation lettering. SemiBold, because
		-- thin strokes crawl on an interlaced TV.
		{ file = "System/Medias/Font/Dosis.ttf",
		  proportional = true,
		  title = 30, head = 18, text = 14, small = 11, row = 22 },
		-- Last resort, always present: the pixel font inherited from RETROLauncher.
		{ file = "System/Medias/Font/PublicPixel.ttf",
		  proportional = false,
		  title = 32, head = 16, text = 8, small = 8, row = 16,
		  adv = { [32] = 26, [16] = 13, [8] = 7 } },
	},
	-- Filled in by gfx_init() from the entry above; these are only the defaults it
	-- falls back on. Edit the profile, not these.
	font_file  = "System/Medias/Font/PublicPixel.ttf",
	proportional = false,
	size_title = 32,
	size_head  = 16,
	size_text  = 8,
	size_small = 8,
	char_adv   = { [32] = 26, [16] = 13, [8] = 7 },
	char_w     = 0.82,     -- fallback ratio for any size with no measured advance

	-- Layout. ----------------------------------------------------------------------------
	-- Three columns, as EmulationStation's detailed view has: the systems, the games,
	-- and everything known about the one game under the bar. 640 px wide, and a
	-- television eats the edges, so nothing important goes nearer than 10 px to them.
	header_h    = 26,
	footer_h    = 26,
	pad         = 10,
	systems_col = { x = 0, w = 170 },
	row_h       = 22,                        -- one list row (set from the font profile)
	list        = { x = 178, w = 200 },      -- the game list
	detail      = { x = 386, w = 244 },      -- the selected game, in four bands
	icon        = { w = 20, h = 16 },        -- console logo in a systems row

	-- The game column, top to bottom:
	--     A | title            a small picture beside the name
	--     ----------------
	--     B | C                two pictures side by side
	--     ----------------
	--     description
	--     ----------------
	--     where the saves go, and which memory card
	-- Which picture lands in A, B and C is a setting - cartridge, box art,
	-- screenshot or nothing. See ART_SLOTS in views/gamelist.lua.
	art_a       = 58,                        -- the square beside the title
	art_row     = 94,                        -- height of the B | C band
	saves_h     = 46,                        -- the band at the foot of the column

	-- The systems view keeps its own picture of the machine.
	shot        = { w = 244, h = 183 },
	cover       = { w = 112, h = 112 },

	-- Modal boxes: the main menu, the game menu, Ready to launch. ---------------------
	menu_box    = { w = 460, x = 90 },
	menu_row    = 26,
	menu_label  = 200,                       -- where the value column starts
	launch_box  = { x = 60, y = 80, w = 520, h = 284 },
}

--- The colour of the selection bar. ------------------------------------------------------
--- The bar is the one thing on screen the eye is always looking for, so it is the one
--- thing worth letting people choose. Each entry is the bar and its bright left edge;
--- the bar is translucent so whatever it sits on still shows through.
SELECTION_COLORS = {
	{ id = "blue",   name = "Blue",   bar = C(52, 140, 255, 90),  edge = C(120, 200, 255) },
	{ id = "green",  name = "Green",  bar = C(40, 180, 90, 90),   edge = C(120, 240, 160) },
	{ id = "yellow", name = "Yellow", bar = C(210, 170, 20, 95),  edge = C(255, 225, 90)  },
	{ id = "orange", name = "Orange", bar = C(225, 120, 30, 90),  edge = C(255, 180, 90)  },
	{ id = "red",    name = "Red",    bar = C(210, 50, 50, 90),   edge = C(255, 130, 130) },
	{ id = "pink",   name = "Pink",   bar = C(220, 70, 160, 90),  edge = C(255, 150, 215) },
	{ id = "purple", name = "Purple", bar = C(130, 80, 220, 90),  edge = C(190, 160, 255) },
	{ id = "white",  name = "White",  bar = C(210, 215, 225, 75), edge = C(255, 255, 255) },
	{ id = "grey",   name = "Graphite", bar = C(90, 95, 110, 95), edge = C(170, 175, 190) },
}

--- The same list, flattened, for the menu: ids to store, names to show.
SELECTION_IDS, SELECTION_NAMES = {}, {}
for i = 1, #SELECTION_COLORS do
	SELECTION_IDS[i] = SELECTION_COLORS[i].id
	SELECTION_NAMES[i] = SELECTION_COLORS[i].name
end

--- Applies one by id and returns its index; unknown ids leave the theme alone.
function theme_selection(id)
	for i = 1, #SELECTION_COLORS do
		local c = SELECTION_COLORS[i]
		if c.id == id then
			THEME.selector = c.bar
			THEME.selector_edge = c.edge
			return i
		end
	end
	return 1
end
