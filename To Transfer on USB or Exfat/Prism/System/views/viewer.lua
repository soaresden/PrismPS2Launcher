-- Prism PS2 Launcher - views/viewer.lua
-- One picture, as big as the screen allows, and left/right to walk round the others.
-- Square opens it on the selected game; the screenshot comes first because it is the
-- one that tells you what a game actually looks like, then the box, the cartridge and
-- the wheel, in that order, skipping whatever the scraper never found.

VIEWER = { game = nil, items = {}, sel = 1 }

--- The order they are offered in. Names are what the band at the bottom says. ---------
local VIEWER_ORDER = {
	{ kind = "screenshots", name = "Screenshot" },
	{ kind = "covers",      name = "Box art" },
	{ kind = "cartridges",  name = "Cartridge" },
	{ kind = "gamelogo",    name = "Game logo" },
}

--- Opens on a game. Returns false when it has nothing to show, so the caller can say
--- so rather than putting up an empty screen.
function viewer_open(g)
	if g == nil then return false end
	local items = {}
	for i = 1, #VIEWER_ORDER do
		local e = VIEWER_ORDER[i]
		local path = library_art(g, e.kind)
		if path ~= nil then
			items[#items + 1] = { path = path, name = e.name }
		end
	end
	if #items == 0 then return false end
	VIEWER.game, VIEWER.items, VIEWER.sel = g, items, 1
	VIEW = "viewer"
	input_flush()
	return true
end

function viewer_input()
	local n = #VIEWER.items
	if input_pressed("circle") or input_pressed("square") or input_pressed("cross") then
		play_sfx(S_CANCELAR)
		VIEW = "gamelist"
		input_flush()
		return
	end
	if n < 2 then return end
	if input_pressed("left") or input_pressed("l1") then
		play_sfx(S_MOVER)
		VIEWER.sel = VIEWER.sel - 1
		if VIEWER.sel < 1 then VIEWER.sel = n end
	elseif input_pressed("right") or input_pressed("r1") then
		play_sfx(S_MOVER)
		VIEWER.sel = VIEWER.sel + 1
		if VIEWER.sel > n then VIEWER.sel = 1 end
	end
end

function viewer_draw()
	local g = VIEWER.game
	local item = VIEWER.items[VIEWER.sel]
	if g == nil or item == nil then
		VIEW = "gamelist"
		return
	end

	-- Black behind, not the usual gradient: a picture is judged against black, and a
	-- blue wash under a box scan makes the whole thing look tinted.
	Screen.clear(Color.new(0, 0, 0))

	local top = gfx_top()
	local bottom = gfx_bottom()
	local head = 24
	local foot = 26
	local bx, by = THEME.pad, top + head
	local bw = 640 - 2 * THEME.pad
	local bh = (bottom - foot) - by - 4
	gfx_image_fit(item.path, bx, by, bw, bh)

	-- Which picture this is, and how many there are.
	gfx_text(gfx_fit(g.title, THEME.size_text, 440), THEME.pad, top + 4,
		THEME.size_text, THEME.text_head)
	gfx_text(item.name .."   ".. VIEWER.sel .." / ".. #VIEWER.items, 200, top + 6,
		THEME.size_small, THEME.text_dim, "right", 640 - 200 - THEME.pad)

	local hy = bottom - foot + 4
	local hx = THEME.pad
	if #VIEWER.items > 1 then
		hx = gfx_hint(hx, hy, "l1", "")
		hx = gfx_hint(hx, hy, "r1", "other pictures")
	end
	gfx_hint(hx, hy, "circle", "back")
end
