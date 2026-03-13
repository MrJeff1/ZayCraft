-- core/engine.lua
-- Main game loop manager. Wraps update/draw and delegates to state manager.

local Engine = {}
Engine.__index = Engine

-- Use core prefix for requires
local StateManager = require("core.state_manager")
local Logger = require("core.logger")

function Engine.new()
    local self = setmetatable({}, Engine)
    self.dt_accumulator = 0
    self.fixed_timestep = 1/60
    self.max_frame_time = 0.25
    return self
end

function Engine:update(dt)
    if dt > self.max_frame_time then
        Logger.warn(("Large dt detected: %.2f, capping to %.2f"):format(dt, self.max_frame_time))
        dt = self.max_frame_time
    end

    self.dt_accumulator = self.dt_accumulator + dt

    local max_steps = 5
    local steps = 0
    while self.dt_accumulator >= self.fixed_timestep and steps < max_steps do
        StateManager.update(self.fixed_timestep)
        self.dt_accumulator = self.dt_accumulator - self.fixed_timestep
        steps = steps + 1
    end

    if self.dt_accumulator > self.fixed_timestep then
        Logger.warn("Fixed update couldn't keep up, discarding " .. self.dt_accumulator)
        self.dt_accumulator = 0
    end
end

function Engine:draw()
    StateManager.draw()
end

return Engine
