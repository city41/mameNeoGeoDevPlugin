# Neo Geo Debug Scripts

A collection of MAME autoboot scripts for the Neo Geo

Mostly focused on Video RAM and memory mapped registers so far.

I'm making these a lot and throwing them away or copying/pasting, etc, so I figured I'll just collect them into this repo.

Maybe eventually these will all get combined into a decent Neo Geo debug plugin.

## Examples

spriteLengthAndFixLayer.lua

![sprite length and fix layer example](https://github.com/city41/ngDebugScripts/blob/main/spriteLengthAndFixLayer_running.png?raw=true)

spriteBoundingBoxes.lua

![sprite bounding boxes example](https://github.com/city41/ngDebugScripts/blob/main/spriteBoundingBoxes_running.png?raw=true)

## To use

### First, keyboard_events

Some scripts want `keyboard_events` installed. To do that, copy `scripts/keyboard_events.lua` into your MAME installation's plugin folder. That will vary from OS to OS and even the type of MAME install. For me on Ubuntu using MAME installed from apt, it is at `/usr/share/games/mame/plugins`.

`keyboard_events` was written by stengun for the [arcademus](https://github.com/stengun/arcademus) project. Thank you!

### Then, launch MAME from the command line

Do `mame -autoboot_script path/to/script/youwant.lua <game>`

For example: `mame -autoboot_script scripts/disableTimerInterrupt.lua ridhero`

If you don't normally run MAME from the command line, you may find the default way it launches not to your liking. I add these flags:

- `-w`: put the game in a window instead of being full screen
- `-nofilter`: turn off the blur filter, just get pure pixels
- `-nomouse`: don't capture the mouse, just leave it alone
- `-sound none`: disable audio if desired

## Known Issues

I am accessing video ram by placing write taps onto the video registers. Essentially I am "emulating" the video ram registers in lua and grabbing all the values the game sends to video ram and saving them.

This works totally fine in every game I've tested ... except Samurai Shodown 2. If you run SS2 with `spriteLengthAndFixLayer.lua`, and once you are in game, you will see on the fix layer visualization that player one's health bar is missing. But if you look in the actual video ram via MAME's debugger, it's there. So either SS2 does something I don't understand and is able to set these video ram values in another way (seems unlikely), or MAME's Lua taps have a rare bug (possible), or I'm just doing something wrong (most likely).

If anyone knows how to fix this, please let me know. Either by using the taps correctly, or even better, just getting direct access to video ram in Lua.
