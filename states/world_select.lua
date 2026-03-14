-- states/world_select.lua
-- World selection with custom UI and game modes

local UI = require("lib.ui")
local serpent = require("lib.serpent")

local WorldSelect = {}
WorldSelect.__index = WorldSelect

function WorldSelect.new()
    local self = setmetatable({}, WorldSelect)
    self.worlds = {}
    self.selected_world = nil
    self.new_world_name = ""
    self.creating_world = false
    self.input_focused = false
    self.cursor_time = 0
    self.mode = "survival" -- or "creative"
    self:refresh_worlds()
    return self
end

function WorldSelect:enter()
    ZLC.logger.info("Entered world select")
    self:refresh_worlds()
    love.keyboard.setTextInput(true)
end

function WorldSelect:exit()
    ZLC.logger.info("Exited world select")
    love.keyboard.setTextInput(false)
end

function WorldSelect:refresh_worlds()
    self.worlds = {}
    if love.filesystem.getInfo("worlds") then
        for _, item in ipairs(love.filesystem.getDirectoryItems("worlds")) do
            local path = "worlds/" .. item
            if love.filesystem.getInfo(path).type == "directory" and
                love.filesystem.getInfo(path .. "/world.dat") then
                table.insert(self.worlds, item)
            end
        end
    end
    table.sort(self.worlds)
end

function WorldSelect:update(dt)
    self.cursor_time = self.cursor_time + dt
    local mx, my = love.mouse.getPosition()
    local w, h = love.graphics.getDimensions()
    local center_x = w / 2
    local list_x, list_y = center_x - 200, 150
    local list_w, list_h = 400, 300
    local btn_y = list_y + list_h + 20

    -- Hover states
    self.hovered = {
        play   = self.selected_world and UI.mouse_in_rect(mx, my, center_x - 210, btn_y, 200, 40),
        create = UI.mouse_in_rect(mx, my, center_x + 10, btn_y, 200, 40),
        back   = UI.mouse_in_rect(mx, my, center_x - 100, h - 80, 200, 40)
    }

    self.hovered_world = nil
    for i, world in ipairs(self.worlds) do
        if UI.mouse_in_rect(mx, my, list_x, list_y + (i - 1) * 40, list_w, 40) then
            self.hovered_world = i
            break
        end
    end

    if self.creating_world then
        local dialog_x, dialog_y = center_x - 200, h / 2 - 120                         -- moved up a bit
        self.dialog_hover = {
            create   = UI.mouse_in_rect(mx, my, dialog_x + 50, dialog_y + 170, 120, 35), -- y adjusted
            cancel   = UI.mouse_in_rect(mx, my, dialog_x + 230, dialog_y + 170, 120, 35),
            input    = UI.mouse_in_rect(mx, my, dialog_x + 120, dialog_y + 75, 200, 30),
            survival = UI.mouse_in_rect(mx, my, dialog_x + 120, dialog_y + 115, 20, 20),
            creative = UI.mouse_in_rect(mx, my, dialog_x + 250, dialog_y + 115, 20, 20),
        }
        if not self.dialog_hover.create and not self.dialog_hover.cancel then
            self.input_focused = self.dialog_hover.input
        end
    end
end

function WorldSelect:draw()
    local w, h = love.graphics.getDimensions()
    local center_x = w / 2
    local list_x, list_y = center_x - 200, 150
    local list_w, list_h = 400, 300

    love.graphics.setBackgroundColor(UI.colors.background)
    love.graphics.clear()
    UI.grid()

    UI.text_centered("Select World", 50, 36)

    UI.panel(list_x, list_y, list_w, list_h)

    for i, world in ipairs(self.worlds) do
        UI.list_item(list_x, list_y + (i - 1) * 40, list_w, 40, world,
            world == self.selected_world, self.hovered_world == i)
    end

    if #self.worlds == 0 then
        love.graphics.setFont(UI.get_font(20))
        love.graphics.setColor(UI.colors.text_dim)
        love.graphics.print("No worlds found. Create one!", list_x + 20, list_y + list_h / 2 - 10)
    end

    local btn_y = list_y + list_h + 20
    UI.button(center_x - 210, btn_y, 200, 40, "Play", self.hovered.play, "play")
    UI.button(center_x + 10, btn_y, 200, 40, "Create New", self.hovered.create)
    UI.button(center_x - 100, h - 80, 200, 40, "Back", self.hovered.back)

    if self.creating_world then
        local dialog_x, dialog_y = center_x - 200, h / 2 - 120
        UI.dialog(dialog_x, dialog_y, 400, 250, "Create New World") -- height increased

        love.graphics.setFont(UI.get_font(20))
        love.graphics.setColor(UI.colors.text)
        love.graphics.print("Name:", dialog_x + 50, dialog_y + 80)

        UI.text_input(dialog_x + 120, dialog_y + 75, 200, 30,
            self.new_world_name, "Enter name...",
            self.input_focused, self.cursor_time)

        -- Mode selection
        love.graphics.print("Mode:", dialog_x + 50, dialog_y + 115)
        UI.radio(dialog_x + 120, dialog_y + 115, 20, self.mode == "survival",
            self.dialog_hover and self.dialog_hover.survival, "Survival")
        UI.radio(dialog_x + 250, dialog_y + 115, 20, self.mode == "creative",
            self.dialog_hover and self.dialog_hover.creative, "Creative")

        UI.small_button(dialog_x + 50, dialog_y + 170, 120, 35, "Create",
            self.dialog_hover and self.dialog_hover.create, #self.new_world_name > 0)
        UI.small_button(dialog_x + 230, dialog_y + 170, 120, 35, "Cancel",
            self.dialog_hover and self.dialog_hover.cancel, true)
    end

    UI.version("v0.2.0")
end

function WorldSelect:mousepressed(x, y, button)
    if button ~= 1 then return false end

    local w, h = love.graphics.getDimensions()
    local center_x = w / 2
    local list_x, list_y = center_x - 200, 150
    local list_w, list_h = 400, 300
    local btn_y = list_y + list_h + 20

    if self.creating_world then
        local dialog_x, dialog_y = center_x - 200, h / 2 - 120

        -- Mode radio toggles
        if self.dialog_hover.survival then
            self.mode = "survival"
            return true
        end
        if self.dialog_hover.creative then
            self.mode = "creative"
            return true
        end

        if self.dialog_hover.create and #self.new_world_name > 0 then
            local name = self.new_world_name:gsub("%s+", "_")
            love.filesystem.createDirectory("worlds/" .. name)
            local data = {
                name = name,
                seed = os.time(),
                created = os.date("%Y-%m-%d %H:%M:%S"),
                player_x = 0,
                player_y = 0,
                game_time = 6000,
                mode = self.mode,
                version = "0.2.0"
            }
            love.filesystem.write("worlds/" .. name .. "/world.dat", serpent.dump(data))

            self.creating_world = false
            self.new_world_name = ""
            self:refresh_worlds()
            self.selected_world = name
            return true
        end

        if self.dialog_hover.cancel then
            self.creating_world = false
            self.new_world_name = ""
            return true
        end
        return true
    end

    for i, world in ipairs(self.worlds) do
        if UI.mouse_in_rect(x, y, list_x, list_y + (i - 1) * 40, list_w, 40) then
            self.selected_world = world
            return true
        end
    end

    if self.hovered.play and self.selected_world then
        local Game = require("states.game")
        ZLC.state.push(Game.new(self.selected_world))
        return true
    elseif self.hovered.create then
        self.creating_world = true
        self.input_focused = true
        self.mode = "survival" -- default
        return true
    elseif self.hovered.back then
        ZLC.state.pop()
        return true
    end

    return false
end

function WorldSelect:textinput(t)
    if self.creating_world and self.input_focused and t:match("^[%w%s_]+$") and #self.new_world_name < 30 then
        self.new_world_name = self.new_world_name .. t
    end
end

function WorldSelect:keypressed(key)
    if key == "escape" then
        if self.creating_world then
            self.creating_world = false
            self.new_world_name = ""
        else
            ZLC.state.pop()
        end
        return true
    elseif key == "backspace" and self.creating_world and self.input_focused then
        self.new_world_name = self.new_world_name:sub(1, -2)
        return true
    elseif key == "return" and self.creating_world and #self.new_world_name > 0 then
        local w, h = love.graphics.getDimensions()
        self:mousepressed(w / 2 - 150, h / 2 + 50, 1) -- simulate create click
        return true
    end
    return false
end

return WorldSelect
