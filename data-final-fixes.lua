local prefix = settings.startup['replace-landfill'].value and 'landfill' or 'platform'
local technology = data.raw.technology[prefix]
local item = data.raw.item[prefix]

if prefix == 'landfill' then
	for _, v in ipairs(technology.effects) do
		if v.type == 'unlock-recipe' and v.recipe == 'landfill' then
			goto included
		end
	end
	technology.effects[#technology.effects + 1] = {type='unlock-recipe', recipe='landfill'}
	::included::
	
	item.icon = '__platforms__/graphics/icons/platform.png'
	item.icon_size = 32
end