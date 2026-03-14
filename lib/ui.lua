-- lib/ui.lua
-- Custom UI engine for ZayCraft Legends

local UI = {}

-- Colors
UI.colors = {
    background = { 0.15, 0.15, 0.25 },
    button = { 0.3, 0.3, 0.5 },
    button_hover = { 0.4, 0.4, 0.6 },
    button_active = { 0.2, 0.2, 0.4 },
    button_play = { 0.3, 0.5, 0.7 },
    button_play_hover = { 0.4, 0.6, 0.8 },
    button_danger = { 0.4, 0.2, 0.2 },
    button_danger_hover = { 0.5, 0.3, 0.3 },
    checkbox_bg = { 0.3, 0.3, 0.4 },
    checkbox_hover = { 0.4, 0.4, 0.5 },
    checkbox_check = { 0, 1, 0 },
    slider_bg = { 0.3, 0.3, 0.4 },
    slider_fill = { 0.2, 0.6, 1.0 },
    slider_fill_purple = { 0.8, 0.4, 1.0 },
    text = { 1, 1, 1 },
    text_dim = { 0.7, 0.7, 0.7 },
    text_dark = { 0.5, 0.5, 0.5 },
    panel = { 0.2, 0.2, 0.3 },
    panel_border = { 0.3, 0.3, 0.4 },
    dialog_bg = { 0, 0, 0, 0.95 },
    highlight = { 0.3, 0.4, 0.6, 0.5 },
    selection = { 0.4, 0.5, 0.7, 0.3 },
}

-- Font cache
local fonts = {}

function UI.get_font(size)
    if not fonts[size] then
        fonts[size] = love.graphics.newFont(size)
    end
    return fonts[size]
end

function UI.button(x, y, w, h, text, hovered, color_scheme)
    if hovered then
        if color_scheme == "play" then
            love.graphics.setColor(UI.colors.button_play_hover)
        elseif color_scheme == "danger" then
            love.graphics.setColor(UI.colors.button_danger_hover)
        else
            love.graphics.setColor(UI.colors.button_hover)
        end
    else
        if color_scheme == "play" then
            love.graphics.setColor(UI.colors.button_play)
        elseif color_scheme == "danger" then
            love.graphics.setColor(UI.colors.button_danger)
        else
            love.graphics.setColor(UI.colors.button)
        end
    end
    love.graphics.rectangle("fill", x, y, w, h, 8, 8)

    love.graphics.setColor(UI.colors.text)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 8, 8)

    local font = UI.get_font(20)
    love.graphics.setFont(font)
    local tw = font:getWidth(text)
    love.graphics.print(text, x + (w - tw) / 2, y + (h - font:getHeight()) / 2)
end

function UI.small_button(x, y, w, h, text, hovered, enabled)
    if not enabled then
        love.graphics.setColor(UI.colors.button_active)
    elseif hovered and enabled then
        love.graphics.setColor(UI.colors.button_hover)
    else
        love.graphics.setColor(UI.colors.button)
    end
    love.graphics.rectangle("fill", x, y, w, h, 5, 5)

    love.graphics.setColor(UI.colors.text)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 5, 5)

    local font = UI.get_font(16)
    love.graphics.setFont(font)
    local tw = font:getWidth(text)
    love.graphics.print(text, x + (w - tw) / 2, y + (h - font:getHeight()) / 2)
end

function UI.checkbox(x, y, size, checked, hovered)
    if hovered then
        love.graphics.setColor(UI.colors.checkbox_hover)
    else
        love.graphics.setColor(UI.colors.checkbox_bg)
    end
    love.graphics.rectangle("fill", x, y, size, size)

    love.graphics.setColor(UI.colors.text)
    love.graphics.rectangle("line", x, y, size, size)

    if checked then
        love.graphics.setColor(UI.colors.checkbox_check)
        love.graphics.setLineWidth(3)
        love.graphics.line(x + 5, y + size / 2, x + size / 2, y + size - 5)
        love.graphics.line(x + size / 2, y + size - 5, x + size - 5, y + 5)
        love.graphics.setLineWidth(1)
    end
end

function UI.slider(x, y, w, h, value, min, max, dragging, color_scheme)
    love.graphics.setColor(UI.colors.slider_bg)
    love.graphics.rectangle("fill", x, y, w, h)

    if color_scheme == "purple" then
        love.graphics.setColor(UI.colors.slider_fill_purple)
    else
        love.graphics.setColor(UI.colors.slider_fill)
    end
    local percent = (value - min) / (max - min)
    love.graphics.rectangle("fill", x, y, w * percent, h)

    love.graphics.setColor(UI.colors.text)
    love.graphics.rectangle("line", x, y, w, h)

    local handle_x = x + (w * percent) - 8
    love.graphics.setColor(UI.colors.text)
    love.graphics.rectangle("fill", handle_x, y - 8, 16, h + 16)

    local font = UI.get_font(16)
    love.graphics.setFont(font)
    love.graphics.setColor(UI.colors.text)
    local val_text = tostring(math.floor(value))
    love.graphics.print(val_text, x + w + 10, y)
end

function UI.radio(x, y, size, selected, hovered, text)
    if hovered then
        love.graphics.setColor(UI.colors.button_hover)
    else
        love.graphics.setColor(UI.colors.button)
    end
    love.graphics.circle("fill", x + size / 2, y + size / 2, size / 2)

    love.graphics.setColor(UI.colors.text)
    love.graphics.circle("line", x + size / 2, y + size / 2, size / 2)

    if selected then
        love.graphics.setColor(UI.colors.checkbox_check)
        love.graphics.circle("fill", x + size / 2, y + size / 2, size / 4)
    end

    if text then
        love.graphics.setFont(UI.get_font(20))
        love.graphics.setColor(UI.colors.text)
        love.graphics.print(text, x + size + 10, y)
    end
end

function UI.panel(x, y, w, h, title, subtitle)
    love.graphics.setColor(UI.colors.panel)
    love.graphics.rectangle("fill", x, y, w, h, 10, 10)

    love.graphics.setColor(UI.colors.panel_border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 10, 10)

    if title then
        local font = UI.get_font(24)
        love.graphics.setFont(font)
        love.graphics.setColor(UI.colors.text)
        local tw = font:getWidth(title)
        love.graphics.print(title, x + (w - tw) / 2, y + 10)
    end

    if subtitle then
        local font = UI.get_font(16)
        love.graphics.setFont(font)
        love.graphics.setColor(UI.colors.text_dim)
        local sw = font:getWidth(subtitle)
        love.graphics.print(subtitle, x + (w - sw) / 2, y + 40)
    end
end

function UI.dialog(x, y, w, h, title)
    love.graphics.setColor(UI.colors.dialog_bg)
    love.graphics.rectangle("fill", x, y, w, h, 15, 15)

    love.graphics.setColor(UI.colors.text)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", x, y, w, h, 15, 15)

    if title then
        local font = UI.get_font(24)
        love.graphics.setFont(font)
        love.graphics.setColor(UI.colors.text)
        local tw = font:getWidth(title)
        love.graphics.print(title, x + (w - tw) / 2, y + 20)
    end
end

function UI.text_input(x, y, w, h, text, placeholder, focused, cursor_time)
    if focused then
        love.graphics.setColor(UI.colors.button_hover)
    else
        love.graphics.setColor(UI.colors.button)
    end
    love.graphics.rectangle("fill", x, y, w, h)

    love.graphics.setColor(UI.colors.text)
    love.graphics.rectangle("line", x, y, w, h)

    local font = UI.get_font(20)
    love.graphics.setFont(font)

    if #text > 0 then
        love.graphics.setColor(UI.colors.text)
        love.graphics.print(text, x + 5, y + (h - font:getHeight()) / 2)
    elseif placeholder then
        love.graphics.setColor(UI.colors.text_dim)
        love.graphics.print(placeholder, x + 5, y + (h - font:getHeight()) / 2)
    end

    if focused and cursor_time then
        if cursor_time % 1 > 0.5 then
            local cursor_x = x + 5 + font:getWidth(text)
            love.graphics.setColor(UI.colors.text)
            love.graphics.line(cursor_x, y + 5, cursor_x, y + h - 5)
        end
    end
end

function UI.list_item(x, y, w, h, text, selected, hovered)
    if selected then
        love.graphics.setColor(UI.colors.selection)
        love.graphics.rectangle("fill", x + 5, y + 2, w - 10, h - 4, 5, 5)
    elseif hovered then
        love.graphics.setColor(UI.colors.highlight)
        love.graphics.rectangle("fill", x + 5, y + 2, w - 10, h - 4, 5, 5)
    end

    love.graphics.setColor(UI.colors.text)
    local font = UI.get_font(20)
    love.graphics.setFont(font)
    love.graphics.print(text, x + 20, y + (h - font:getHeight()) / 2)
end

function UI.text_centered(text, y, size, color)
    local font = UI.get_font(size or 36)
    love.graphics.setFont(font)
    love.graphics.setColor(color or UI.colors.text)
    local tw = font:getWidth(text)
    love.graphics.print(text, (love.graphics.getWidth() - tw) / 2, y)
end

function UI.version(version)
    local font = UI.get_font(16)
    love.graphics.setFont(font)
    love.graphics.setColor(UI.colors.text_dim)
    local vw = font:getWidth(version)
    love.graphics.print(version, love.graphics.getWidth() - vw - 20, love.graphics.getHeight() - 30)
end

function UI.starfield()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(1, 1, 1, 0.3)
    for i = 1, 30 do
        local x = (math.sin(os.clock() * 0.2 + i * 10) * 0.4 + 0.5) * w
        local y = (math.cos(os.clock() * 0.15 + i * 5) * 0.3 + 0.5) * h
        love.graphics.circle("fill", x, y, 2 + math.sin(os.clock() + i) * 0.5)
    end
end

function UI.grid()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(1, 1, 1, 0.03)
    for i = 0, w, 50 do
        love.graphics.line(i, 0, i, h)
    end
    for i = 0, h, 50 do
        love.graphics.line(0, i, w, i)
    end
end

function UI.mouse_in_rect(mx, my, x, y, w, h)
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

return UI
