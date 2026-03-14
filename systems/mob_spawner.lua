-- systems/mob_spawner.lua
-- Handles mob spawning based on light level and time

local Mob = require("entities.mob")

local MobSpawner = {}
MobSpawner.__index = MobSpawner

function MobSpawner.new()
    local self = setmetatable({}, MobSpawner)
    self.mobs = {}
    self.spawn_timer = 0
    self.spawn_interval = 5 -- Try to spawn every 5 seconds
    self.max_mobs = 50
    return self
end

function MobSpawner:update(dt, world, player)
    self.spawn_timer = self.spawn_timer + dt

    -- Clean up dead mobs
    for i = #self.mobs, 1, -1 do
        if self.mobs[i].health <= 0 then
            table.remove(self.mobs, i)
        end
    end

    -- Spawn new mobs
    if self.spawn_timer >= self.spawn_interval and #self.mobs < self.max_mobs then
        self.spawn_timer = 0

        -- Try to spawn a mob near the player but not too close
        local attempts = 10
        for i = 1, attempts do
            local angle = math.random() * math.pi * 2
            local distance = math.random(15, 25)
            local spawn_x = player.x + math.cos(angle) * distance
            local spawn_y = player.y + math.sin(angle) * distance

            -- Check if spawn location is valid (not in solid blocks)
            local tile = world:get_tile(math.floor(spawn_x), math.floor(spawn_y))
            if tile and (tile == "grass" or tile == "forest" or tile == "sand") then
                -- Choose mob type based on biome and time
                local mob_type
                local hour = (os.time() % 24000) / 1000 -- Rough time of day

                if hour > 18 or hour < 6 then           -- Night time
                    local r = math.random()
                    if r < 0.4 then
                        mob_type = "zombie"
                    elseif r < 0.7 then
                        mob_type = "skeleton"
                    elseif r < 0.9 then
                        mob_type = "spider"
                    else
                        mob_type = "creeper"
                    end
                else                        -- Day time - fewer mobs
                    if math.random() < 0.3 then
                        mob_type = "zombie" -- Still some zombies in dark areas
                    else
                        return              -- Don't spawn during day
                    end
                end

                local mob = Mob.new(spawn_x, spawn_y, mob_type)
                table.insert(self.mobs, mob)
                ZLC.logger.debug("Spawned " .. mob_type .. " at " .. spawn_x .. "," .. spawn_y)
                break
            end
        end
    end

    -- Update all mobs
    for _, mob in ipairs(self.mobs) do
        mob:update(dt, world, player)
    end
end

function MobSpawner:draw()
    for _, mob in ipairs(self.mobs) do
        mob:draw()
    end
end

function MobSpawner:check_collisions(entity)
    for _, mob in ipairs(self.mobs) do
        -- Simple AABB collision check
        if math.abs(mob.x - entity.x) < (mob.width + entity.width) / 2 and
            math.abs(mob.y - entity.y) < (mob.height + entity.height) / 2 then
            return mob
        end
    end
    return nil
end

return MobSpawner
