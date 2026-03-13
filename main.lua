-- main.lua
-- Entry point for ZayCraft Legends.

if not love then
    print("This game must be run with the Love2D engine.")
    print("Download from: https://love2d.org")
    return
end

-- Simple require with core prefix
local function require_core(name)
    return require("core." .. name)
end

-- Load core modules
local Logger = require_core("logger")
local StateManager = require_core("state_manager")
local EventBus = require_core("event_bus")
local Engine = require_core("engine")
local Registry = require_core("registry")
local SaveManager = require_core("save_manager")

-- Global references
ZLC = {
    logger = Logger,
    state = StateManager,
    events = EventBus,
    registry = Registry,
    save = SaveManager,
    engine = nil,
}

-- Load game modules
local World = require("world.world")
local Player = require("entities.player")
local Camera = require("renderer.camera")
local TilemapRenderer = require("renderer.tilemap_renderer")
local Physics = require("systems.physics")

-- Tile registry (temporary, will move to registry.lua later)
local TILE_REGISTRY = {
    air = { name = "Air", color = {0,0,0,0}, solid = false },
    grass = { name = "Grass", color = {0.2, 0.8, 0.2}, solid = true },
    dirt = { name = "Dirt", color = {0.6, 0.4, 0.2}, solid = true },
    stone = { name = "Stone", color = {0.5, 0.5, 0.5}, solid = true },
}

-- Game state
local Game = {}

function Game:enter()
    Logger.info("Entering game world")
    self.world = World.new(os.time())
    self.player = Player.new(0, 0)
    self.camera = Camera.new()
    self.tile_renderer = TilemapRenderer.new()
end

function Game:exit()
    Logger.info("Exiting game world")
end

function Game:update(dt)
    -- Update player
    self.player:update(dt)
    
    -- Simple collision
    Physics.resolve(self.player, self.world, dt)
    
    -- Update camera to follow player (pixel coordinates)
    self.camera:follow(self.player.x * 32, self.player.y * 32, dt)
    
    -- Update world loading around player
    local cx = math.floor(self.player.x / 16)
    local cy = math.floor(self.player.y / 16)
    self.world:update_center(cx, cy)
end

function Game:draw()
    self.camera:apply()
    
    -- Draw chunks
    for key, chunk in pairs(self.world.chunks) do
        self.tile_renderer:draw_chunk_simple(chunk, TILE_REGISTRY)
    end
    
    -- Draw player
    self.player:draw()
    
    self.camera:reset()
    
    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Pos: " .. math.floor(self.player.x) .. ", " .. math.floor(self.player.y), 10, 30)
end

function Game:keypressed(key)
    if key == "escape" then
        StateManager.pop()  -- back to main menu
        return true
    end
    return false
end

-- Main menu state
local MainMenu = {}

function MainMenu:enter()
    Logger.info("Entered main menu")
end

function MainMenu:exit()
    Logger.info("Exited main menu")
end

function MainMenu:update(dt) end

function MainMenu:draw()
    love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local title = "ZayCraft Legends"
    local prompt = "Press any key to continue"
    love.graphics.print(title, (love.graphics.getWidth() - font:getWidth(title)) / 2, 200)
    love.graphics.print(prompt, (love.graphics.getWidth() - font:getWidth(prompt)) / 2, 300)
end

function MainMenu:keypressed(key)
    if key == "escape" then
        love.event.quit()
    else
        StateManager.push(Game)
    end
    return true
end

function love.load()
    Logger.info("ZayCraft Legends starting up...")
    Logger.info("Love2D version: " .. love.getVersion())

    Registry.init()
    SaveManager.init()
    ZLC.engine = Engine.new()

    -- Push main menu
    StateManager.push(MainMenu)
end

function love.update(dt)
    ZLC.engine:update(dt)
end

function love.draw()
    ZLC.engine:draw()
end

function love.keypressed(key, scancode, isrepeat)
    return StateManager.keypressed(key, scancode, isrepeat)
end

function love.quit()
    if Logger then
        Logger.info("Shutting down ZayCraft Legends.")
    end
    return false
end