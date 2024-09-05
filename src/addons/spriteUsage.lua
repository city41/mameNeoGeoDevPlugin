require("ngdev/util")
require("ngdev/vram")

local addon = {}
addon.keyGroup = "g"
addon.togglekey = "s"
addon.name = "sprite usage"

local prev_vramData = {}
local vramData = {}

local SCB1 = 0
local SCB2 = 0x8000
local SCB3 = 0x8200
local SCB4 = 0x8400
local VRAM_SIZE = 0x8600
local FIX_LAYER = 0x7000

local showSpriteUsage = false
local spriteChangeFade = {}

-- given a sprite index, looks at prev_vram and vram to see if it has changed
-- this frame. If so, it will show up green on screen, otherwise red
-- changes considered: height and tile indexes
function addon.spriteJustChanged(si)
	height = vram.getSpriteHeight(si, vramData)
	if height ~= vram.getSpriteHeight(si, prev_vramData) then
		return true
	end

	local tiles = vram.getSpriteTiles(si, height, vramData)
	local prevTiles = vram.getSpriteTiles(si, height, prev_vramData)

	return not util.areTablesEqual(tiles, prevTiles)
end

function addon.visualize_sprites(screen)
	screen:draw_box(0, 224 - 69, 320, 224, 0, 0xaa666666)

	for i = 0, 380 do
		local height = vram.getSpriteHeight(i, vramData)

		local y = 224 - 68
		local x = i

		if i > 320 then
			y = 224 - 32
			x = (i - 320)
		end

		if spriteChangeFade[i] == nil then
			spriteChangeFade[i] = 0
		end

		if addon.spriteJustChanged(i) then
			spriteChangeFade[i] = 30
		end

		local heightColor = spriteChangeFade[i] > 0 and 0xaa00ff00 or 0xaaff0000
		local emptyColor = 0xaadddddd

		if i > 0 and i % 10 == 0 then
			heightColor = spriteChangeFade[i] > 0 and 0xaa00aa00 or 0xaaaa0000
			emptyColor = 0xaa333333
		end

		screen:draw_line(x, y, x, y + 32, emptyColor)
		screen:draw_line(x, y, x, y + height, heightColor)

		if spriteChangeFade[i] > 0 then
			spriteChangeFade[i] = spriteChangeFade[i] - 1
		end
	end
end

function addon.toggled()
	showSpriteUsage = not showSpriteUsage
end

function addon.draw(screen)
	if showSpriteUsage then
		prev_vramData = vramData
		vramData = vram.grab_vram()
		addon.visualize_sprites(screen)
	end
end

return addon
