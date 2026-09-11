-- Prism PS2 Launcher - ui/input.lua
-- One input model for the whole interface. Read once per frame with input_poll();
-- views ask input_pressed("down") and get true on the frame the button went down,
-- then again while held, at the repeat rate. The left stick counts as the d-pad.

INPUT = {
	now = 0, before = 0,        -- raw pad bitmasks
	held = {},                  -- name -> frames held
	repeat_delay = 18,          -- frames before auto-repeat starts (~0.3 s at 60)
	repeat_every = 4,           -- frames between repeats once started
	stick_dead = 90,            -- stick threshold, out of 127
}

local BUTTONS = {
	up = PAD_UP, down = PAD_DOWN, left = PAD_LEFT, right = PAD_RIGHT,
	cross = PAD_CROSS, circle = PAD_CIRCLE, square = PAD_SQUARE, triangle = PAD_TRIANGLE,
	l1 = PAD_L1, r1 = PAD_R1, l2 = PAD_L2, r2 = PAD_R2, l3 = PAD_L3, r3 = PAD_R3,
	start = PAD_START, select = PAD_SELECT,
}

local function is_down(pad, name, lx, ly)
	local b = BUTTONS[name]
	if b ~= nil and Pads.check(pad, b) then return true end
	local d = INPUT.stick_dead
	if name == "up"    and ly <= -d then return true end
	if name == "down"  and ly >=  d then return true end
	if name == "left"  and lx <= -d then return true end
	if name == "right" and lx >=  d then return true end
	return false
end

--- Call once per frame, before any view reads input. ------------------------------
function input_poll()
	local pad = Pads.get(0)
	local lx, ly = Pads.getLeftStick(0)
	lx, ly = lx or 0, ly or 0
	INPUT.pad = pad
	for name, _b in pairs(BUTTONS) do
		if is_down(pad, name, lx, ly) then
			INPUT.held[name] = (INPUT.held[name] or 0) + 1
		else
			INPUT.held[name] = 0
		end
	end
end

--- True on the first frame a button is down, and on repeats while it stays down. -----
--- Only the four directions repeat; everything else fires once per press.
function input_pressed(name)
	local n = INPUT.held[name] or 0
	if n == 1 then return true end
	if name == "up" or name == "down" or name == "left" or name == "right" then
		if n > INPUT.repeat_delay and ((n - INPUT.repeat_delay) % INPUT.repeat_every) == 0 then
			return true
		end
	end
	return false
end

--- True while the button is down, every frame. -------------------------------------
function input_held(name)
	return (INPUT.held[name] or 0) > 0
end

--- Forget the current presses: used after a screen change so the button that
--- confirmed the previous screen does not also act on the next one.
function input_flush()
	for name, _b in pairs(BUTTONS) do INPUT.held[name] = -1000 end
end
