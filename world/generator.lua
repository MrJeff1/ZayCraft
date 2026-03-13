-- world/generator.lua
-- Procedural world generator for top-down view.

local Generator = {}
Generator.__index = Generator

function Generator.new(seed)
    local self = setmetatable({}, Generator)
    self.seed = seed
    -- Simple noise function (replace with proper noise later)
    math.randomseed(seed)
    self.noise = {}
    -- Generate some random noise values
    for i = -100, 100 do
        self.noise[i] = {}
        for j = -100, 100 do
            self.noise[i][j] = math.random()
        end
    end
    return self
end

function Generator:generate(chunk, cx, cy)
    -- Top-down world generation:
    -- - Grass everywhere as base
    -- - Random patches of different biomes
    -- - Water areas
    -- - Trees/structures will be added later

    for ly = 1, 16 do
        for lx = 1, 16 do
            local wx = cx * 16 + lx - 1
            local wy = cy * 16 + ly - 1

            -- Get noise value for this position (simplified)
            local noise_val = 0
            if self.noise[wx] and self.noise[wx][wy] then
                noise_val = self.noise[wx][wy]
            else
                noise_val = math.random() -- fallback
            end

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
