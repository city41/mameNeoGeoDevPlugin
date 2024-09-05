require("ngdev/util")
require("ngdev/vram")

local addon = {}
addon.togglekey = "n"
addon.name = "auto animations"

-- -1 means dont mess with them, just let the game do them
-- all other numbers are the speed of the animations,
-- the higher the number, the slower the animations are
local autoAnimationSpeeds = { -1, 256, 0, 10, 20, 50, 80, 120, 255 }
local autoAnimationSpeedIndex = 1

local LSPCMODE_ADDR = 0x3c0006
local lspcmode_handler = nil

function addon.toggled()
	autoAnimationSpeedIndex = autoAnimationSpeedIndex + 1

	if autoAnimationSpeedIndex > #autoAnimationSpeeds then
		autoAnimationSpeedIndex = 1
	end

	print("autoAnimationSpeed", autoAnimationSpeeds[autoAnimationSpeedIndex])
end

function addon.on_lspcmode_write(offset, data)
	if offset == LSPCMODE_ADDR then
		if autoAnimationSpeeds[autoAnimationSpeedIndex] == 256 then
			-- disable auto animations
			data = data | (1 << 3)
		elseif autoAnimationSpeeds[autoAnimationSpeedIndex] > -1 then
			data = (autoAnimationSpeeds[autoAnimationSpeedIndex] << 8) | (data & 0xff)
		end

		return data
	end
end

function addon.init(cpu, mem)
	lspcmode_handler = mem:install_write_tap(LSPCMODE_ADDR, LSPCMODE_ADDR + 1, "lspcmode", addon.on_lspcmode_write)
end

return addon
