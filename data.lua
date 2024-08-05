local theme = string.lower(settings.startup['platform-theme'].value)
local prefix = settings.startup['replace-landfill'].value and 'landfill' or 'platform'

local platform = table.deepcopy(data.raw.tile['stone-path'])
platform.name = prefix
platform.localised_name = {'tile-name.platform'}
platform.minable.result = prefix
platform.minable.mining_time = platform.minable.mining_time * 3
for i = 1, 3 do
	platform.variants.main[i].hr_version.picture = '__platforms__/graphics/terrain/hr-platform-' .. i .. '-' .. theme .. '.png'
	platform.variants.main[i].picture = '__platforms__/graphics/terrain/platform-' .. i .. '-' .. theme .. '.png'
    platform.variants.main[i].count = 1
    platform.variants.main[i].hr_version.count = 1
end
platform.variants.inner_corner.hr_version.picture = '__platforms__/graphics/terrain/hr-platform-inner-corner-' .. theme .. '.png'
platform.variants.inner_corner.picture = '__platforms__/graphics/terrain/platform-inner-corner-' .. theme .. '.png'
platform.variants.side.hr_version.picture = '__platforms__/graphics/terrain/hr-platform-side-' .. theme .. '.png'
platform.variants.side.picture = '__platforms__/graphics/terrain/platform-side-' .. theme .. '.png'
platform.can_be_part_of_blueprint = true
platform.autoplace = nil
platform.map_color = {r = 0.3, b = 0.32, g = 0.3}

local immortal_platform = table.deepcopy(platform)
immortal_platform.name = 'unbreakable-' .. prefix
immortal_platform.minable = nil

local technology = table.deepcopy(data.raw.technology['landfill'])
technology.name = prefix
technology.icon = '__platforms__/graphics/icons/platform-technology.png'
technology.icon_size = 128
technology.localised_name = {'technology-name.platform'}
technology.localised_description = {'technology-description.platform'}
if prefix == 'platform' then
	technology.prerequisites = {'stone-wall', 'landfill'}
	technology.effects = {{type = 'unlock-recipe', recipe = 'platform'}}
else
	technology.prerequisites[#technology.prerequisites + 1] = 'stone-wall'
end

data:extend{
	{
		type = 'recipe',
		name = prefix,
		enabled = data.raw.recipe['landfill'].enabled,
		energy_required = data.raw.recipe['landfill'].energy_required,
		ingredients = {
			{'iron-stick', 4},
			{'steel-plate', 2},
			{'stone-brick', 6}
		},
		result = prefix
	},
	{
		icon = '__platforms__/graphics/icons/platform.png',
		icon_size = 32,
		name = prefix,
		order = data.raw.item['landfill'].order,
		place_as_tile = {condition = {'ground-tile'}, condition_size = 1, result = prefix},
		stack_size = 1000,
		subgroup = 'terrain',
		type = 'item',
		localised_name = {'item-name.platform'}
	},
	platform,
	immortal_platform,
	technology
}

if mods.SeaBlock then
	data.raw.recipe[prefix].enabled = true
	if prefix == platform then
		data.raw.technology[prefix] = nil
	end
end
