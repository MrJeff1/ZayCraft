-- entities/entity.lua
-- Base class for all entities (player, mobs, items).

local Entity = {}
Entity.__index = Entity

function Entity.new(x, y)
    local self = setmetatable({}, Entity)
    self.x = x or 0
    self.y = y or 0
    self.vx = 0
    self.vy = 0
    self.width = 0.8  -- tile width in tiles (collision size)
    self.height = 0.8
    return self
end

function Entity:update(dt)
    -- Apply velocity (simple)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
end

function Entity:draw()
    -- To be overridden
end

return Entity
