-- Prism PS2 Launcher - ui/widgets.lua
-- The few building blocks every screen is made of:
--   list   a vertical list with a selection bar and a scrolling window
--   menu   a modal box of options, each { label, get, set, kind, values, action }
-- A widget is a plain table; *_input moves it, *_draw paints it.

--- List ---------------------------------------------------------------------------------
--- items: array of anything; render(item, i) -> text, color   (color optional)
function list_new(items, rows)
	return { items = items or {}, sel = 1, top = 1, rows = rows or 10 }
end

function list_set(l, items)
	l.items = items or {}
	if l.sel > #l.items then l.sel = #l.items end
	if l.sel < 1 then l.sel = 1 end
	list_scroll(l)
end

function list_scroll(l)
	if l.sel < l.top then l.top = l.sel end
	if l.sel > l.top + l.rows - 1 then l.top = l.sel - l.rows + 1 end
	if l.top < 1 then l.top = 1 end
end

function list_current(l)
	return l.items[l.sel]
end

--- Moves on up/down (with repeat), pages on left/right or L2/R2. Returns true if moved.
function list_input(l, page_keys)
	local n = #l.items
	if n == 0 then return false end
	local moved = false
	if input_pressed("up") then
		l.sel = l.sel - 1
		if l.sel < 1 then l.sel = n end
		moved = true
	elseif input_pressed("down") then
		l.sel = l.sel + 1
		if l.sel > n then l.sel = 1 end
		moved = true
	elseif page_keys and (input_pressed("l2") or input_pressed("left")) then
		l.sel = l.sel - l.rows
		if l.sel < 1 then l.sel = 1 end
		moved = true
	elseif page_keys and (input_pressed("r2") or input_pressed("right")) then
		l.sel = l.sel + l.rows
		if l.sel > n then l.sel = n end
		moved = true
	end
	if moved then list_scroll(l) end
	return moved
end

--- Draws rows from y down, row_h each, inside width w. render gives text and colour.
--- focused: whether the selection bar is bright (this list has the focus) or dim.
function list_draw(l, x, y, w, row_h, render, focused)
	local size = THEME.size_text
	for r = 0, l.rows - 1 do
		local i = l.top + r
		if i > #l.items then break end
		local ry = y + r * row_h
		local text, color = render(l.items[i], i)
		if i == l.sel then
			local bar = THEME.selector
			if focused == false then bar = THEME.panel_hi end
			gfx_rect(x, ry, w, row_h, bar)
			gfx_rect(x, ry, 3, row_h, THEME.selector_edge)
			color = THEME.text_sel
		end
		gfx_text(gfx_fit(text, size, w - 16), x + 10, ry + (row_h - size) / 2, size, color or THEME.text)
	end
	-- Scroll marks when the list is longer than the window.
	if #l.items > l.rows then
		local small = THEME.size_small
		if l.top > 1 then
			gfx_text("^", x + w - 12, y - small, small, THEME.text_dim)
		end
		if l.top + l.rows - 1 < #l.items then
			gfx_text("v", x + w - 12, y + l.rows * row_h + 2, small, THEME.text_dim)
		end
	end
end

--- Menu (modal) -------------------------------------------------------------------------
--- Each option:
---   label   text on the left
---   kind    "choice" (left/right cycles values), "toggle", "action" (cross runs it),
---           "info" (not selectable, just text)
---   values  for "choice": array of display strings
---   get()   -> current value (index for choice, boolean for toggle, text for info)
---   set(v)  called with the new value
---   action() for "action"
--- A menu is a table { title, options, sel }. menu_input returns "close" when the user
--- leaves, "changed" when a value changed, nil otherwise.
function menu_new(title, options)
	local m = { title = title, options = options or {}, sel = 1 }
	menu_skip_info(m, 1)
	return m
end

function menu_skip_info(m, dir)
	local n = #m.options
	local tries = 0
	while n > 0 and tries < n and m.options[m.sel] ~= nil and m.options[m.sel].kind == "info" do
		m.sel = m.sel + dir
		if m.sel < 1 then m.sel = n end
		if m.sel > n then m.sel = 1 end
		tries = tries + 1
	end
end

function menu_input(m)
	local n = #m.options
	if input_pressed("circle") or input_pressed("start") then return "close" end
	if n == 0 then return nil end
	if input_pressed("up") then
		m.sel = m.sel - 1
		if m.sel < 1 then m.sel = n end
		menu_skip_info(m, -1)
		return nil
	elseif input_pressed("down") then
		m.sel = m.sel + 1
		if m.sel > n then m.sel = 1 end
		menu_skip_info(m, 1)
		return nil
	end
	local o = m.options[m.sel]
	if o == nil then return nil end
	if o.kind == "choice" then
		local dir = 0
		if input_pressed("left") then dir = -1 end
		if input_pressed("right") or input_pressed("cross") then dir = 1 end
		if dir ~= 0 and o.values ~= nil and #o.values > 0 then
			local v = (o.get() or 1) + dir
			if v < 1 then v = #o.values end
			if v > #o.values then v = 1 end
			o.set(v)
			return "changed"
		end
	elseif o.kind == "toggle" then
		if input_pressed("left") or input_pressed("right") or input_pressed("cross") then
			o.set(not o.get())
			return "changed"
		end
	elseif o.kind == "action" then
		if input_pressed("cross") then
			local r = o.action()
			if r ~= nil then return r end
			return "action"
		end
	end
	return nil
end

--- Draws the menu centred, over whatever is behind (the caller dims the screen). ------
function menu_draw(m)
	local size, small = THEME.size_text, THEME.size_small
	local row_h = 24
	local w = 460
	local h = 44 + #m.options * row_h + 30
	if h > 400 then h = 400 end
	local x = (640 - w) // 2
	local y = (448 - h) // 2
	gfx_rect(x, y, w, h, THEME.panel_hi)
	gfx_rect(x, y, w, h, THEME.panel)
	gfx_frame(x, y, w, h, THEME.selector_edge)
	gfx_rect(x, y, w, 30, THEME.selector)
	gfx_text(m.title, x, y + 7, THEME.size_head, THEME.text_head, "center", w)

	local rows = math.floor((h - 44 - 30) / row_h)
	local top = 1
	if m.sel > rows then top = m.sel - rows + 1 end
	for r = 0, rows - 1 do
		local i = top + r
		local o = m.options[i]
		if o == nil then break end
		local ry = y + 38 + r * row_h
		if i == m.sel then
			gfx_rect(x + 6, ry, w - 12, row_h, THEME.selector)
		end
		local col = THEME.text
		if o.kind == "info" then col = THEME.text_dim end
		gfx_text(gfx_fit(o.label, size, w * 0.55), x + 16, ry + (row_h - size) / 2, size, col)
		local value = ""
		if o.kind == "choice" then
			local v = o.get()
			value = "< ".. tostring((o.values or {})[v] or "?") .." >"
		elseif o.kind == "toggle" then
			if o.get() then value = "< ON >" else value = "< OFF >" end
		elseif o.kind == "action" then
			value = ">"
		elseif o.kind == "info" then
			value = tostring(o.get and o.get() or "")
		end
		gfx_text(gfx_fit(value, size, w * 0.42), x + 16, ry + (row_h - size) / 2, size, THEME.text_head, "right", w - 32)
	end
	local hx = x + 12
	hx = gfx_hint(hx, y + h - 22, "cross", "select")
	hx = gfx_hint(hx, y + h - 22, "circle", "back")
	gfx_text("left / right : change", hx, y + h - 19, small, THEME.text_dim)
end

--- Dims the whole screen: drawn before a modal. --------------------------------------
function dim_screen()
	Graphics.drawRect(0, 0, GFX.w, GFX.h, Color.new(0, 0, 0, 70))
end
