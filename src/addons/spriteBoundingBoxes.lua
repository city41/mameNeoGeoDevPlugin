require("ngdev/util")
require("ngdev/vram")

local addon = {}
addon.togglekey = "b"
addon.name = "sprite bounding boxes"

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

function addon.visualize_boundingBoxes(screen, vramData)
	for i = 0, 380 do
		local ht = vram.getSpriteHeight(i, vramData)
		local hpx = ht * 16
		local x = vram.dewrap(vram.getSpriteX(i, vramData), 320)
		local y = vram.dewrap(vram.getSpriteY(i, vramData), 224)

		local left = x
		local top = y
		-- TODO: support sprite scaling
		local right = vram.dewrap(x + 16, 320)
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

function addon.draw(screen)
	if showBoundingBoxes then
		local vramData = vram.grab_vram()
		addon.visualize_boundingBoxes(screen, vramData)
	end
end

return addon
