-- systems/physics.lua
-- Optimized collision detection.

local Physics = {}

-- Cache for solid tile checks
local solid_cache = {}
local cache_size = 0
local MAX_CACHE = 1000

-- Check if a tile at world coordinates is solid (with caching)
local function is_solid(world, wx, wy)
    local tx, ty = math.floor(wx), math.floor(wy)
    local key = tx .. "," .. ty
    
    -- Check cache
    if solid_cache[key] ~= nil then
        return solid_cache[key]
    end
    
    -- Get tile and determine if solid
    local tile_id = world:get_tile(tx, ty)
    local solid = tile_id ~= "air" and tile_id ~= "water"
    
    -- Cache the result
    solid_cache[key] = solid
    cache_size = cache_size + 1
    
    -- Limit cache size
    if cache_size > MAX_CACHE then
        -- Clear cache periodically (simplified)
        solid_cache = {}
        cache_size = 0
    end
    
    return solid
end

-- Resolve collision for an entity (optimized)
function Physics.resolve(entity, world, dt)
    -- Only check if moving
    if entity.vx == 0 and entity.vy == 0 then
        return
    end
    
    local new_x = entity.x + entity.vx * dt
    local new_y = entity.y + entity.vy * dt
    
    -- X axis movement
    if entity.vx ~= 0 then
        entity.x = new_x
        local left = entity.x - entity.width/2
        local right = entity.x + entity.width/2
        local top = entity.y - entity.height/2
        local bottom = entity.y + entity.height/2
        
        -- Only check tiles in the direction of movement
        local start_y = math.max(math.floor(top), -1000)
        local end_y = math.min(math.floor(bottom), 1000)
        
        if entity.vx > 0 then
            -- Moving right
            for y = start_y, end_y do
                if is_solid(world, right, y) then
                    entity.x = math.floor(right) - entity.width/2
                    entity.vx = 0
                    break
                end
            end
        else
            -- Moving left
            for y = start_y, end_y do
                if is_solid(world, left, y) then
                    entity.x = math.floor(left) + 1 + entity.width/2
                    entity.vx = 0
                    break
                end
            end
        end
    end
    
    -- Y axis movement
    if entity.vy ~= 0 then
        entity.y = new_y
        local left = entity.x - entity.width/2
        local right = entity.x + entity.width/2
        local top = entity.y - entity.height/2
        local bottom = entity.y + entity.height/2
        
        local start_x = math.max(math.floor(left), -1000)
        local end_x = math.min(math.floor(right), 1000)
        
        if entity.vy > 0 then
            -- Moving down
            for x = start_x, end_x do
                if is_solid(world, x, bottom) then
                    entity.y = math.floor(bottom) - entity.height/2
                    entity.vy = 0
                    break
                end
            end
        else
            -- Moving up
            for x = start_x, end_x do
                if is_solid(world, x, top) then
                    entity.y = math.floor(top) + 1 + entity.height/2
                    entity.vy = 0
                    break
                end
            end
        end
    end
end

return Physics