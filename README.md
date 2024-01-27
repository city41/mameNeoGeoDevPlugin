# Neo Geo Debug Scripts

A collection of MAME autoboot scripts for the Neo Geo

Mostly focused on Video RAM and memory mapped registers so far.

I'm making these a lot and throwing them away or copying/pasting, etc, so I figured I'll just collect them into this repo.

Maybe eventually these will all get combined into a decent Neo Geo debug plugin.

## Example

An example of one script (spriteLengthAndFixLayer.lua) running

![example](https://github.com/city41/ngDebugScripts/blob/main/spriteLengthAndFixLayer_running.png?raw=true)

## To use

### First, keyboard_events

Some scripts want `keyboard_events` installed. To do that, copy `scripts/keyboard_events.lua` into your MAME installation's plugin folder. That will vary from OS to OS and even the type of MAME install. For me on Ubuntu using MAME installed from apt, it is at `/usr/share/games/mame/plugins`.

### Then, launch MAME from the command line

Do `mame -autoboot_script path/to/script/youwant.lua <game>`

For example: `mame -autoboot_script scripts/disableTimerInterrupt.lua ridhero`

If you don't normally run MAME from the command line, you may find the default way it launches not to your liking. I add these flags:

- `-w`: put the game in a window instead of being full screen
- `-nofilter`: turn off the blur filter, just get pure pixels
- `-nomouse`: don't capture the mouse, just leave it alone
- `-sound none`: disable audio if desired
