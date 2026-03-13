-- systems/physics.lua
-- Collision detection and resolution for entities against solid tiles.

local Physics = {}

-- Check if a tile at world coordinates is solid
local function is_solid(world, wx, wy)
    local tile_id = world:get_tile(math.floor(wx), math.floor(wy))
    -- We need a tile registry. For now, assume we have a global registry.
    -- We'll pass registry as argument later.
    -- Simplified: assume tile IDs "grass", "dirt", "stone" are solid, "air" is not.
    if tile_id == "air" then
        return false
    else
        return true
    end
end

-- Resolve collision for an entity
function Physics.resolve(entity, world, dt)
    -- Simple AABB collision with tile grid
    -- We'll implement a basic sweep later; for now just prevent going into solid tiles.
    local new_x = entity.x + entity.vx * dt
    local new_y = entity.y + entity.vy * dt
    
    -- Check X axis
    entity.x = new_x
    if entity.vx ~= 0 then
        -- Check corners
        local left = entity.x - entity.width/2
        local right = entity.x + entity.width/2
        local top = entity.y - entity.height/2
        local bottom = entity.y + entity.height/2
        
        local tiles_to_check = {}
        -- Collect all integer tile positions that the entity overlaps
        for y = math.floor(top), math.floor(bottom) do
            if entity.vx > 0 then
                -- moving right, check right edge
                if is_solid(world, right, y) then
                    entity.x = math.floor(right) - entity.width/2
                    entity.vx = 0
                    break
                end
            else
                -- moving left, check left edge
                if is_solid(world, left, y) then
                    entity.x = math.floor(left) + 1 + entity.width/2
                    entity.vx = 0
                    break
                end
            end
        end
    end
    
    -- Check Y axis
    entity.y = new_y
    if entity.vy ~= 0 then
        local left = entity.x - entity.width/2
        local right = entity.x + entity.width/2
        local top = entity.y - entity.height/2
        local bottom = entity.y + entity.height/2
        
        for x = math.floor(left), math.floor(right) do
            if entity.vy > 0 then
                -- moving down, check bottom edge
                if is_solid(world, x, bottom) then
                    entity.y = math.floor(bottom) - entity.height/2
                    entity.vy = 0
                    break
                end
            else
                -- moving up, check top edge
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