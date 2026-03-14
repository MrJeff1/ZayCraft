-- core/settings.lua
-- Persistent settings manager

local Settings = {}
Settings.__index = Settings

local DEFAULT_SETTINGS = {
    vsync = true,
    fullscreen = false,
    volume = 0.8,
    render_distance = 8,
    master_volume = 1.0,
    music_volume = 0.7,
    sfx_volume = 1.0,
    window_width = 1280,
    window_height = 720,
    last_version = "0.1.0"
}

local SETTINGS_PATH = "settings.dat"

function Settings.load()
    local self = setmetatable({}, Settings)

    -- Try to load existing settings
    local success, data = pcall(love.filesystem.read, SETTINGS_PATH)
    if success and data then
        -- Try to deserialize (simple key-value format)
        self.data = {}
        for line in data:gmatch("[^\r\n]+") do
            local key, value = line:match("([^=]+)=(.*)")
            if key and value then
                -- Convert string to appropriate type
                if value == "true" then
                    self.data[key] = true
                elseif value == "false" then
                    self.data[key] = false
                elseif value:match("^%d+$") then
                    self.data[key] = tonumber(value)
                elseif value:match("^%d+%.%d+$") then
                    self.data[key] = tonumber(value)
                else
                    self.data[key] = value
                end
            end
        end
    else
        -- Use defaults
        self.data = {}
        for k, v in pairs(DEFAULT_SETTINGS) do
            self.data[k] = v
        end
    end

    -- Apply settings on load
    self:apply()

    return self
end

function Settings:save()
    -- Serialize to simple key=value format
    local lines = {}
    for k, v in pairs(self.data) do
        lines[#lines + 1] = k .. "=" .. tostring(v)
    end
    local content = table.concat(lines, "\n")

    -- Write to file
    love.filesystem.write(SETTINGS_PATH, content)
    ZLC.logger.info("Settings saved to " .. SETTINGS_PATH)
end

function Settings:get(key, default)
    if self.data[key] ~= nil then
        return self.data[key]
    end
    return default
end

function Settings:set(key, value)
    self.data[key] = value
    self:apply() -- Apply immediately
end

function Settings:apply()
    -- Apply graphics settings
    love.window.setVSync(self.data.vsync and 1 or 0)
    love.window.setFullscreen(self.data.fullscreen)

    -- Apply audio settings
    love.audio.setVolume(self.data.master_volume * self.data.master_volume)

    -- Apply window size if changed
    local _, _, flags = love.window.getMode()
    if flags.fullscreen ~= self.data.fullscreen then
        love.window.setMode(self.data.window_width, self.data.window_height, flags)
    end

    ZLC.logger.debug("Settings applied")
end

return Settings
