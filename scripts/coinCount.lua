-- an experimental script that listens to the BIOS setting REG_SETCC1
-- whenever a coin is entered

REG_SETCC1 = 0x3800E0

function on_reg_write(offset, data)
	if offset == REG_SETCC1 then
		print("coin entered")
	end
end

cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]

reg_handler = mem:install_write_tap(REG_SETCC1, REG_SETCC1 + 1, "reg", on_reg_write)
