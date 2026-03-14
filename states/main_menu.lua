-- states/main_menu.lua
-- Main menu using UI engine

local UI = require("lib.ui")

local MainMenu = {}
MainMenu.__index = MainMenu

function MainMenu.new()
    return setmetatable({}, MainMenu)
end

function MainMenu:enter()
    ZLC.logger.info("Entered main menu")
    self.hovered = {}
end

function MainMenu:exit()
    ZLC.logger.info("Exited main menu")
end

function MainMenu:update(dt)
    local mx, my = love.mouse.getPosition()
    local w, h = love.graphics.getDimensions()
    local center_x = w / 2
    local start_y = h * 0.4
    local btn_w, btn_h = 250, 60

    self.hovered = {
        play     = UI.mouse_in_rect(mx, my, center_x - btn_w / 2, start_y, btn_w, btn_h),
        settings = UI.mouse_in_rect(mx, my, center_x - btn_w / 2, start_y + btn_h + 15, btn_w, btn_h),
        credits  = UI.mouse_in_rect(mx, my, center_x - btn_w / 2, start_y + (btn_h + 15) * 2, btn_w, btn_h),
        quit     = UI.mouse_in_rect(mx, my, center_x - btn_w / 2, start_y + (btn_h + 15) * 3, btn_w, btn_h),
    }
end

function MainMenu:draw()
    love.graphics.setBackgroundColor(UI.colors.background)
    love.graphics.clear()
    UI.starfield()

    UI.text_centered("ZayCraft Legends", love.graphics.getHeight() * 0.15, 72)
    UI.text_centered("A 2D Top-Down Adventure", love.graphics.getHeight() * 0.25, 24, UI.colors.text_dim)

    local w, h = love.graphics.getDimensions()
    local center_x = w / 2
    local start_y = h * 0.4
    local btn_w, btn_h = 250, 60

    UI.button(center_x - btn_w / 2, start_y, btn_w, btn_h, "Play", self.hovered.play, "play")
    UI.button(center_x - btn_w / 2, start_y + btn_h + 15, btn_w, btn_h, "Settings", self.hovered.settings)
    UI.button(center_x - btn_w / 2, start_y + (btn_h + 15) * 2, btn_w, btn_h, "Credits", self.hovered.credits)
    UI.button(center_x - btn_w / 2, start_y + (btn_h + 15) * 3, btn_w, btn_h, "Quit", self.hovered.quit, "danger")

    UI.version("Release v0.3.0")
end

function MainMenu:mousepressed(x, y, button)
    if button ~= 1 then return false end

    local w, h = love.graphics.getDimensions()
    local center_x = w / 2
    local start_y = h * 0.4
    local btn_w, btn_h = 250, 60

    if self.hovered.play then
        local WorldSelect = require("states.world_select")
        ZLC.state.push(WorldSelect.new())
        return true
    elseif self.hovered.settings then
        local Settings = require("states.settings")
        ZLC.state.push(Settings.new())
        return true
    elseif self.hovered.credits then
        local Credits = require("states.credits")
        ZLC.state.push(Credits.new())
        return true
    elseif self.hovered.quit then
        love.event.quit()
        return true
    end
    return false
end

function MainMenu:keypressed(key)
    if key == "escape" then love.event.quit() end
    return false
end

return MainMenu
