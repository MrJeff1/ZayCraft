-- world/generator.lua
-- Optimized generator with precomputed noise.

local Generator = {}
Generator.__index = Generator

function Generator.new(seed)
    local self = setmetatable({}, Generator)
    self.seed = seed
    math.randomseed(seed)
    return self
end

-- Simple but fast deterministic noise
function Generator:noise(x, y)
    -- Simple hash function for speed
    local n = x * 374761393 + y * 668265263 + self.seed * 101
    n = (n % 127) ^ 2
    return (n % 100) / 100
end

function Generator:generate(chunk, cx, cy)
    for ly = 1, 16 do
        for lx = 1, 16 do
            local wx = cx * 16 + lx - 1
            local wy = cy * 16 + ly - 1
            
            -- Fast noise lookup
            local noise_val = self:noise(wx, wy)
            
            -- Determine tile based on noise
            if noise_val < 0.1 then
                chunk:set_tile(lx, ly, "water")
            elseif noise_val < 0.2 then
                chunk:set_tile(lx, ly, "sand")
            elseif noise_val < 0.8 then
                chunk:set_tile(lx, ly, "grass")
            else
                chunk:set_tile(lx, ly, "forest")
            end
        end
    end
end

return Generator