require("keyboard_events")

cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]
screen = manager.machine.screens[":screen"]

LSPCMODE_ADDR = 0x3c0006

game_autoAnimationSpeed = 0
game_disableAutoAnimations = false

-- set this to true to disable auto animations or press 'Y' while the game is running
-- note that pressing while the game is running may have a (long) delay as it will
-- only take effect the next time the game changes LSPCMODE. For best effect, set it in the script
DISABLE_AUTO_ANIMATIONS = false
-- set this to a number from 0 to 255 to control auto animation speed
-- the larger the number, the slower they are
AUTO_ANIMATION_SPEED_OVERRIDE = 1

function on_lspcmode_write(offset, data)
	if offset == LSPCMODE_ADDR then
		-- grab the values the game wants
		game_autoAnimationSpeed = data >> 8
		game_disableAutoAnimations = (data & (1 << 3)) ~= 0

		if DISABLE_AUTO_ANIMATIONS then
			data = data | (1 << 3)
		end

		if AUTO_ANIMATION_SPEED_OVERRIDE ~= nil then
			data = (AUTO_ANIMATION_SPEED_OVERRIDE << 8) | (data & 0xff)
		end

		return data
	end
end

lspcmode_handler = mem:install_write_tap(LSPCMODE_ADDR, LSPCMODE_ADDR + 1, "lspcmode", on_lspcmode_write)

function tick()
	keyboard_events.poll()
end

function on_y(e)
	if e == "pressed" then
		DISABLE_AUTO_ANIMATIONS = not DISABLE_AUTO_ANIMATIONS
	end
end

keyboard_events.register_key_event_callback("KEYCODE_Y", on_y)

function on_frame_done()
	local gameSpeed = game_disableAutoAnimations and "disabled" or tostring(game_autoAnimationSpeed)
	screen:draw_text(0, 0, string.format("Game ani speed: %s", gameSpeed), 0xffffffff, 0xff000000)

	local overrideSpeed = ""

	if DISABLE_AUTO_ANIMATIONS then
		overrideSpeed = "disabled"
	elseif AUTO_ANIMATION_SPEED_OVERRIDE ~= nil then
		overrideSpeed = tostring(AUTO_ANIMATION_SPEED_OVERRIDE)
	else
		overrideSpeed = "not set"
	end

	screen:draw_text(0, 8, string.format("Override ani speed: %s", overrideSpeed), 0xffffffff, 0xff000000)
end

emu.register_frame(tick, "tick")
emu.register_frame_done(on_frame_done, "frame_done")
