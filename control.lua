local ceil = math.ceil

local normal = settings.startup['replace-landfill'].value and 'landfill' or 'platform'
local unbreakable = 'unbreakable-' .. normal

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event)
	local entity = event.created_entity
	
	if entity.type == 'tile-ghost' or entity.has_flag('placeable-off-grid') or entity.type == 'curved-rail' then return end
	
	local position = entity.position
	local surface = entity.surface
	
	local selection_box = entity.selection_box
    local top_left_x = ceil(selection_box.left_top.x * 2) / 2
    local top_left_y = ceil(selection_box.left_top.y * 2) / 2
    local right_bottom_x = ceil(selection_box.right_bottom.x * 2) / 2
    local right_bottom_y = ceil(selection_box.right_bottom.y * 2) / 2
	
	if top_left_x == right_bottom_x or top_left_y == right_bottom_y then return end
	
	local tiles = {}
	
	for _, tile in pairs(surface.find_tiles_filtered{area = {{top_left_x, top_left_y}, {right_bottom_x, right_bottom_y}}, name = normal}) do
		tiles[#tiles + 1] = {name = unbreakable, position = tile.position}
	end
	
	if tiles then surface.set_tiles(tiles) end
end)

local function on_destroy(event)
	local entity = event.entity
	
	if entity.type == 'tile-ghost' or entity.has_flag('placeable-off-grid') or entity.type == 'curved-rail' then return end
	
	local position = entity.position
	local surface = entity.surface
	
	local selection_box = entity.selection_box
    local top_left_x = ceil(selection_box.left_top.x * 2) / 2
    local top_left_y = ceil(selection_box.left_top.y * 2) / 2
    local right_bottom_x = ceil(selection_box.right_bottom.x * 2) / 2
    local right_bottom_y = ceil(selection_box.right_bottom.y * 2) / 2
	
	if top_left_x == right_bottom_x or top_left_y == right_bottom_y then return end
	
	local water_tiles = {}
	local ground_tiles = {}
	
	for _, tile in pairs(surface.find_tiles_filtered{area = {{top_left_x, top_left_y}, {right_bottom_x, right_bottom_y}}, name = unbreakable}) do
		local tile_position = tile.position
		water_tiles[#water_tiles + 1] = {name = 'water', position = tile_position}
		ground_tiles[#ground_tiles + 1] = {name = normal, position = tile_position}
	end
	
	surface.set_tiles(water_tiles, false, false, false, false)
	surface.set_tiles(ground_tiles)
end

script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity, defines.events.on_entity_died, defines.events.script_raised_destroy}, on_destroy)
script.on_event({defines.events.on_pre_ghost_deconstructed}, function(event) on_destroy{entity = event.ghost} end)

script.on_event({defines.events.on_player_built_tile, defines.events.on_robot_built_tile}, function(event)
	if event.tile.name == normal then return end
	
	local surface = game.surfaces[event.surface_index]
	
	local tiles = {}
	local change_count = 0
	
	for _, tile in pairs(event.tiles) do
		if tile.old_tile.name == normal then
			tiles[#tiles + 1] = {name = unbreakable, position = tile.position}
			tiles[#tiles + 1] = {name = event.tile.name, position = tile.position}
			change_count = change_count + 1
		end
	end
	
	if change_count ~= 0 then
		surface.set_tiles(tiles)
		local entity = event.robot or game.players[event.player_index]
		entity.remove_item{name = normal, count = change_count}
	end
end)

script.on_event({defines.events.on_player_mined_tile, defines.events.on_robot_mined_tile}, function(event)
	local surface = game.surfaces[event.surface_index]
	
	for _, tile in pairs(event.tiles) do
		if tile.old_tile.name ~= normal then
			local tile_position = tile.position
			if surface.get_tile(tile_position).name == unbreakable then
				local place = true
				for _, entity in pairs(surface.find_entities{tile_position, {tile_position.x + 1, tile_position.y + 1}}) do
					if entity.has_flag('placeable-player') and entity.tags == nil and entity.type ~= 'tile-ghost' and not entity.has_flag('placeable-off-grid') and entity.type ~= 'curved-rail' then
						place = false
						break
					end
				end
				if place then
					surface.set_tiles({{name = 'water', position = tile_position}}, false, false, false, false)
					surface.set_tiles({{name = normal, position = tile_position}})
				end
			end
		end
	end
end)