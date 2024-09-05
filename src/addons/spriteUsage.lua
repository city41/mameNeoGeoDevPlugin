require("ngdev/util")

local addon = {}
addon.togglekey = "s"
addon.name = "sprite usage"

local prev_vram = {}
local vram = {}

local SCB1 = 0
local SCB2 = 0x8000
local SCB3 = 0x8200
local SCB4 = 0x8400
local VRAM_SIZE = 0x8600
local FIX_LAYER = 0x7000

return addon
