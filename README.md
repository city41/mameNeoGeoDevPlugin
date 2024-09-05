# MAME Neo Geo Dev Plugin

A MAME Lua Plugin that provides information about the Neo Geo. Meant to be used for ROM hacking, game development, and those curious about the system's internals.

## Installation

Grab the latest [release](https://github.com/city41/mameNeoGeoDevPlugin/releases) and unzip it into your MAME plugin folder. Where this exists varies by MAME installation and OS. You can figure out where it is (and change it if needed) by launching MAME without running a game, then going to `Configure Options > Configure Directories > Plugins`

![plugins path in MAME options](https://github.com/city41/mameNeoGeoDevPlugin/blob/main/pluginDir.png?raw=true)

So if your plugin direction is at `/usr/share/games/mame/plugins` like mine is, then this plugin should be at `.../mame/plugins/ngdev`

## Usage

### Enabling the plugin

From the command line, launch MAME with the plugin active via

```sh
mame ... -plugin ngdev
```

or in the UI, enable the plugin

![enabling the plugin in MAME](https://github.com/city41/mameNeoGeoDevPlugin/blob/main/pluginEnabled.png?raw=true)

### The plugin in action

Once enabled, you should see `(h) for help` in the upper right corner of a Neo Geo game.

![plugin showing help message](https://github.com/city41/mameNeoGeoDevPlugin/blob/main/pluginInGame.png?raw=true)

Press `h` to see all available commands. To toggle a command on or off, press its hotkey, for example `b` for showing sprite bounding boxes

![sprite bounding boxes](https://github.com/city41/mameNeoGeoDevPlugin/blob/main/spriteBoundingBoxes_running.png?raw=true)
