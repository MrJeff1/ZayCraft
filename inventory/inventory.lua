-- inventory/inventory.lua
local Inventory = {}
Inventory.__index = Inventory

function Inventory.new(size)
    local self = setmetatable({}, Inventory)
    self.size = size or 27
    self.slots = {}
    for i = 1, self.size do
        self.slots[i] = { id = nil, count = 0 }
    end
    return self
end

function Inventory:add_item(id, count)
    count = count or 1
    local item_def = ZLC.item_registry.get(id)
    if not item_def then return false end

    -- Try to stack with existing
    for i = 1, self.size do
        if self.slots[i].id == id and self.slots[i].count < item_def.stack_size then
            local space = item_def.stack_size - self.slots[i].count
            local add = math.min(space, count)
            self.slots[i].count = self.slots[i].count + add
            count = count - add
            if count == 0 then return true end
        end
    end

    -- Fill empty slots
    for i = 1, self.size do
        if self.slots[i].id == nil then
            self.slots[i].id = id
            self.slots[i].count = math.min(count, item_def.stack_size)
            count = count - self.slots[i].count
            if count == 0 then return true end
        end
    end

    return false -- Not enough space
end

function Inventory:remove_item(id, count)
    count = count or 1
    for i = 1, self.size do
        if self.slots[i].id == id then
            local remove = math.min(self.slots[i].count, count)
            self.slots[i].count = self.slots[i].count - remove
            count = count - remove
            if self.slots[i].count == 0 then
                self.slots[i].id = nil
            end
            if count == 0 then return true end
        end
    end
    return count == 0
end

function Inventory:get_slot(index)
    return self.slots[index]
end

return Inventory
