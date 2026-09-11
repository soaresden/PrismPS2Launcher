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

--- Fonts: one FreeType handle per size (ftSetPixelSize is per handle). ------------
function gfx_init()
	Font.ftInit()
	local f = THEME.font_file
	GFX.font_head  = Font.ftLoad(f)
	Font.ftSetPixelSize(GFX.font_head, THEME.size_head, THEME.size_head)
	GFX.font_text  = Font.ftLoad(f)
	Font.ftSetPixelSize(GFX.font_text, THEME.size_text, THEME.size_text)
	GFX.font_small = Font.ftLoad(f)
	Font.ftSetPixelSize(GFX.font_small, THEME.size_small, THEME.size_small)
end

--- Real screen size. Layout stays 640x448 and is centred vertically on PAL. ----------
function gfx_set_screen(w, h)
	GFX.w, GFX.h = w, h
	GFX.pal_y = (h - 448) // 2
end

--- Character width of a font size, for measuring and clipping text. ----------------
function gfx_char_w(size)
	return size * THEME.char_w
end

--- Text that fits in "width" pixels, cut with an ellipsis if needed. ----------------
function gfx_fit(text, size, width)
	text = tostring(text or "")
	local maxc = math.floor(width / gfx_char_w(size))
	if maxc < 1 then return "" end
	if string.len(text) <= maxc then return text end
	if maxc <= 2 then return string.sub(text, 1, maxc) end
	return string.sub(text, 1, maxc - 2) .."~"
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
	elseif size == THEME.size_small then font = GFX.font_small end
	local tw = string.len(text) * gfx_char_w(size)
	if align == "center" then
		x = x + ((width or 0) - tw) / 2
	elseif align == "right" then
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

--- A button hint: coloured disc with the button letter, then a label. ----------------
--- Returns the x after the hint, so several can be laid out in a row.
function gfx_hint(x, y, button, label)
	local colors = {
		cross = THEME.btn_cross, circle = THEME.btn_circle,
		square = THEME.btn_square, triangle = THEME.btn_triangle,
	}
	local letters = { cross = "X", circle = "O", square = "#", triangle = "^" }
	local size = THEME.size_small
	local letter = letters[button] or button
	local d = 16
	local c = colors[button] or THEME.btn_neutral
	if letters[button] ~= nil then
		Graphics.drawCircle(x + d / 2, y + d / 2 + GFX.pal_y, d / 2, c, true)
	else
		-- L1, R1, START...: a pill wide enough for the word.
		d = math.floor(string.len(letter) * gfx_char_w(size)) + 8
		gfx_rect(x, y, d, 16, c)
	end
	gfx_text(letter, x, y + 3, size, THEME.text_head, "center", d)
	local lx = x + d + 5
	gfx_text(label, lx, y + 3, size, THEME.text)
	return lx + string.len(label) * gfx_char_w(size) + 18
end
