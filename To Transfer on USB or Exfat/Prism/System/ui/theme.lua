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
	selector   = C(52, 140, 255, 90),     -- the selection bar
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

	-- Layout: systems view. ------------------------------------------------------------
	header_h    = 34,
	footer_h    = 30,
	systems_col = { x = 0, w = 186 },        -- the left column of systems
	row_h       = 16,                        -- one list row (set from the font profile)
	detail      = { x = 200, w = 428 },      -- everything right of the column

	-- Layout: gamelist detailed view (inside "detail"). --------------------------------
	list_w      = 240,                       -- the game list
	cover       = { w = 170, h = 130 },      -- box art, top right
	screenshot  = { w = 170, h = 90 },       -- below the cover; the description follows

	-- Loading / launch screens. --------------------------------------------------------
	launch_box  = { x = 60, y = 90, w = 520, h = 270 },
}
