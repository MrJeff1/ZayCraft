-- states/settings.lua
-- Settings screen with fully dynamic centered UI

local Settings = {}
Settings.__index = Settings

function Settings.new()
    local self = setmetatable({}, Settings)

    -- Get settings from global
    self.settings = ZLC.settings.data

    -- UI state
    self.dragging_volume = false
    self.dragging_distance = false
    self.hovered_back = false
    self.hovered_vsync = false
    self.hovered_fullscreen = false

    return self
end

function Settings:enter()
    ZLC.logger.info("Entered settings")
end

function Settings:exit()
    ZLC.logger.info("Exited settings")
    ZLC.settings:save()
end

function Settings:get_layout()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local center_x = w / 2
    local col_width = 250
    local label_x = center_x - col_width - 20
    local control_x = center_x + 20
    local start_y = h * 0.2 -- Start at 20% down

    return {
        w = w,
        h = h,
        label_x = label_x,
        control_x = control_x,
        col_width = col_width,
        start_y = start_y,
        row_height = 55,
        center_x = center_x
    }
end

function Settings:update(dt)
    local mx, my = love.mouse.getX(), love.mouse.getY()
    local left_down = love.mouse.isDown(1)
    local layout = self:get_layout()

    -- Volume slider
    local vol_y = layout.start_y + layout.row_height * 2
    local vol_slider_x, vol_slider_y = layout.control_x, vol_y
    local vol_slider_w, vol_slider_h = layout.col_width, 30

    if not left_down then
        self.dragging_volume = false
    end

    if self.dragging_volume then
        local rel_x = math.max(0, math.min(vol_slider_w, mx - vol_slider_x))
        self.settings.volume = rel_x / vol_slider_w
        love.audio.setVolume(self.settings.volume * self.settings.master_volume)
    elseif left_down and not self.dragging_volume and not self.dragging_distance then
        local handle_x = vol_slider_x + (self.settings.volume * vol_slider_w) - 8
        if mx >= handle_x and mx <= handle_x + 16 and
            my >= vol_slider_y - 8 and my <= vol_slider_y + vol_slider_h + 8 then
            self.dragging_volume = true
        end
    end

    -- Render distance slider
    local dist_y = layout.start_y + layout.row_height * 3
    local dist_slider_x, dist_slider_y = layout.control_x, dist_y
    local dist_slider_w, dist_slider_h = layout.col_width, 30

    if not left_down then
        self.dragging_distance = false
    end

    if self.dragging_distance then
        local rel_x = math.max(0, math.min(dist_slider_w, mx - dist_slider_x))
        self.settings.render_distance = 4 + (rel_x / dist_slider_w) * 12
    elseif left_down and not self.dragging_distance and not self.dragging_volume then
        local handle_x = dist_slider_x + ((self.settings.render_distance - 4) / 12 * dist_slider_w) - 8
        if mx >= handle_x and mx <= handle_x + 16 and
            my >= dist_slider_y - 8 and my <= dist_slider_y + dist_slider_h + 8 then
            self.dragging_distance = true
        end
    end

    -- Hover states
    self.hovered_vsync = mx >= layout.control_x and mx <= layout.control_x + 30 and
        my >= layout.start_y and my <= layout.start_y + 30
    self.hovered_fullscreen = mx >= layout.control_x and mx <= layout.control_x + 30 and
        my >= layout.start_y + layout.row_height and my <= layout.start_y + layout.row_height + 30
    self.hovered_back = mx >= layout.center_x - 100 and mx <= layout.center_x + 100 and
        my >= layout.h - 100 and my <= layout.h - 50
end

function Settings:draw()
    local layout = self:get_layout()

    -- Background gradient
    love.graphics.setBackgroundColor(0.15, 0.15, 0.25)
    love.graphics.clear()

    -- Draw subtle grid pattern
    love.graphics.setColor(1, 1, 1, 0.03)
    for i = 0, layout.w, 50 do
        love.graphics.line(i, 0, i, layout.h)
    end
    for i = 0, layout.h, 50 do
        love.graphics.line(0, i, layout.w, i)
    end

    -- Title
    local title_font_size = math.min(48, layout.h * 0.06)
    local title_font = love.graphics.newFont(title_font_size)
    love.graphics.setFont(title_font)
    love.graphics.setColor(1, 1, 1)
    local title = "Settings"
    local tw = title_font:getWidth(title)
    love.graphics.print(title, layout.center_x - tw / 2, layout.h * 0.1)

    -- Subtitle with instructions
    local sub_font = love.graphics.newFont(16)
    love.graphics.setFont(sub_font)
    love.graphics.setColor(0.7, 0.7, 0.9)
    local instruct = "Adjust your game preferences"
    local iw = sub_font:getWidth(instruct)
    love.graphics.print(instruct, layout.center_x - iw / 2, layout.h * 0.1 + title_font_size + 10)

    -- Draw settings rows
    love.graphics.setFont(love.graphics.newFont(20))

    -- V-Sync row
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("V-Sync:", layout.label_x, layout.start_y)

    -- Checkbox
    if self.hovered_vsync then
        love.graphics.setColor(0.4, 0.4, 0.5)
    else
        love.graphics.setColor(0.3, 0.3, 0.4)
    end
    love.graphics.rectangle("fill", layout.control_x, layout.start_y, 30, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", layout.control_x, layout.start_y, 30, 30)

    if self.settings.vsync then
        love.graphics.setColor(0, 1, 0)
        love.graphics.line(layout.control_x + 5, layout.start_y + 15,
            layout.control_x + 15, layout.start_y + 25,
            layout.control_x + 25, layout.start_y + 5)
    end

    -- Fullscreen row
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Fullscreen:", layout.label_x, layout.start_y + layout.row_height)

    if self.hovered_fullscreen then
        love.graphics.setColor(0.4, 0.4, 0.5)
    else
        love.graphics.setColor(0.3, 0.3, 0.4)
    end
    love.graphics.rectangle("fill", layout.control_x, layout.start_y + layout.row_height, 30, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", layout.control_x, layout.start_y + layout.row_height, 30, 30)

    if self.settings.fullscreen then
        love.graphics.setColor(0, 1, 0)
        love.graphics.line(layout.control_x + 5, layout.start_y + layout.row_height + 15,
            layout.control_x + 15, layout.start_y + layout.row_height + 25,
            layout.control_x + 25, layout.start_y + layout.row_height + 5)
    end

    -- Volume slider
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Volume:", layout.label_x, layout.start_y + layout.row_height * 2)

    -- Slider background
    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.rectangle("fill", layout.control_x, layout.start_y + layout.row_height * 2, layout.col_width, 30)

    -- Slider fill
    love.graphics.setColor(0.2, 0.6, 1.0)
    love.graphics.rectangle("fill", layout.control_x, layout.start_y + layout.row_height * 2,
        layout.col_width * self.settings.volume, 30)

    -- Slider border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", layout.control_x, layout.start_y + layout.row_height * 2, layout.col_width, 30)

    -- Slider handle
    local handle_x = layout.control_x + (layout.col_width * self.settings.volume) - 8
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", handle_x, layout.start_y + layout.row_height * 2 - 8, 16, 46)

    -- Volume percentage
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(math.floor(self.settings.volume * 100) .. "%",
        layout.control_x + layout.col_width + 40,
        layout.start_y + layout.row_height * 2 + 5)

    -- Render distance slider
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Render Distance:", layout.label_x, layout.start_y + layout.row_height * 3)

    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.rectangle("fill", layout.control_x, layout.start_y + layout.row_height * 3, layout.col_width, 30)

    love.graphics.setColor(0.8, 0.4, 1.0)
    local dist_percent = (self.settings.render_distance - 4) / 12
    love.graphics.rectangle("fill", layout.control_x, layout.start_y + layout.row_height * 3,
        layout.col_width * dist_percent, 30)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", layout.control_x, layout.start_y + layout.row_height * 3, layout.col_width, 30)

    -- Handle
    local handle_x = layout.control_x + (layout.col_width * dist_percent) - 8
    love.graphics.rectangle("fill", handle_x, layout.start_y + layout.row_height * 3 - 8, 16, 46)

    -- Distance value
    love.graphics.print(math.floor(self.settings.render_distance) .. " chunks",
        layout.control_x + layout.col_width + 40,
        layout.start_y + layout.row_height * 3 + 5)

    -- Back button (centered at bottom)
    local back_y = layout.h - 80
    if self.hovered_back then
        love.graphics.setColor(0.4, 0.4, 0.6)
    else
        love.graphics.setColor(0.3, 0.3, 0.5)
    end
    love.graphics.rectangle("fill", layout.center_x - 100, back_y, 200, 50, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", layout.center_x - 100, back_y, 200, 50, 10, 10)

    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Back", layout.center_x - 30, back_y + 12)
end

function Settings:mousepressed(x, y, button)
    if button ~= 1 then return false end

    local layout = self:get_layout()

    -- V-Sync checkbox
    if x >= layout.control_x and x <= layout.control_x + 30 and
        y >= layout.start_y and y <= layout.start_y + 30 then
        self.settings.vsync = not self.settings.vsync
        love.window.setVSync(self.settings.vsync and 1 or 0)
        return true
    end

    -- Fullscreen checkbox
    if x >= layout.control_x and x <= layout.control_x + 30 and
        y >= layout.start_y + layout.row_height and y <= layout.start_y + layout.row_height + 30 then
        self.settings.fullscreen = not self.settings.fullscreen
        love.window.setFullscreen(self.settings.fullscreen)
        return true
    end

    -- Back button
    if x >= layout.center_x - 100 and x <= layout.center_x + 100 and
        y >= layout.h - 80 and y <= layout.h - 30 then
        ZLC.state.pop()
        return true
    end

    return false
end

function Settings:keypressed(key)
    if key == "escape" then
        ZLC.state.pop()
        return true
    end
    return false
end

return Settings
