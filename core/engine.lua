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
    self.warning_threshold = 0.1  -- Only warn if dt is really large
    return self
end

function Engine:update(dt)
    -- Cap dt to prevent huge jumps after a pause or lag
    if dt > self.max_frame_time then
        if dt > self.warning_threshold then
            Logger.warn(("Large dt detected: %.2f, capping to %.2f"):format(dt, self.max_frame_time))
        end
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

    -- Only warn if we're consistently falling behind
    if self.dt_accumulator > self.fixed_timestep * 2 then
        Logger.warn("Fixed update struggling, discarding " .. self.dt_accumulator)
        self.dt_accumulator = 0
    end
end

function Engine:draw()
    StateManager.draw()
end

return Engine