-- states/game.lua
-- Main game state with world loading, mobs, and inventory

local World = require("world.world")
local Player = require("entities.player")
local Camera = require("renderer.camera")
local TilemapRenderer = require("renderer.tilemap_renderer")
local Physics = require("systems.physics")
local MobSpawner = require("systems.mob_spawner")
local serpent = require("lib.serpent")
local UI = require("lib.ui")

local Game = {}
Game.__index = Game

function Game.new(world_name)
    local self = setmetatable({}, Game)
    self.world_name = world_name
    return self
end

function Game:enter()
    ZLC.logger.info("Entering game world: " .. (self.world_name or "new"))

    -- Hide system cursor (custom cursor drawn globally)
    love.mouse.setVisible(false)

    if self.world_name then
        self:load_world(self.world_name)
    else
        self.world = World.new(os.time())
        self.player = Player.new(0, 0)
        self.mode = "survival"
    end

    self.camera = Camera.new()
    self.tile_renderer = TilemapRenderer.new()
    self.mob_spawner = MobSpawner.new()
    self.debug_mode = false
    self.game_time = 6000
    self.day_length = 24000
end

function Game:load_world(name)
    local path = "worlds/" .. name .. "/"
    local success, data = pcall(love.filesystem.read, path .. "world.dat")
    if success and data then
        local world_data = serpent.load(data)
        if type(world_data) == "table" then
            self.world = World.new(world_data.seed or os.time())
            self.player = Player.new(world_data.player_x or 0, world_data.player_y or 0)
            self.game_time = world_data.game_time or 6000
            self.mode = world_data.mode or "survival"
            ZLC.logger.info("Loaded world: " .. name)
        else
            ZLC.logger.warn("World data corrupted, creating new world")
            self.world = World.new(os.time())
            self.player = Player.new(0, 0)
            self.mode = "survival"
        end
    else
        ZLC.logger.info("No save found, creating new world")
        self.world = World.new(os.time())
        self.player = Player.new(0, 0)
        self.mode = "survival"
    end
end

function Game:save_world()
    if not self.world_name then return end
    local path = "worlds/" .. self.world_name .. "/"
    local world_data = {
        name = self.world_name,
        seed = self.world.seed,
        player_x = self.player.x,
        player_y = self.player.y,
        game_time = self.game_time,
        mode = self.mode,
        version = "0.2.0",
        last_saved = os.date("%Y-%m-%d %H:%M:%S")
    }
    love.filesystem.write(path .. "world.dat", serpent.dump(world_data))
    ZLC.logger.info("World saved: " .. self.world_name)
end

function Game:exit()
    if self.world_name then
        self:save_world()
    end
    love.mouse.setVisible(true) -- restore system cursor
    ZLC.logger.info("Exiting game world")
end

function Game:update(dt)
    self.game_time = (self.game_time + dt * 1000) % self.day_length

    self.player:update(dt)
    Physics.resolve(self.player, self.world, dt)

    if self.mode == "survival" then
        self.mob_spawner:update(dt, self.world, self.player)
        local mob = self.mob_spawner:check_collisions(self.player)
        if mob and mob.attack_cooldown <= 0 then
            mob:attack(self.player)
            -- Player damage logic would go here
        end
    end

    local screen_center_x = (love.graphics.getWidth() / 2) / self.camera.scale
    local screen_center_y = (love.graphics.getHeight() / 2) / self.camera.scale
    local target_x = self.player.x * 32 - screen_center_x
    local target_y = self.player.y * 32 - screen_center_y
    self.camera:follow(target_x, target_y, dt)

    local cx = math.floor(self.player.x / 16)
    local cy = math.floor(self.player.y / 16)
    self.world:update_center(cx, cy)
end

function Game:draw()
    self.camera:apply()

    for _, chunk in pairs(self.world.chunks) do
        self.tile_renderer:draw_chunk(chunk, ZLC.registry.tiles, self.camera)
    end

    self.mob_spawner:draw()
    self.player:draw()

    if self.debug_mode then
        love.graphics.setColor(1, 0, 0, 0.3)
        for _, chunk in pairs(self.world.chunks) do
            love.graphics.rectangle("line", chunk.cx * 16 * 32, chunk.cy * 16 * 32, 16 * 32, 16 * 32)
        end
    end

    self.camera:reset()

    -- HUD
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local margin = 20
    local hour = math.floor(self.game_time / 1000)
    local minute = math.floor((self.game_time % 1000) * 60 / 1000)
    local time_string = string.format("%02d:%02d", hour, minute)

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", margin - 5, margin - 5, 320, 170, 10, 10)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(UI.get_font(16))
    love.graphics.print("FPS: " .. love.timer.getFPS(), margin, margin)
    love.graphics.print("Time: " .. time_string, margin, margin + 20)
    love.graphics.print("Mode: " .. self.mode:upper(), margin, margin + 40)
    love.graphics.print("Pos: " .. math.floor(self.player.x) .. ", " .. math.floor(self.player.y), margin, margin + 60)
    love.graphics.print("Mobs: " .. #self.mob_spawner.mobs, margin, margin + 80)

    local tile = self.world:get_tile(math.floor(self.player.x), math.floor(self.player.y))
    love.graphics.print("Biome: " .. (ZLC.registry.tiles[tile] and ZLC.registry.tiles[tile].name or "Unknown"), margin,
        margin + 100)

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", w - 270, h - 40, 250, 30, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("ESC: Menu | F3: Debug | F5: Save | E: Inventory", w - 260, h - 32)
end

function Game:keypressed(key)
    if key == "escape" then
        ZLC.state.pop()
        return true
    elseif key == "f3" then
        self.debug_mode = not self.debug_mode
        return true
    elseif key == "f5" then
        self:save_world()
        return true
    elseif key == "e" then
        local InventoryScreen = require("ui.inventory_screen")
        ZLC.state.push(InventoryScreen.new(self.player))
        return true
    end
    return false
end

return Game
