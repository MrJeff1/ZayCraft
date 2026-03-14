-- inventory/item.lua
local Item = {}
Item.__index = Item

function Item.new(id, def)
    local self = setmetatable({}, Item)
    self.id = id
    self.name = def.name or id
    self.stack_size = def.stack_size or 64
    self.texture = def.texture
    self.type = def.type or "misc" -- tool, weapon, armor, food, block
    return self
end

return Item
