--[[

	TA4 Addons
	==========

	Copyright (C) 2020 Joachim Stolberg
	Copyright (C) 2020 Thomas S.

	AGPL v3
	See LICENSE.txt for more information

	Touchscreen

]]--

local S = ta4_addons.S
local M = minetest.get_meta
local N = techage.get_nvm

local function get_value(element, key, default)
	return minetest.formspec_escape(element.get(key) or default)
end

local function parse_payload(payload)
	local element_type = payload.get("type")
	if type(element_type) ~= "string" then
		return
	end
	element_type = string.lower(element_type)
	if element_type == "button" then
		local x = get_value(payload, "x", 1)
		local y = get_value(payload, "y", 1)
		local w = get_value(payload, "w", 2)
		local h = get_value(payload, "h", 1)
		local name = get_value(payload, "name", "button")
		local label = get_value(payload, "label", "Button")
		return "button["..x..","..y..";"..w..","..h..";"..name..";"..label.."]"
	end
end

local function next_id(pos)
	local nvm = N(pos)
	local id = (nvm.element_id or 0) + 1
	nvm.element_id = id
	return id
end

local function reset_id(pos)
	N(pos).element_id = 0
end

local function get_elements(pos)
	local nvm = N(pos)
	nvm.elements = nvm.elements or {}
	return nvm.elements
end

local function valid_payload(payload)
	if not payload then return false end
	if not type(payload) == "table" then return false end
	if not payload.get then return false end
	if not payload.next then return false end
	return true
end

local function update_fs(pos)
	local meta = M(pos)
	local fs = "formspec_version[3]"
	fs = fs .. "size[10,10]"
	local elements = get_elements(pos)
	for _,ele in ipairs(elements) do
		fs = fs .. ele
	end
	meta:set_string("formspec", fs)
end

local function add_content(pos, payload)
	if not valid_payload(payload) then
		return
	end
	local element = parse_payload(payload)
	if not element then
		return
	end
	local elements = get_elements(pos)
	local id = next_id(pos)
	elements[id] = element
	update_fs(pos)
	return id
end

local function update_content(pos, payload)
	if not valid_payload(payload) then
		return false
	end
	local id = payload.get("id")
	local elements = get_elements(pos)
	if not id or not elements[id] then
		return false
	end
	local element = parse_payload(payload)
	if not element then
		return false
	end
	elements[id] = element
	update_fs(pos)
	return true
end

local function remove_content(pos, payload)
	if valid_payload(payload) then
		local id = payload.get("id")
		if id then
			local elements = get_elements(pos)
			if not elements[id] then
				return false
			end
			elements[id] = nil
			update_fs(pos)
			return true
		else
			return false
		end
	end
	local nvm = techage.get_nvm(pos)
	nvm.elements = {}
	nvm.element_id = nil
	update_fs(pos)
	return true
end

minetest.register_node("ta4_addons:touchscreen", {
	description = S("TA4 Display"),
	inventory_image = "ta4_addons_touchscreen_inventory.png",
	tiles = {"ta4_addons_touchscreen.png"},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	node_box = techage.display.lcd_box,
	selection_box = techage.display.lcd_box,
	light_source = 6,

	display_entities = {
		["techage:display_entity"] = {
			depth = 0.42,
			on_display_update = techage.display.display_update
		},
	},

	after_place_node = function(pos, placer)
		local number = techage.add_node(pos, "ta4_addons:touchscreen")
		local meta = M(pos)
		meta:set_string("number", number)
		meta:set_string("infotext", S("Touchscreen no: ")..number)
		update_fs(pos)
		local nvm = techage.get_nvm(pos)
		nvm.text = {"My", "Techage","TA4", "Touchscreen", "No: "..number}
		lcdlib.update_entities(pos)
		minetest.get_node_timer(pos):start(1)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata)
		remove_content(pos)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		local meta = M(pos)
		if meta:get_string("public") ~= "true" and minetest.is_protected(pos, sender:get_player_name()) then
			return
		end
		local fields_store = safer_lua.Store()
		for k,v in pairs(fields) do
			fields_store.set(k, v)
		end
		local ctrl = meta:get_string("ctrl")
		if ctrl then
			local own_num = meta:get_string("node_number") or ""
			techage.send_single(own_num, ctrl, "msg", fields_store)
		end
	end,

	on_timer = techage.display.on_timer,
	on_place = lcdlib.on_place,
	on_construct = lcdlib.on_construct,
	on_destruct = lcdlib.on_destruct,
	on_rotate = lcdlib.on_rotate,
	groups = {cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_craft({
	output = "ta4_addons:touchscreen",
	recipe = {
		{"", "dye:blue", ""},
		{"default:copper_ingot", "techage:ta4_display", "default:copper_ingot"},
		{"", "default:mese_crystal_fragment", ""},
	},
})

techage.register_node({"ta4_addons:touchscreen"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "add" then  -- add one line and scroll if necessary
			techage.display.add_line(pos, payload, 1)
		elseif topic == "set" then  -- overwrite the given row
			techage.display.write_row(pos, payload, 1)
		elseif topic == "clear" then  -- clear the screen
			techage.display.clear_screen(pos, 1)
		elseif topic == "add_content" then
			M(pos):set_string("ctrl", src)
			return add_content(pos, payload)
		elseif topic == "update_content" then
			M(pos):set_string("ctrl", src)
			return update_content(pos, payload)
		elseif topic == "remove_content" then
			M(pos):set_string("ctrl", src)
			return remove_content(pos, payload)
		elseif topic == "private" then
			M(pos):set_string("public", "false")
		elseif topic == "public" then
			M(pos):set_string("public", "true")
		end
	end,
})