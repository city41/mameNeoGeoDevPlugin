require("ngdev/util")
require("ngdev/vram")

local addon = {}
addon.keyGroup = "g"
addon.togglekey = "f"
addon.name = "fix layer"

local prev_vramData = {}
local vramData = {}
local fixTileFade = {}

local showFixLayer = false

function addon.toggled()
	showFixLayer = not showFixLayer
end

function addon.visualize_fix_layer(screen)
	-- center horizontally
	local screenX = (320 / 2) - (FIX_WIDTH / 2)
	local screenY = 224 - FIX_HEIGHT - 2

	for x = 0, FIX_WIDTH - 1 do
		for y = 0, FIX_HEIGHT - 1 do
			local i = x * 32 + y
			local fe = vramData[FIX_LAYER + i] or 0
			local pfe = prev_vramData[FIX_LAYER + i] or 0
			local tileIndex = fe & 0x3ff
			local ptileIndex = pfe & 0x3ff

			if fixTileFade[i] == nil then
				fixTileFade[i] = 0
			end

			if tileIndex ~= ptileIndex then
				fixTileFade[i] = 30
			end

			local color = tileIndex == 0xff and 0xaadddddd or 0xaaff0000

			if tileIndex ~= 0xff and fixTileFade[i] > 0 then
				color = 0xaa00aa00
			end

			screen:draw_line(screenX + x, screenY + y, screenX + x, screenY + y + 1, color)

			if fixTileFade[i] > 0 then
				fixTileFade[i] = fixTileFade[i] - 1
			end
		end
	end
end

function addon.draw(screen)
	if showFixLayer then
		prev_vramData = vramData
		vramData = vram.grab_vram()
		addon.visualize_fix_layer(screen)
	end
end

return addon
