--- Originally written by stengun here:
--- https://github.com/stengun/arcademus/blob/main/keyboard_events.lua
--- needs to be copied to your mame plugins folder.
--- on linux that is usually /usr/share/games/mame/plugins, on other OSes? no idea
---
---
--- Global table used to register callbacks for specific keyboard keycodes.
--- The callbacks are fired when pressed and released events are detected.
--- To make this table work, .poll() method has to be called in a proper tick
--- function.
---
--- The callback signature is callback(event).
---
_G.keyboard_events = {}

local event_callbacks = {}

local function fire_callbacks(k, event)
	if not event_callbacks[k] or manager.ui.menu_active then
		return
	end
	for _, f in pairs(event_callbacks[k]) do
		f(event)
	end
end

local last_state = {}
---
--- Checks for status changes of the keys that have at least a callback registered.
--- If no callbacks are registered, this method does nothing.
---
function keyboard_events.poll()
	if manager.machine.system.name == "___empty" then
		return
	end
	local input = manager.machine.input
	for cb_name, _ in pairs(event_callbacks) do
		local is_pressed = input:code_pressed(input:code_from_token(cb_name))
		local was_pressed = last_state[cb_name][1]
		if was_pressed and not is_pressed then
			fire_callbacks(cb_name, "released")
			last_state[cb_name] = { is_pressed, emu.time() }
		elseif not was_pressed and is_pressed then
			fire_callbacks(cb_name, "pressed")
			last_state[cb_name] = { is_pressed, emu.time() }
		elseif was_pressed and is_pressed and emu.time() - last_state[cb_name][2] >= 0.25 then
			fire_callbacks(cb_name, "pressed_repeat")
			last_state[cb_name] = { is_pressed, emu.time() - 0.12 }
		end
	end
end
---
--- Register callback for key keycode. Callback is a function(event) method.
--- Callback's event parameter is a string which can assume the values "pressed" or "released".
---
--- Keycodes are the same as the macros in this file (the ones in the form KEYCODE_*)
--- https://github.com/mamedev/mame/blob/d822e7ec4ad29eeb7724e9249ef97a7220f541e0/src/emu/input.h#L679
---
function keyboard_events.register_key_event_callback(key, cb)
	if not event_callbacks[key] then
		event_callbacks[key] = {}
	end
	local input = manager.machine.input
	last_state[key] = { input:code_pressed(input:code_from_token(key)), emu.time() }
	table.insert(event_callbacks[key], cb)
end

function keyboard_events.reset_bindings()
	event_callbacks = {}
end

return keyboard_events
