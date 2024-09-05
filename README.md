# MAME Neo Geo Dev Plugin

A MAME Lua Plugin that provides information about the Neo Geo. Meant to be used for ROM hacking, game development, and those curious about the system's internals.

**WARNING:** this will not work on Windows (yet) and may not work on MacOS either. There are Linux specific things in the plugin that need to be worked out. See [this issue](https://github.com/city41/mameNeoGeoDevPlugin/issues/2).

## Installation

Grab the latest [release](https://github.com/city41/mameNeoGeoDevPlugin/releases) and unzip it somewhere. Then take the contents of the `src` directory and copy into your MAME plugin folder renamed to `ngdev`. Where this exists varies by MAME installation and OS. You can figure out where it is (and change it if needed) by launching MAME without running a game, then going to `Configure Options > Configure Directories > Plugins`

![plugins path in MAME options](https://github.com/city41/mameNeoGeoDevPlugin/blob/main/pluginDir.png?raw=true)

So if your plugin direction is at `/usr/share/games/mame/plugins` like mine is, then this plugin should be at `.../mame/plugins/ngdev`

```sh
unzip mameNeoGeoDevPlugin-0.0.1.zip
mv mameNeoGeoDevPlugin-0.0.1/src /usr/share/games/mame/plugins/ngdev
```

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

![plugin in initial state](https://github.com/city41/mameNeoGeoDevPlugin/blob/main/pluginInGame_nothingActive.png?raw=true)

Press `h` to see all available commands. Commands are grouped under a letter. For example all graphic related commands are under `g`.

![plugin showing help message](https://github.com/city41/mameNeoGeoDevPlugin/blob/main/pluginInGame_helpMessage.png?raw=true)

To toggle a command on or off, press its group hotkey, then the command's hotkey. So for example to show sprite bounding boxes, press `g` followed by `b`. In the upper right it will show the current group. Once in a group you don't press the group key anymore. So for example to toggle sprite bounding boxes on and off just press `b`.

![sprite bounding boxes](https://github.com/city41/mameNeoGeoDevPlugin/blob/main/plugin_spriteBoundingBoxes.png?raw=true)

So far the plugin only ships with one group, so it might seem like overkill. But there's only so many keys and many are already taken up by MAME. When extending the plugin (see below), the groups help a lot.

## Extending the plugin

You can add your own extensions to the plugin. I do this myself to add things needed for the game I am writing.

To do so, create a `custom_addons` folder next to the standard `addons` folder inside the `ngdev` plugin folder in the MAME plugins folder.

So it will look like this

```
mame/plugins/
        |_ ngdev
            |_ addons
            |   |_ (these are the standard addons)
            |   |_ spriteUsage.lua
            |   |_ ...
            |_ custom_addons
                |_your_lua_addon_here.lua
```
