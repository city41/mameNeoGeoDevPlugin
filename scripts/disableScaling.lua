-- Disables sprite scaling by forcing the scale values to always be full size

-- where the game wants to write in VRAM
REG_VRAMADDR = 0x3c0000
-- how much to move the index after a write
REG_VRAMMOD = 0x3c0004
-- a data write
REG_VRAMRW = 0x3c0002

SCB2 = 0x8000
SCB3 = 0x8200

function on_vram_write(offset, data)
	if offset == REG_VRAMADDR then
		next_vram_index = data
	end

	if offset == REG_VRAMMOD then
		vram_index_mod = data
	end

	if offset == REG_VRAMRW then
		local retValue = data
		if next_vram_index >= SCB2 and next_vram_index < SCB3 then
			-- force scaling to not happen
			retValue = data | 0xfff
		end
		next_vram_index = next_vram_index + vram_index_mod
		return retValue
	end
end

cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]

vram_handler = mem:install_write_tap(REG_VRAMADDR, REG_VRAMMOD + 1, "vram", on_vram_write)
