-- states/credits.lua
local UI = require("lib.ui")

local Credits = {}
Credits.__index = Credits

function Credits.new()
    return setmetatable({}, Credits)
end

function Credits:enter()
    ZLC.logger.info("Entered credits")
    self.scroll_y = love.graphics.getHeight()
    self.speed = 50
    self.hovered_back = false
end

function Credits:exit()
    ZLC.logger.info("Exited credits")
end

function Credits:update(dt)
    self.scroll_y = self.scroll_y - self.speed * dt
    if self.scroll_y < -500 then
        self.scroll_y = love.graphics.getHeight()
    end

    local mx, my = love.mouse.getPosition()
    local w, h = love.graphics.getDimensions()
    self.hovered_back = UI.mouse_in_rect(mx, my, w / 2 - 100, h - 80, 200, 50)
end

function Credits:draw()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.2)
    love.graphics.clear()

    local w, h = love.graphics.getDimensions()
    local y = self.scroll_y

    love.graphics.setFont(UI.get_font(48))
    love.graphics.setColor(1, 1, 1)
    local title = "ZayCraft Legends"
    local tw = love.graphics.getFont():getWidth(title)
    love.graphics.print(title, (w - tw) / 2, y)

    love.graphics.setFont(UI.get_font(32))
    love.graphics.setColor(0.8, 0.8, 1)
    local subtitle = "Made by Zayfire Studios"
    local sw = love.graphics.getFont():getWidth(subtitle)
    love.graphics.print(subtitle, (w - sw) / 2, y + 80)

    love.graphics.setFont(UI.get_font(24))
    love.graphics.setColor(1, 1, 1)
    local credits = {
        "Lead Developer: Sheldi",
        "Co-Developer: Zaiden",
        "Art & Design: Sheldi",
        "Music & Sound: Zaiden",
        "Special Thanks:",
        "The Love2D Community",
        "All our playtesters!",
        "",
        "Thank you for playing!"
    }

    for i, line in ipairs(credits) do
        local lw = love.graphics.getFont():getWidth(line)
        love.graphics.print(line, (w - lw) / 2, y + 140 + (i - 1) * 40)
    end

    UI.button(w / 2 - 100, h - 80, 200, 50, "Back", self.hovered_back)
end

function Credits:mousepressed(x, y, button)
    if button ~= 1 then return end
    local w, h = love.graphics.getDimensions()
    if x >= w / 2 - 100 and x <= w / 2 + 100 and y >= h - 80 and y <= h - 30 then
        ZLC.state.pop()
        return true
    end
    return false
end

function Credits:keypressed(key)
    if key == "escape" then
        ZLC.state.pop()
        return true
    end
    return false
end

return Credits
