-- Visualizes all sprite bounding boxes

cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]
screen = manager.machine.screens[":screen"]

-- what vram looks like this frame
vram = {}
-- where vram will write to next
next_vram_index = 0
-- how much to move the index based on REG_VRAMMOD
vram_index_mod = 1

-- where the game wants to write in VRAM
REG_VRAMADDR = 0x3c0000
-- how much to move the index after a write
REG_VRAMMOD = 0x3c0004
-- a data write
REG_VRAMRW = 0x3c0002

SCB1 = 0
SCB2 = 0x8000
SCB3 = 0x8200
SCB4 = 0x8400
VRAM_SIZE = 0x8600
FIX_LAYER = 0x7000

-- toggle sprites/fix on/off
SHOW_SPRITES = true
SHOW_FIX_LAYER = true

-- "emulate" vram to grab the data writes and store them in the vram table
function on_vram_write(offset, data)
	if offset == REG_VRAMADDR then
		next_vram_index = data
	end

	if offset == REG_VRAMMOD then
		vram_index_mod = data
	end

	if offset == REG_VRAMRW then
		vram[next_vram_index] = data
		next_vram_index = next_vram_index + vram_index_mod

		if (not SHOW_FIX_LAYER) and next_vram_index >= FIX_LAYER and next_vram_index <= SCB2 then
			return 0xff
		end

		if (not SHOW_SPRITES) and next_vram_index >= SCB4 and next_vram_index <= VRAM_SIZE then
			-- this moves the sprites off the screen, 320 is to account for stickied sprites
			-- who might be only moving their control sprite
			return -320
		end
	end
end

function isSticky(si, vr)
	local scb3Val = vr[SCB3 + si] or 0

	return scb3Val & 0x40 == 0x40
end

function getSpriteHeight(si, vr)
	if isSticky(si, vr) then
		return getSpriteHeight(si - 1, vr)
	end

	local scb3Val = vr[SCB3 + si] or 0
	return scb3Val & 0x3f
end

function getSpriteY(si, vr)
	if isSticky(si, vr) then
		return getSpriteY(si - 1, vr)
	end

	local scb3Val = vr[SCB3 + si] or 0

	local y = scb3Val >> 7

	-- handle 9 bit two's compliment
	if y > 256 then
		y = y - 512
	end

	y = 496 - y

	while y > 224 do
		y = y - 512
	end

	while y < -224 do
		y = y + 512
	end

	return y
end

-- TODO: support sprite scaling
function getSpriteX(si, vr)
	if isSticky(si, vr) then
		return getSpriteX(si - 1, vr) + 16
	end

	local scb4Val = vr[SCB4 + si] or 0

	return scb4Val >> 7
end

function clamp(v, min, max)
	return math.min(max, math.max(min, v))
end

function isOnScreen(x, y, h)
	return not (x + 16 < 0 or x > 320 or y + (h * 16) < 0 or y > 224)
end

RED = 0xffff0000
ORANGE = 0xffffaa00
PURPLE = 0xffaa00ff
WHITE = 0xffffffff

colors = { RED, ORANGE, PURPLE, WHITE }

function visualize_boundingBoxes()
	for i = 0, 380 do
		local h = getSpriteHeight(i, vram)
		local y = getSpriteY(i, vram)
		local x = getSpriteX(i, vram)

		local left = x
		local top = y
		-- TODO: support sprite scaling
		local right = x + 16
		-- TODO: support sprite scaling
		local bottom = y + (h * 16)

		if isOnScreen(x, y, h) then
			screen:draw_box(
				clamp(left, 0, 320),
				clamp(top, 0, 224),
				clamp(right, 0, 320),
				clamp(bottom, 0, 224),
				colors[i % 4],
				0
			)

			screen:draw_text(clamp(left, 0, 320), clamp(top, 0, 224), tostring(i), 0xffffffff, 0xff000000)
		end
	end
end

function on_frame()
	visualize_boundingBoxes()
end

emu.register_frame_done(on_frame, "frame")

vram_handler = mem:install_write_tap(REG_VRAMADDR, REG_VRAMMOD + 1, "vram", on_vram_write)
