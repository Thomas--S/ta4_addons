--[[

	TA4 Addons
	==========

	Copyright (C) 2020 Joachim Stolberg
	Copyright (C) 2020 Thomas S.

	GPL v3
	See LICENSE.txt for more information

]]--

ta4_addons = {}

-- Version for compatibility checks
ta4_addons.version = 0.1

-- Load support for I18n.
ta4_addons.S = minetest.get_translator("ta4_addons")

local MP = minetest.get_modpath("ta4_addons")

dofile(MP.."/touchscreen/main.lua") -- Touchscreen
