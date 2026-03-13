-- core/registry.lua
-- Central registry for all game definitions: blocks, items, entities, recipes.

local Registry = {}
Registry.__index = Registry

Registry.blocks = {}
Registry.items = {}
Registry.entities = {}
Registry.recipes = {}

function Registry.init()
    Registry.blocks = {}
    Registry.items = {}
    Registry.entities = {}
    Registry.recipes = {}
end

function Registry.register_block(id, def)
    if Registry.blocks[id] then
        local logger = require("core.logger")
        logger.warn(("Block '%s' already registered, skipping."):format(id))
        return false
    end
    Registry.blocks[id] = def
    return true
end

function Registry.get_block(id)
    return Registry.blocks[id]
end

function Registry.register_item(id, def)
    if Registry.items[id] then
        local logger = require("core.logger")
        logger.warn(("Item '%s' already registered, skipping."):format(id))
        return false
    end
    Registry.items[id] = def
    return true
end

function Registry.get_item(id)
    return Registry.items[id]
end

function Registry.register_entity(id, def)
    if Registry.entities[id] then
        local logger = require("core.logger")
        logger.warn(("Entity '%s' already registered, skipping."):format(id))
        return false
    end
    Registry.entities[id] = def
    return true
end

function Registry.get_entity(id)
    return Registry.entities[id]
end

function Registry.register_recipe(recipe_def)
    table.insert(Registry.recipes, recipe_def)
end

function Registry.get_all_recipes()
    return Registry.recipes
end

return Registry
