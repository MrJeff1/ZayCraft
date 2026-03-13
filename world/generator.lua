-- world/generator.lua
-- Procedural world generator (flat for now).

local Generator = {}
Generator.__index = Generator

function Generator.new(seed)
    local self = setmetatable({}, Generator)
    self.seed = seed
    return self
end

function Generator:generate(chunk, cx, cy)
    -- Simple flat world: grass at y=0, dirt below, stone deeper
    for ly = 1, 16 do
        for lx = 1, 16 do
            local wx = cx * 16 + lx - 1
            local wy = cy * 16 + ly - 1

            -- Determine tile based on world y
            if wy == 0 then
                chunk:set_tile(lx, ly, "grass")
            elseif wy < 0 and wy > -5 then
                chunk:set_tile(lx, ly, "dirt")
            elseif wy <= -5 then
                chunk:set_tile(lx, ly, "stone")
            else
                chunk:set_tile(lx, ly, "air")
            end
        end
    end
end

return Generator
