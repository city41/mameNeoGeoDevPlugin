vram = {}

local SCB1 = 0
local SCB2 = 0x8000
local SCB3 = 0x8200
local SCB4 = 0x8400
local VRAM_SIZE = 0x8600
local FIX_LAYER = 0x7000

function vram.isSticky(si, vr)
	local scb3Val = vr[SCB3 + si] or 0

	return scb3Val & 0x40 == 0x40
end

function vram.getSpriteHeight(si, vr)
	if vram.isSticky(si, vr) then
		return vram.getSpriteHeight(si - 1, vr)
	end

	local scb3Val = vr[SCB3 + si] or 0
	return scb3Val & 0x3f
end

function vram.dewrap(v, wrapBoundary)
	while v > wrapBoundary do
		v = v - 512
	end

	while v < -wrapBoundary do
		v = v + 512
	end

	return v
end

function vram.getSpriteY(si, vr)
	if vram.isSticky(si, vr) then
		return vram.getSpriteY(si - 1, vr)
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
function vram.getSpriteX(si, vr)
	if vram.isSticky(si, vr) then
		return vram.getSpriteX(si - 1, vr) + 16
	end

	local scb4Val = vr[SCB4 + si] or 0

	x = scb4Val >> 7

	return x
end

function vram.getSpriteHeight(si, vr)
	if vram.isSticky(si, vr) then
		return vram.getSpriteHeight(si - 1, vr)
	end

	local scb3Val = vr[SCB3 + si] or 0
	return scb3Val & 0x3f
end

function vram.grab_vram()
	local vramdevice = emu.item(manager.machine.devices[":spritegen"].items["0/m_videoram"])
	local vramData = {}
	for i = 0, VRAM_SIZE - 1 do
		vramData[i] = vramdevice:read(i)
	end

	return vramData
end
