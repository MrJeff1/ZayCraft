-- inventory/item_registry.lua
local Registry = {}

Registry.items = {}

function Registry.register(id, def)
    Registry.items[id] = def
end

function Registry.get(id)
    return Registry.items[id]
end

return Registry
