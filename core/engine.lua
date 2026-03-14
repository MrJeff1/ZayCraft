-- core/engine.lua
-- Optimized main game loop manager

local Engine = {}
Engine.__index = Engine

local StateManager = require("core.state_manager")
local Logger = require("core.logger")

function Engine.new()
    local self = setmetatable({}, Engine)
    self.dt_accumulator = 0
    self.fixed_timestep = 1 / 60
    self.max_frame_time = 0.25
    self.warning_threshold = 0.2
    self.last_warning_time = 0
    return self
end

function Engine:update(dt)
    if dt > self.max_frame_time then
        local now = love.timer.getTime()
        if dt > self.warning_threshold and now - self.last_warning_time > 2.0 then
            Logger.warn(("Large dt detected: %.2f, capping"):format(dt))
            self.last_warning_time = now
        end
        dt = self.max_frame_time
    end

    self.dt_accumulator = self.dt_accumulator + dt

    local max_steps = 3
    local steps = 0
    while self.dt_accumulator >= self.fixed_timestep and steps < max_steps do
        StateManager.update(self.fixed_timestep)
        self.dt_accumulator = self.dt_accumulator - self.fixed_timestep
        steps = steps + 1
    end

    if self.dt_accumulator > self.fixed_timestep * 3 then
        local now = love.timer.getTime()
        if now - self.last_warning_time > 2.0 then
            Logger.warn("Game struggling, reducing load")
            self.last_warning_time = now
        end
        self.dt_accumulator = 0
    end
end

function Engine:draw()
    StateManager.draw()
end

return Engine
