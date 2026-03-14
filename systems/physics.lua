-- systems/physics.lua
-- Optimized collision detection

local Physics = {}

-- Cache for tile lookups
local tile_cache = {}
local CACHE_SIZE = 0
local MAX_CACHE = 500

function Physics.resolve(entity, world, dt)
    local original_x, original_y = entity.x, entity.y

    -- Try X movement
    local new_x = entity.x + entity.vx * dt
    entity.x = new_x

    if entity.vx ~= 0 and Physics.check_collision(entity, world) then
        entity.x = original_x
        entity.vx = 0
    end

    -- Try Y movement
    local new_y = entity.y + entity.vy * dt
    entity.y = new_y

    if entity.vy ~= 0 and Physics.check_collision(entity, world) then
        entity.y = original_y
        entity.vy = 0
    end
end

function Physics.check_collision(entity, world)
    -- Get tile-aligned bounding box
    local left = math.floor(entity.x - entity.width / 2)
    local right = math.floor(entity.x + entity.width / 2)
    local top = math.floor(entity.y - entity.height / 2)
    local bottom = math.floor(entity.y + entity.height / 2)

    -- Limit checks to reasonable bounds
    left = math.max(left, -1000)
    right = math.min(right, 1000)
    top = math.max(top, -1000)
    bottom = math.min(bottom, 1000)

    -- Check all tiles the entity overlaps
    for x = left, right do
        for y = top, bottom do
            -- Check cache first
            local cache_key = x .. "," .. y
            local tile = tile_cache[cache_key]

            if not tile then
                tile = world:get_tile(x, y)
                -- Cache the result
                tile_cache[cache_key] = tile
                CACHE_SIZE = CACHE_SIZE + 1

                -- Clear cache if too big
                if CACHE_SIZE > MAX_CACHE then
                    tile_cache = {}
                    CACHE_SIZE = 0
                end
            end

            if tile and tile ~= "air" and tile ~= "water" then
                return true
            end
        end
    end
    return false
end

return Physics
