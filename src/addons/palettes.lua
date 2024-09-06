require("ngdev/util")
require("ngdev/vram")

local addon = {}
addon.keyGroup = "g"
addon.toggleKey = "c"
addon.name = "palettes"

local vram_handler = nil
local inUsePalettes = {}

-- where vram will write to next
local next_vram_index = 0
-- how much to move the index based on REG_VRAMMOD
local vram_index_mod = 1

-- how big to make the palette color boxes on the screen when visualizing
local boxSize = 4

local showPalettes = false

function addon.toggled()
	showPalettes = not showPalettes
end

function addon.onVramWrite(offset, data)
	if offset == REG_VRAMADDR then
		next_vram_index = data
	end

	if offset == REG_VRAMMOD then
		vram_index_mod = data
	end

	if offset == REG_VRAMRW then
		if vram.getSpriteControlBlock(next_vram_index) == "scb1/odd" then
			local pal = data >> 8
			inUsePalettes[pal] = true
		end

		next_vram_index = next_vram_index + vram_index_mod
	end
end

function addon.init(cpu, mem)
	vram_handler = mem:install_write_tap(REG_VRAMADDR, REG_VRAMMOD + 1, "vram", addon.onVramWrite)
end

function addon.draw_palette(screen, pali, x)
	local cpu = manager.machine.devices[":maincpu"]
	local mem = cpu.spaces["program"]

	local yOffset = boxSize

	for i = 0, 15 do
		local pramVal = mem:read_u16(0x400000 + pali * 32 + (i * 2))
		local color = util.convert16to24(pramVal)
		screen:draw_box(x, i * boxSize + yOffset, x + boxSize, (i * boxSize) + yOffset + boxSize, 0, color)
	end
end

function addon.visualize_palettes(screen)
	local x = boxSize
	for pali, _ in util.spairs(inUsePalettes) do
		-- screen:draw_text(x, 0, tostring(pali), 0xffff0000, 0xff000000)
		addon.draw_palette(screen, pali, x)
		x = x + boxSize
	end
end

function addon.draw(screen)
	if showPalettes then
		addon.visualize_palettes(screen)
	end
end

return addon
