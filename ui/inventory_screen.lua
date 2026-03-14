-- ui/inventory_screen.lua
local UI = require("lib.ui")

local InventoryScreen = {}
InventoryScreen.__index = InventoryScreen

function InventoryScreen.new(player)
    local self = setmetatable({}, InventoryScreen)
    self.player = player
    return self
end

function InventoryScreen:enter()
    ZLC.logger.info("Opened inventory")
end

function InventoryScreen:exit()
    ZLC.logger.info("Closed inventory")
end

function InventoryScreen:update(dt)
    -- Handle mouse hover for slots
    local mx, my = love.mouse.getPosition()
    self.hovered_slot = nil
    -- Slot grid: 9 columns, 3 rows, starting at (center-200, 150)
    local w, h = love.graphics.getDimensions()
    local start_x = w / 2 - 200
    local start_y = 150
    local slot_size = 48
    local padding = 5
    for row = 0, 2 do
        for col = 0, 8 do
            local x = start_x + col * (slot_size + padding)
            local y = start_y + row * (slot_size + padding)
            if mx >= x and mx <= x + slot_size and my >= y and my <= y + slot_size then
                self.hovered_slot = row * 9 + col + 1
                break
            end
        end
    end
end

function InventoryScreen:draw()
    local w, h = love.graphics.getDimensions()
    local start_x = w / 2 - 200
    local start_y = 150
    local slot_size = 48
    local padding = 5

    -- Background overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- Title
    UI.text_centered("Inventory", 50, 36)

    -- Draw slots
    for i = 1, 27 do
        local row = math.floor((i - 1) / 9)
        local col = (i - 1) % 9
        local x = start_x + col * (slot_size + padding)
        local y = start_y + row * (slot_size + padding)

        -- Slot background
        if self.hovered_slot == i then
            love.graphics.setColor(UI.colors.button_hover)
        else
            love.graphics.setColor(UI.colors.button)
        end
        love.graphics.rectangle("fill", x, y, slot_size, slot_size, 5, 5)
        love.graphics.setColor(UI.colors.text)
        love.graphics.rectangle("line", x, y, slot_size, slot_size, 5, 5)

        -- Draw item if present
        local slot = self.player.inventory:get_slot(i)
        if slot.id then
            local item_def = ZLC.item_registry.get(slot.id)
            if item_def and item_def.texture then
                love.graphics.draw(item_def.texture, x, y)
            end
            -- Count text
            if slot.count > 1 then
                love.graphics.setFont(UI.get_font(14))
                love.graphics.setColor(1, 1, 1)
                love.graphics.print(slot.count, x + slot_size - 20, y + slot_size - 20)
            end
        end
    end

    -- Close button
    if UI.button(w / 2 - 100, h - 100, 200, 50, "Close", self.hovered_close) then
        ZLC.state.pop()
    end
end

function InventoryScreen:mousepressed(x, y, button)
    if button ~= 1 then return end
    -- Handle slot clicks, etc.
    -- For now, just check close button
    local w, h = love.graphics.getDimensions()
    if x >= w / 2 - 100 and x <= w / 2 + 100 and y >= h - 100 and y <= h - 50 then
        ZLC.state.pop()
        return true
    end
    return false
end

function InventoryScreen:keypressed(key)
    if key == "escape" or key == "e" then
        ZLC.state.pop()
        return true
    end
    return false
end

return InventoryScreen
