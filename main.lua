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
local Settings = require_core("settings")

-- Global references
ZLC = {
    logger = Logger,
    state = StateManager,
    events = EventBus,
    registry = Registry,
    save = SaveManager,
    settings = nil,
    engine = nil,
    textures = {},
    cursor = nil,
    item_registry = nil, -- Will be set after item system loads
}

function love.load()
    Logger.info("ZayCraft Legends starting up...")
    Logger.info("Love2D version: " .. love.getVersion())

    -- Load settings
    ZLC.settings = Settings.load()

    -- Set default graphics
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(love.graphics.newFont(16))

    -- Initialize core systems
    Registry.init()
    SaveManager.init()
    ZLC.engine = Engine.new()

    -- Load textures
    ZLC:load_textures()

    -- Load custom cursor
    if love.filesystem.getInfo("assets/ui/cursor.png") then
        ZLC.cursor = love.graphics.newImage("assets/ui/cursor.png")
    end

    -- Initialize item registry (will be populated later)
    ZLC.item_registry = require("inventory.item_registry")
    ZLC:register_items()

    -- Register tiles
    Registry.register_tile("grass", { name = "Grass", texture = ZLC.textures.tiles.grass, solid = true })
    Registry.register_tile("dirt", { name = "Dirt", texture = ZLC.textures.tiles.dirt, solid = true })
    Registry.register_tile("stone", { name = "Stone", texture = ZLC.textures.tiles.stone, solid = true })
    Registry.register_tile("water", { name = "Water", texture = ZLC.textures.tiles.water, solid = false })
    Registry.register_tile("sand", { name = "Sand", texture = ZLC.textures.tiles.sand, solid = true })
    Registry.register_tile("forest", { name = "Forest", texture = ZLC.textures.tiles.forest, solid = true })
    Registry.register_tile("mountain", { name = "Mountain", texture = ZLC.textures.tiles.mountain, solid = true })

    -- Push main menu
    local MainMenu = require("states.main_menu")
    StateManager.push(MainMenu.new())

    -- Hide mouse cursor
    love.mouse.setVisible(false)
    Logger.info("Custom Mouse Cursor Set")
end

function ZLC:load_textures()
    self.textures = { tiles = {}, mobs = {} }
    local tile_files = { "grass", "dirt", "stone", "water", "sand", "forest", "mountain" }
    for _, name in ipairs(tile_files) do
        local path = "assets/textures/tiles/" .. name .. ".png"
        local success, tex = pcall(love.graphics.newImage, path)
        if success then
            self.textures.tiles[name] = tex
            Logger.debug("Loaded texture: " .. path)
        else
            Logger.warn("Failed to load texture: " .. path)
            -- fallback colored rectangle
            local canvas = love.graphics.newCanvas(32, 32)
            love.graphics.setCanvas(canvas)
            love.graphics.clear(0.5, 0.5, 0.5, 1)
            love.graphics.setCanvas()
            self.textures.tiles[name] = canvas
        end
    end

    local mob_files = { "zombie", "skeleton", "creeper", "spider", "player" }
    for _, name in ipairs(mob_files) do
        local path = "assets/textures/mobs/" .. name .. ".png"
        local success, tex = pcall(love.graphics.newImage, path)
        if success then
            self.textures.mobs[name] = tex
            Logger.debug("Loaded texture: " .. path)
        else
            Logger.warn("Failed to load texture: " .. path)
        end
    end
end

function ZLC:register_items()
    -- Simple items (placeholders)
    local Item = require("inventory.item")
    self.item_registry.register("dirt_block",
        Item.new("dirt_block", { name = "Dirt Block", texture = self.textures.tiles.dirt, type = "block" }))
    self.item_registry.register("stone_block",
        Item.new("stone_block", { name = "Stone Block", texture = self.textures.tiles.stone, type = "block" }))
    self.item_registry.register("grass_block",
        Item.new("grass_block", { name = "Grass Block", texture = self.textures.tiles.grass, type = "block" }))
    self.item_registry.register("wood", Item.new("wood", { name = "Wood", texture = nil, type = "material" })) -- no texture yet
end

function love.update(dt)
    ZLC.engine:update(dt)
end

function love.draw()
    StateManager.draw()
    -- Draw global custom cursor
    if ZLC.cursor then
        local mx, my = love.mouse.getPosition()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(ZLC.cursor, mx, my)
    end
end

function love.keypressed(key, scancode, isrepeat)
    return StateManager.keypressed(key, scancode, isrepeat)
end

function love.mousepressed(x, y, button, istouch, presses)
    local current = StateManager.current()
    if current and current.mousepressed then
        return current:mousepressed(x, y, button, istouch, presses)
    end
    return false
end

-- Mobile touch support
function love.touchpressed(id, x, y, dx, dy, pressure)
    return love.mousepressed(x, y, 1, true, 1)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    local current = StateManager.current()
    if current and current.mousereleased then
        return current:mousereleased(x, y, 1, true, 1)
    end
    return false
end

function love.quit()
    if ZLC.settings then
        ZLC.settings:save()
    end
    if Logger then
        Logger.info("Shutting down ZayCraft Legends.")
    end
    return false
end
