-- core/registry.lua
-- Central registry for all game definitions

local Registry = {}
Registry.__index = Registry

-- Storage tables
Registry.blocks = {}   -- id -> block definition
Registry.items = {}    -- id -> item definition
Registry.entities = {} -- id -> entity definition
Registry.recipes = {}  -- list of recipes
Registry.tiles = {}    -- id -> tile definition

--- Initialize registry (called once at startup).
function Registry.init()
    Registry.blocks = {}
    Registry.items = {}
    Registry.entities = {}
    Registry.recipes = {}
    Registry.tiles = {}
end

--- Register a tile type.
-- @param id (string) Unique identifier (e.g., "grass").
-- @param def (table) Tile properties (name, color, solid, etc.).
-- @return true if registered, false if id already exists.
function Registry.register_tile(id, def)
    if Registry.tiles[id] then
        if Logger then
            Logger.warn(("Tile '%s' already registered, skipping."):format(id))
        end
        return false
    end
    Registry.tiles[id] = def
    return true
end

--- Get tile definition by id.
function Registry.get_tile(id)
    return Registry.tiles[id]
end

--- Register a block type.
function Registry.register_block(id, def)
    if Registry.blocks[id] then
        if Logger then
            Logger.warn(("Block '%s' already registered, skipping."):format(id))
        end
        return false
    end
    Registry.blocks[id] = def
    return true
end

--- Get block definition by id.
function Registry.get_block(id)
    return Registry.blocks[id]
end

--- Register an item type.
function Registry.register_item(id, def)
    if Registry.items[id] then
        if Logger then
            Logger.warn(("Item '%s' already registered, skipping."):format(id))
        end
        return false
    end
    Registry.items[id] = def
    return true
end

--- Get item definition by id.
function Registry.get_item(id)
    return Registry.items[id]
end

--- Register an entity type.
function Registry.register_entity(id, def)
    if Registry.entities[id] then
        if Logger then
            Logger.warn(("Entity '%s' already registered, skipping."):format(id))
        end
        return false
    end
    Registry.entities[id] = def
    return true
end

--- Get entity definition by id.
function Registry.get_entity(id)
    return Registry.entities[id]
end

--- Register a crafting recipe.
function Registry.register_recipe(recipe_def)
    table.insert(Registry.recipes, recipe_def)
end

--- Get all recipes.
function Registry.get_all_recipes()
    return Registry.recipes
end

return Registry
