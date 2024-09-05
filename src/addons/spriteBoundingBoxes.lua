require("ngdev/util")

local addon = {}
addon.togglekey = "b"
addon.name = "sprite bounding boxes"

local vram = {}

local SCB1 = 0
local SCB2 = 0x8000
local SCB3 = 0x8200
local SCB4 = 0x8400
local VRAM_SIZE = 0x8600
local FIX_LAYER = 0x7000

local VRAM_SIZE = 0x8600
local RED = 0xffff0000
local ORANGE = 0xffffaa00
local PURPLE = 0xffaa00ff
local WHITE = 0xffffffff

local colors = { RED, ORANGE, PURPLE, WHITE }

local showBoundingBoxes = false

function addon.toggled()
	showBoundingBoxes = not showBoundingBoxes
end

function addon.isSticky(si, vr)
	local scb3Val = vr[SCB3 + si] or 0

	return scb3Val & 0x40 == 0x40
end

function addon.getSpriteHeight(si, vr)
	if isSticky(si, vr) then
		return getSpriteHeight(si - 1, vr)
	end

	local scb3Val = vr[SCB3 + si] or 0
	return scb3Val & 0x3f
end

function addon.dewrap(v, wrapBoundary)
	while v > wrapBoundary do
		v = v - 512
	end

	while v < -wrapBoundary do
		v = v + 512
	end

	return v
end

function addon.getSpriteY(si, vr)
	if addon.isSticky(si, vr) then
		return addon.getSpriteY(si - 1, vr)
	end

	local scb3Val = vr[SCB3 + si] or 0

	local y = scb3Val >> 7

	-- handle 9 bit two's compliment
	if y > 256 then
		y = y - 512
	end

	y = 496 - y

	return y
end

-- TODO: support sprite scaling
function addon.getSpriteX(si, vr)
	if addon.isSticky(si, vr) then
		return addon.getSpriteX(si - 1, vr) + 16
	end

	local scb4Val = vr[SCB4 + si] or 0

	x = scb4Val >> 7

	return x
end

function addon.getSpriteHeight(si, vr)
	if addon.isSticky(si, vr) then
		return addon.getSpriteHeight(si - 1, vr)
	end

	local scb3Val = vr[SCB3 + si] or 0
	return scb3Val & 0x3f
end

function addon.visualize_boundingBoxes(screen)
	for i = 0, 380 do
		local ht = addon.getSpriteHeight(i, vram)
		local hpx = ht * 16
		local x = addon.dewrap(addon.getSpriteX(i, vram), 320)
		local y = addon.dewrap(addon.getSpriteY(i, vram), 224)

		local left = x
		local top = y
		-- TODO: support sprite scaling
		local right = addon.dewrap(x + 16, 320)
		-- TODO: support sprite scaling
		local bottom = y + hpx

		if bottom > 512 then
			-- sprite has wrapped back around to the top
			-- its visible portion starts at the top of the screen
			top = 0
			-- and this is the amount that has wrapped and become visible
			bottom = hpx - (512 - 224)
		end

		if right > 512 then
			-- sprite has wrapped back around to the left side
			-- its visible portion starts at the left of the screen
			left = 0
			-- and this is the amount that has wrapped and become visible
			right = 16 - (512 - 320)
		end

		if util.isOnScreen(left, top, right, bottom) then
			screen:draw_box(
				util.clamp(left, 0, 320),
				util.clamp(top, 0, 224),
				util.clamp(right, 0, 320),
				util.clamp(bottom, 0, 224),
				colors[i % 4],
				0
			)

			screen:draw_text(util.clamp(left, 0, 320), util.clamp(top, 0, 224), tostring(i), 0xffffffff, 0xff000000)
		end
	end
end

function addon.grab_vram()
	local vramdevice = emu.item(manager.machine.devices[":spritegen"].items["0/m_videoram"])
	for i = 0, VRAM_SIZE - 1 do
		vram[i] = vramdevice:read(i)
	end
end

function addon.draw(screen)
	if showBoundingBoxes then
		addon.grab_vram()
		addon.visualize_boundingBoxes(screen)
	end
end

return addon
