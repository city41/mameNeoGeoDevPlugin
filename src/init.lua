local exports = {}
exports.name = "ngdev"
exports.version = "0.0.1"
exports.description = "Neo Geo Development Tools"
exports.license = "BSD-3-Clause"
exports.author = { name = "mgreer" }

require("ngdev/keyboard_events")
require("ngdev/games")

local addons = {}
local focusedAddon = nil
local ngdev = exports
local helpOpen = false

local groupCallbacks = {}
local currentGroup = nil

local welcomeMessageCountdown = 0

function ngdev.onFrame()
	keyboard_events.poll()
end

function ngdev.getAddons()
	local addons = {}
	local pluginDir = manager.options.entries.pluginspath:value()
	
	-- Detect OS for proper command
	local isWindows = package.config:sub(1,1) == '\\'
	local listCmd = isWindows and 'dir /b /a-d' or 'ls'
	local nullRedirect = isWindows and '2>nul' or '2>/dev/null'
	
	-- Use proper path separator
	local pathSep = isWindows and '\\' or '/'
	
	for addonPath in io.popen(string.format('%s "%s%sngdev%saddons%s*.lua" %s', listCmd, pluginDir, pathSep, pathSep, pathSep, nullRedirect)):lines() do
		-- On Windows, dir returns relative paths, so we need to build the full path
		if isWindows then
			addonPath = string.format('%s%sngdev%saddons%s%s', pluginDir, pathSep, pathSep, pathSep, addonPath)
		end
		
		local addonHydrate = assert(loadfile(addonPath))
		local success, addonOrErr = pcall(addonHydrate)

		if not success then
			print(string.format("Addon failed to hydrate: %s", addonOrErr))
		else
			table.insert(addons, addonOrErr)
		end
	end

	for customAddonPath in io.popen(string.format('%s "%s%sngdev%scustom_addons%s*.lua" %s', listCmd, pluginDir, pathSep, pathSep, pathSep, nullRedirect)):lines() do
		-- On Windows, dir returns relative paths, so we need to build the full path
		if isWindows then
			customAddonPath = string.format('%s%sngdev%scustom_addons%s%s', pluginDir, pathSep, pathSep, pathSep, customAddonPath)
		end
		
		local addonHydrate = assert(loadfile(customAddonPath))
		local success, addonOrErr = pcall(addonHydrate)

		if not success then
			print(string.format("Custom Addon failed to hydrate: %s", addonOrErr))
		else
			table.insert(addons, addonOrErr)
		end
	end

	return addons
end

function ngdev.drawHelp(screen)
	local x = 20
	local y = 10
	for _, a in ipairs(addons) do
		screen:draw_text(
			x,
			y,
			string.format("(%s,%s) %s", a.keyGroup, a.overlayKey or a.toggleKey, a.name),
			0xffffffff,
			0xff000000
		)
		y = y + 10
	end
end

function ngdev.drawAddons(screen)
	for _, a in ipairs(addons) do
		if a.draw ~= nil then
			local success, err = pcall(a.draw, screen)
			if not success then
				print(string.format("%s.draw errored: %s", a.name, err))
			end
		end
	end
end

function ngdev.onFrameDone()
	local screen = manager.machine.screens[":screen"]

	if welcomeMessageCountdown > 0 then
		welcomeMessageCountdown = welcomeMessageCountdown - 1
		screen:draw_text("center", 0, "ngdev initialized")
	else
		ngdev.drawAddons(screen)

		if not helpOpen then
			screen:draw_text(288, 0, "(h) for help", 0xffffffff, 0xff000000)
		else
			ngdev.drawHelp(screen)
		end

		if focusedAddon ~= nil then
			local success, err = pcall(focusedAddon.drawOverlay, screen)

			if not success then
				print(string.format("%s.drawOverlay errored: %s", focusedAddon.name, err))
			else
				screen:draw_text(
					0,
					217,
					string.format("%s, (%s) to close", focusedAddon.name, focusedAddon.overlayKey),
					0xffffffff,
					0xff000000
				)
			end
		end

		if currentGroup ~= nil then
			screen:draw_text(288, 10, string.format("group: %s", currentGroup))
		end
	end
end

function ngdev.startplugin()
	emu.register_start(function()
		if not games.is_neogeo_game(manager.machine.system.name) then
			return
		end

		welcomeMessageCountdown = 120

		local cpu = manager.machine.devices[":maincpu"]
		local mem = cpu.spaces["program"]
		local screen = manager.machine.screens[":screen"]

		local success, errOrData = pcall(ngdev.getAddons)

		if success then
			addons = errOrData
			print(string.format("%d addons", #addons))

			for _, a in ipairs(addons) do
				if a.init ~= nil then
					local initSuccess, initErr = pcall(a.init, cpu, mem, screen)
					if not initSuccess then
						print(string.format("%s.init() errored: %s", a.name, initErr))
					end
				end

				if a.keyGroup == nil then
					print(string.format("error, % lacks a keyGroup", a.name))
				end

				if not groupCallbacks[a.keyGroup] then
					keyboard_events.register_key_event_callback(
						string.format("KEYCODE_%s", string.upper(a.keyGroup)),
						function(e)
							if e == "pressed" then
								if currentGroup == a.keyGroup then
									currentGroup = nil
								else
									currentGroup = a.keyGroup
								end
							end
						end
					)
					groupCallbacks[a.keyGroup] = true
				end

				if a.overlayKey ~= nil then
					keyboard_events.register_key_event_callback(
						string.format("KEYCODE_%s", string.upper(a.overlayKey)),
						function(e)
							if e == "pressed" and currentGroup == a.keyGroup then
								if focusedAddon == a then
									focusedAddon = nil
								else
									focusedAddon = a
									helpOpen = false
								end
							end
						end
					)
				end

				if a.toggleKey ~= nil then
					if a.toggled == nil then
						print(string.format("error, addon %s has toggleKey but no toggled() function", a.name))
					else
						keyboard_events.register_key_event_callback(
							string.format("KEYCODE_%s", string.upper(a.toggleKey)),
							function(e)
								if e == "pressed" and currentGroup == a.keyGroup then
									a.toggled()
								end
							end
						)
					end
				end
			end
		else
			print("error getting addons", errOrData)
		end

		emu.register_frame(ngdev.onFrame, "frame")
		emu.register_frame_done(ngdev.onFrameDone, "frame_done")

		keyboard_events.register_key_event_callback("KEYCODE_H", function(e)
			if e == "pressed" then
				helpOpen = not helpOpen

				if helpOpen then
					focusedAddon = nil
					currentGroup = nil
				end
			end
		end)
	end)

	emu.register_stop(function()
		keyboard_events.reset_bindings()
		addons = {}
	end)
end

return exports
