-- entities/mob.lua
-- Base mob class with AI and textures

local Entity = require("entities.entity")
local Mob = setmetatable({}, { __index = Entity })
Mob.__index = Mob

function Mob.new(x, y, type)
    local self = setmetatable(Entity.new(x, y), Mob)
    self.type = type or "zombie"
    self.speed = 2
    self.health = 20
    self.max_health = 20
    self.attack_damage = 3
    self.attack_cooldown = 0
    self.attack_range = 1.5
    self.detection_range = 10
    self.state = "idle"
    self.wander_timer = 0
    self.wander_direction = { x = 0, y = 0 }
    self.target = nil

    -- Get texture from global registry
    self.texture = ZLC.textures.mobs[type]

    -- Mob type properties
    if type == "zombie" then
        self.speed = 1.5
        self.health = 20
        self.attack_damage = 4
    elseif type == "skeleton" then
        self.speed = 2.5
        self.health = 15
        self.attack_damage = 3
    elseif type == "creeper" then
        self.speed = 1.8
        self.health = 10
        self.attack_damage = 20
    elseif type == "spider" then
        self.speed = 3
        self.health = 16
        self.attack_damage = 3
    end

    return self
end

function Mob:update(dt, world, player)
    -- Update attack cooldown
    if self.attack_cooldown > 0 then
        self.attack_cooldown = self.attack_cooldown - dt
    end

    -- Check distance to player
    if player then
        local dx = player.x - self.x
        local dy = player.y - self.y
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist < self.detection_range then
            self.target = player
            if dist < self.attack_range then
                self.state = "attacking"
            else
                self.state = "chasing"
            end
        else
            self.target = nil
            if self.state ~= "wandering" then
                self.state = "idle"
            end
        end
    end

    -- State machine
    if self.state == "idle" then
        self.vx = 0
        self.vy = 0
        self.wander_timer = self.wander_timer - dt
        if self.wander_timer <= 0 then
            self.state = "wandering"
            self.wander_timer = math.random(3, 8)
            self.wander_direction.x = math.random() * 2 - 1
            self.wander_direction.y = math.random() * 2 - 1
            local len = math.sqrt(self.wander_direction.x ^ 2 + self.wander_direction.y ^ 2)
            if len > 0 then
                self.wander_direction.x = self.wander_direction.x / len
                self.wander_direction.y = self.wander_direction.y / len
            end
        end
    elseif self.state == "wandering" then
        self.vx = self.wander_direction.x * self.speed
        self.vy = self.wander_direction.y * self.speed
        self.wander_timer = self.wander_timer - dt
        if self.wander_timer <= 0 then
            self.state = "idle"
            self.wander_timer = math.random(2, 5)
        end
    elseif self.state == "chasing" and self.target then
        local dx = self.target.x - self.x
        local dy = self.target.y - self.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > 0 then
            self.vx = (dx / dist) * self.speed
            self.vy = (dy / dist) * self.speed
        end
    elseif self.state == "attacking" and self.target and self.attack_cooldown <= 0 then
        self:attack(self.target)
        self.attack_cooldown = 1.5
    end

    Entity.update(self, dt)
end

function Mob:attack(target)
    if self.type == "creeper" then
        ZLC.logger.info("Creeper explodes!")
        self.health = 0
    else
        ZLC.logger.info(self.type .. " attacks for " .. self.attack_damage .. " damage")
    end
end

function Mob:draw()
    -- Draw mob with texture
    if self.texture then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.texture,
            (self.x - self.width / 2) * 32,
            (self.y - self.height / 2) * 32)
    else
        -- Fallback colored rectangle
        local colors = {
            zombie = { 0.2, 0.5, 0.2 },
            skeleton = { 0.8, 0.8, 0.8 },
            creeper = { 0.1, 0.8, 0.1 },
            spider = { 0.4, 0.2, 0.4 }
        }
        love.graphics.setColor(colors[self.type] or { 1, 0, 1 })
        love.graphics.rectangle("fill",
            (self.x - self.width / 2) * 32,
            (self.y - self.height / 2) * 32,
            self.width * 32,
            self.height * 32)
    end

    -- Draw health bar
    if self.health < self.max_health then
        local health_percent = self.health / self.max_health
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill",
            (self.x - self.width / 2) * 32,
            (self.y - self.height / 2 - 10) * 32,
            self.width * 32,
            5)
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill",
            (self.x - self.width / 2) * 32,
            (self.y - self.height / 2 - 10) * 32,
            self.width * 32 * health_percent,
            5)
    end

    love.graphics.setColor(1, 1, 1)
end

return Mob
