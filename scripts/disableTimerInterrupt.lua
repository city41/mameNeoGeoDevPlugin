-- disables the timer interrupt by forcing writes that turn it on to instead keep it off
-- this is used by Riding Hero and Neo Turf Masters to perform perspective effects.
-- Riding Hero: no road is drawn at all with this enabled
-- NTM: no perspective happens as you rotate

REG_LSPCMODE = 0x3c0006

function on_lspcmode_write(offset, data)
  if (offset == REG_LSPCMODE) then
    -- force timer interrupt to never enable
    return data & 0xffef
  end
end


cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]

lspcmode_handler = mem:install_write_tap(REG_LSPCMODE, REG_LSPCMODE + 1, "lspcmode", on_lspcmode_write)