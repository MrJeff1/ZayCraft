-- renderer/camera.lua
-- Camera with smooth follow and zoom.

local Camera = {}
Camera.__index = Camera

function Camera.new()
    local self = setmetatable({}, Camera)
    self.x = 0
    self.y = 0
    self.scale = 2.0 -- zoom level (pixels per tile? we'll use 32x32 tiles)
    self.lerp = 0.1  -- smooth follow factor
    return self
end

function Camera:follow(target_x, target_y, dt)
    -- Smoothly move toward target
    self.x = self.x + (target_x - self.x) * self.lerp * math.min(dt * 60, 1)
    self.y = self.y + (target_y - self.y) * self.lerp * math.min(dt * 60, 1)
end

function Camera:apply()
    -- Transform Love2D graphics
    love.graphics.push()
    love.graphics.scale(self.scale, self.scale)
    love.graphics.translate(-math.floor(self.x), -math.floor(self.y))
end

function Camera:reset()
    love.graphics.pop()
end

-- Convert screen coordinates to world coordinates
function Camera:screen_to_world(sx, sy)
    local wx = sx / self.scale + self.x
    local wy = sy / self.scale + self.y
    return wx, wy
end

return Camera
