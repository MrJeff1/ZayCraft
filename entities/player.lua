-- entities/player.lua
local Entity = require("entities.entity")
local Inventory = require("inventory.inventory")
local Player = setmetatable({}, { __index = Entity })
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable(Entity.new(x, y), Player)
    self.speed = 5
    self.texture = ZLC.textures.mobs.player
    self.inventory = Inventory.new(27)
    return self
end

function Player:update(dt)
    local move_x, move_y = 0, 0
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then move_y = move_y - 1 end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then move_y = move_y + 1 end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then move_x = move_x - 1 end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then move_x = move_x + 1 end

    if move_x ~= 0 and move_y ~= 0 then
        move_x = move_x * 0.7071
        move_y = move_y * 0.7071
    end

    self.vx = move_x * self.speed
    self.vy = move_y * self.speed

    Entity.update(self, dt)
end

function Player:draw()
    if self.texture then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.texture,
            (self.x - self.width / 2) * 32,
            (self.y - self.height / 2) * 32)
    else
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill",
            (self.x - self.width / 2) * 32,
            (self.y - self.height / 2) * 32,
            self.width * 32,
            self.height * 32)
    end
    love.graphics.setColor(1, 1, 1)
end

return Player
