-- disables the timer interrupt by forcing writes that turn it on to instead keep it off
-- this is used by Riding Hero and Neo Turf Masters to perform perspective effects.
-- Riding Hero: no road is drawn at all with this enabled
-- NTM: no perspective happens as you rotate

REG_DIPSW = 0x300001

function on_dip_read(offset, data, mask)
	-- print(string.format("o %x d %x m %x", offset, data, mask))
	-- local ret = (data & 0xff00) | ~2
	-- return ret

	if mask == 0xff then
		return ~2
	end
end

cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]

dip_handlwer = mem:install_read_tap(REG_DIPSW - 1, REG_DIPSW, "dips", on_dip_read)
