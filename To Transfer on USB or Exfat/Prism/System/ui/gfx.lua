-- Prism PS2 Launcher - ui/gfx.lua
-- Drawing helpers over the Enceladus Graphics/Font API. Everything the views draw
-- goes through here, so the theme is applied in one place and the PAL offset too.

GFX = {
	w = 640, h = 448,   -- logical size; set_screen() updates them
	pal_y = 0,          -- vertical offset when the real screen is 512 high
	font_head = nil, font_text = nil, font_small = nil,
	cache = {},         -- path -> image, for the pictures currently on screen
	cache_order = {},
	cache_max = 12,
}

--- Fonts: the first profile in THEME.fonts whose file exists wins, and its sizes
--- become the theme's sizes - that is how dropping a .ttf into System/Medias/Font/
--- changes the whole interface. One FreeType handle per size (ftSetPixelSize is per
--- handle). Called ONCE, by the boot screen: Font.ftInit() a second time would
--- invalidate every handle made before it, so nothing else may call this.
function gfx_init()
	if GFX.font_text ~= nil then return end

	local p = nil
	for i = 1, #THEME.fonts do
		if p == nil and doesFileExist(THEME.fonts[i].file) then p = THEME.fonts[i] end
	end
	if p == nil then p = THEME.fonts[#THEME.fonts] end
	THEME.font_file    = p.file
	THEME.proportional = (p.proportional == true)
	THEME.size_title   = p.title
	THEME.size_head    = p.head
	THEME.size_text    = p.text
	THEME.size_small   = p.small
	THEME.row_h        = p.row or THEME.row_h
	THEME.char_adv     = p.adv or {}
	if boot_log ~= nil then
		boot_log("BOOT   font ".. p.file .."  sizes ".. p.title .."/".. p.head
			.."/".. p.text .."/".. p.small)
	end

	Font.ftInit()
	GFX.font_title = Font.ftLoad(p.file)
	Font.ftSetPixelSize(GFX.font_title, p.title, p.title)
	GFX.font_head  = Font.ftLoad(p.file)
	Font.ftSetPixelSize(GFX.font_head, p.head, p.head)
	GFX.font_text  = Font.ftLoad(p.file)
	Font.ftSetPixelSize(GFX.font_text, p.text, p.text)
	GFX.font_small = Font.ftLoad(p.file)
	Font.ftSetPixelSize(GFX.font_small, p.small, p.small)
end

--- Real screen size. Layout stays 640x448 and is centred vertically on PAL. ----------
function gfx_set_screen(w, h)
	GFX.w, GFX.h = w, h
	GFX.pal_y = (h - 448) // 2
end

--- The real edges of the screen, in layout coordinates. -------------------------------
--- PAL draws 512 lines, the layout is 448, so it is centred and 32 pixels are left over
--- at each end. Anything that should sit ON an edge - the header, the footer, the
--- credits at the foot of the boot screen - has to ask for the real edge, or it floats
--- with a band of background under it that looks like a mistake, because it is one.
--- NTSC: top 0, bottom 448. PAL: top -32, bottom 480.
function gfx_top()
	return -GFX.pal_y
end

function gfx_bottom()
	return GFX.h - GFX.pal_y
end

--- Average character width at a size: the measured advance for a pixel font, a
--- deliberately generous estimate for a proportional one (over-estimating makes text
--- wrap early, under-estimating makes it run out of its box).
function gfx_char_w(size)
	local adv = THEME.char_adv[size]
	if adv ~= nil then return adv end
	if THEME.proportional == true then return size * 0.62 end
	return size * THEME.char_w
end

--- Relative advance of one character, as a fraction of the pixel size, for a normal
--- proportional font. SST, Inter and Roboto sit within a few percent of these. It only
--- decides where a string is cut and how it is centred; FreeType does the real spacing.
local NARROW = "iltjfIr.,:;'!|()[]{}/\\"
local WIDE   = "mwMW@%"
local CAPS   = "ABCDEFGHJKLNOPQRSTUVXYZ0123456789#$&+="

--- Rounded up on purpose. An over-estimate cuts a string one letter early and nudges a
--- centred one a pixel left; an under-estimate lets text walk off the screen, which is
--- what the first pass did to the credits line on the boot screen.
local function char_rel(ch)
	if ch == " " then return 0.34 end
	if string.find(NARROW, ch, 1, true) ~= nil then return 0.40 end
	if string.find(WIDE, ch, 1, true) ~= nil then return 1.00 end
	if string.find(CAPS, ch, 1, true) ~= nil then return 0.74 end
	return 0.66
end

--- Width of a string in pixels. Fixed-width fonts take the fast path. ----------------
function gfx_text_w(text, size)
	text = tostring(text or "")
	if THEME.proportional ~= true then
		return string.len(text) * gfx_char_w(size)
	end
	local w = 0
	for i = 1, string.len(text) do
		w = w + char_rel(string.sub(text, i, i)) * size
	end
	return w
end

--- Text that fits in "width" pixels, cut with a "~" if needed. ----------------------
function gfx_fit(text, size, width)
	text = tostring(text or "")
	if THEME.proportional ~= true then
		local maxc = math.floor(width / gfx_char_w(size))
		if maxc < 1 then return "" end
		if string.len(text) <= maxc then return text end
		if maxc <= 2 then return string.sub(text, 1, maxc) end
		return string.sub(text, 1, maxc - 2) .."~"
	end
	if gfx_text_w(text, size) <= width then return text end
	local room = width - char_rel("~") * size
	local w, n = 0, 0
	for i = 1, string.len(text) do
		local cw = char_rel(string.sub(text, i, i)) * size
		if w + cw > room then break end
		w = w + cw
		n = i
	end
	if n == 0 then return "" end
	return string.sub(text, 1, n) .."~"
end

--- Cut to fit, with no mark. For the scrolling window below, where a "~" would be a
--- letter of the text itself.
function gfx_clip(text, size, width)
	text = tostring(text or "")
	if gfx_text_w(text, size) <= width then return text end
	local w, n = 0, 0
	for i = 1, string.len(text) do
		local cw = gfx_char_w(size)
		if THEME.proportional == true then cw = char_rel(string.sub(text, i, i)) * size end
		if w + cw > width then break end
		w = w + cw
		n = i
	end
	return string.sub(text, 1, n)
end

--- A line that scrolls, right to left, for ever, when it does not fit. ----------------
--- It moves a letter at a time rather than a pixel at a time, and for a reason:
--- Font.ftPrint has no clipping rectangle, so a string drawn at a fractional offset
--- would spill over whatever is beside it. Sliding the WINDOW over the string instead
--- of the string under a window keeps every pixel inside the box. The text is wrapped
--- with a separator so the end runs into the beginning without looking like a glitch.
GFX.frame = 0
SCROLL_FRAMES = 3                  -- frames per character; 3 is ~16 letters a second
SCROLL_GAP = "     ---     "
SCROLL_SPEEDS = { slow = 7, normal = 5, fast = 3, faster = 2 }
SCROLL_MODES  = { "slow", "normal", "fast", "faster" }
SCROLL_LABELS = { "Slow", "Normal", "Fast", "Very fast" }

function gfx_scroll_speed(name)
	SCROLL_FRAMES = SCROLL_SPEEDS[name] or 3
end

function gfx_tick()
	GFX.frame = GFX.frame + 1
end

function gfx_text_scroll(text, x, y, size, color, width)
	text = tostring(text or "")
	if text == "" then return end
	if gfx_text_w(text, size) <= width then
		gfx_text(text, x, y, size, color)
		return
	end
	local padded = text .. SCROLL_GAP
	local n = string.len(padded)
	local off = math.floor(GFX.frame / SCROLL_FRAMES) % n
	gfx_text(gfx_clip(string.sub(padded, off + 1) .. string.sub(padded, 1, off), size, width),
		x, y, size, color)
end

--- Word-wrap text into at most max_lines lines of "width" pixels. ----------------------
function gfx_wrap(text, size, width, max_lines)
	local lines = {}
	text = tostring(text or "")
	local maxc = math.floor(width / gfx_char_w(size))
	if maxc < 4 then return lines end
	local line, cut = "", false
	for word in string.gmatch(text, "%S+") do
		if #lines >= max_lines then cut = true; break end
		if line == "" then
			line = word
		elseif string.len(line) + 1 + string.len(word) <= maxc then
			line = line .." ".. word
		else
			lines[#lines + 1] = line
			line = word
		end
		while string.len(line) > maxc and #lines < max_lines do
			lines[#lines + 1] = string.sub(line, 1, maxc)
			line = string.sub(line, maxc + 1)
		end
	end
	if line ~= "" then
		if #lines < max_lines then lines[#lines + 1] = line else cut = true end
	end
	if cut and #lines > 0 then
		local last = lines[#lines]
		if string.len(last) > maxc - 1 then last = string.sub(last, 1, maxc - 1) end
		lines[#lines] = last .."~"
	end
	return lines
end

--- Draw text. size picks the font; x, y are the top-left of the text box. ----------
--- align: "left" (default), "center" or "right" relative to x (or the box x..x+width).
function gfx_text(text, x, y, size, color, align, width)
	text = tostring(text or "")
	if text == "" then return end
	local font = GFX.font_text
	if size == THEME.size_head then font = GFX.font_head
	elseif size == THEME.size_small then font = GFX.font_small
	elseif size == THEME.size_title then font = GFX.font_title end
	if font == nil then return end
	-- Centring is handed to FreeType rather than computed here. Our width estimate is
	-- good enough to decide where to CUT a string, but not to place it to the pixel,
	-- and a title that sits thirty pixels left of its logo is the proof. Align 8 with
	-- x at the middle of the box is what the original launcher used for its centred
	-- text, and it measures the real glyphs.
	if align == "center" then
		Font.ftPrint(font, math.floor(x + (width or 0) / 2), math.floor(y + GFX.pal_y),
			8, math.floor(width or 640), 48, text, color or THEME.text)
		return
	end
	local tw = gfx_text_w(text, size)
	if align == "right" then
		x = x + (width or 0) - tw
	end
	Font.ftPrint(font, math.floor(x), math.floor(y + GFX.pal_y), 0, 640, 48, text, color or THEME.text)
end

--- Text with a drop shadow, for anything drawn over a picture. --------------------
function gfx_text_shadow(text, x, y, size, color, align, width)
	gfx_text(text, x + 1, y + 1, size, THEME.shadow, align, width)
	gfx_text(text, x, y, size, color, align, width)
end

--- Filled rectangle in layout space. ---------------------------------------------------
function gfx_rect(x, y, w, h, color)
	Graphics.drawRect(x, y + GFX.pal_y, w, h, color)
end

--- Rectangle outline, one pixel. -----------------------------------------------------
function gfx_frame(x, y, w, h, color)
	gfx_rect(x, y, w, 1, color)
	gfx_rect(x, y + h - 1, w, 1, color)
	gfx_rect(x, y, 1, h, color)
	gfx_rect(x + w - 1, y, 1, h, color)
end

--- The background: a vertical gradient over the whole real screen. -------------------
function gfx_background()
	Screen.clear(THEME.bg_bottom)
	Graphics.drawQuad(0, 0, GFX.w, 0, GFX.w, GFX.h, 0, GFX.h,
		THEME.bg_top, THEME.bg_top, THEME.bg_bottom, THEME.bg_bottom)
end

--- Images: a small cache so moving through a list does not reload the same art. ------
function gfx_image(path)
	if path == nil then return nil end
	local img = GFX.cache[path]
	if img ~= nil then return img end
	if doesFileExist(path) == false then return nil end
	local ok, loaded = pcall(Graphics.loadImage, path)
	if ok == false or loaded == nil then return nil end
	GFX.cache[path] = loaded
	GFX.cache_order[#GFX.cache_order + 1] = path
	if #GFX.cache_order > GFX.cache_max then
		local old = table.remove(GFX.cache_order, 1)
		if GFX.cache[old] ~= nil then
			pcall(Graphics.freeImage, GFX.cache[old])
			GFX.cache[old] = nil
		end
	end
	return loaded
end

function gfx_free_images()
	for i = 1, #GFX.cache_order do
		local p = GFX.cache_order[i]
		if GFX.cache[p] ~= nil then pcall(Graphics.freeImage, GFX.cache[p]) end
	end
	GFX.cache, GFX.cache_order = {}, {}
end

--- Draw an image scaled to fit inside a box, keeping its aspect, centred. ------------
--- Returns true if something was drawn.
function gfx_image_fit(path, x, y, w, h)
	local img = gfx_image(path)
	if img == nil then return false end
	local iw, ih = Graphics.getImageWidth(img), Graphics.getImageHeight(img)
	if iw == nil or ih == nil or iw <= 0 or ih <= 0 then return false end
	local s = math.min(w / iw, h / ih)
	local dw, dh = math.floor(iw * s), math.floor(ih * s)
	local dx, dy = x + math.floor((w - dw) / 2), y + math.floor((h - dh) / 2)
	Graphics.drawScaleImage(img, dx, dy + GFX.pal_y, dw, dh)
	return true
end

--- The real pad buttons, redrawn for Prism in System/Medias/Pads/psx/. ---------------
--- A coloured square with a letter in it is what you draw when you have no picture;
--- these are the shapes people have known since 1994, and they are read without being
--- read. Anything not in this table falls back to a pill with its name written in it,
--- which is what L3, or a key on a USB keyboard, gets.
BUTTON_ICON = {
	cross    = "System/Medias/Pads/psx/ps-cross.png",
	circle   = "System/Medias/Pads/psx/ps-circle.png",
	square   = "System/Medias/Pads/psx/ps-square.png",
	triangle = "System/Medias/Pads/psx/ps-triangle.png",
	l1       = "System/Medias/Pads/psx/ps-l1.png",
	l2       = "System/Medias/Pads/psx/ps-l2.png",
	l3       = "System/Medias/Pads/psx/ps-l3.png",
	r1       = "System/Medias/Pads/psx/ps-r1.png",
	r2       = "System/Medias/Pads/psx/ps-r2.png",
	r3       = "System/Medias/Pads/psx/ps-r3.png",
	start    = "System/Medias/Pads/psx/ps-start.png",
	select   = "System/Medias/Pads/psx/ps-select.png",
}

--- A button hint: the button, then what it does. -------------------------------------
--- Returns the x after the hint, so a row of them lays itself out.
function gfx_hint(x, y, button, label)
	local size = THEME.size_small
	local key = string.lower(tostring(button))
	local d = 18
	local icon = BUTTON_ICON[key]
	if icon ~= nil and gfx_image_fit(icon, x, y - 1, d, d) then
		-- drawn
	else
		local colors = {
			cross = THEME.btn_cross, circle = THEME.btn_circle,
			square = THEME.btn_square, triangle = THEME.btn_triangle,
		}
		local c = colors[key] or THEME.btn_neutral
		local name = string.upper(tostring(button))
		d = math.floor(gfx_text_w(name, size)) + 10
		gfx_rect(x, y, d, 16, c)
		gfx_text(name, x, y + 3, size, THEME.text_head, "center", d)
	end
	local lx = x + d + 4
	if label == nil or label == "" then return lx end
	gfx_text(label, lx, y + 3, size, THEME.text)
	return lx + gfx_text_w(label, size) + 14
end
