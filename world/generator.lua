-- world/generator.lua
-- Advanced world generator with trees and biomes

local Generator = {}
Generator.__index = Generator

function Generator.new(seed)
    local self = setmetatable({}, Generator)
    self.seed = seed
    return self
end

-- Improved noise function
function Generator:noise(x, y, scale, octaves)
    octaves = octaves or 1
    local value = 0
    local amplitude = 1
    local frequency = scale
    local max_value = 0

    for i = 1, octaves do
        -- Simple but effective pseudo-random noise
        local n = math.sin(x * frequency * 0.1) * math.cos(y * frequency * 0.1) * 1000
        n = n - math.floor(n)
        value = value + n * amplitude

        max_value = max_value + amplitude
        amplitude = amplitude * 0.5
        frequency = frequency * 2
    end

    return value / max_value
end

-- Check if a tile is solid (for tree placement)
function Generator:is_solid(tile)
    return tile == "grass" or tile == "forest" or tile == "dirt" or tile == "mountain"
end

function Generator:generate(chunk, cx, cy)
    for ly = 1, 16 do
        for lx = 1, 16 do
            local wx = cx * 16 + lx
            local wy = cy * 16 + ly

            -- Multiple noise layers
            local elevation = self:noise(wx, wy, 0.02, 3)
            local moisture = self:noise(wx + 1000, wy, 0.015, 2)
            local temperature = self:noise(wx - 1000, wy, 0.012, 2)
            local terrain_roughness = self:noise(wx * 2, wy * 2, 0.05, 2)

            -- Combine for more interesting terrain
            elevation = elevation * 0.8 + terrain_roughness * 0.2

            -- Biome determination
            local tile
            local tree_chance = 0

            if elevation < 0.2 then
                tile = "water"
                tree_chance = 0
            elseif elevation < 0.28 then
                tile = "sand"
                tree_chance = 0.05
            elseif elevation < 0.65 then
                if moisture > 0.7 then
                    tile = "forest"
                    tree_chance = 0.3
                elseif temperature > 0.7 then
                    tile = "sand"
                    tree_chance = 0.02
                elseif moisture < 0.3 then
                    tile = "grass"
                    tree_chance = 0.1
                else
                    tile = "grass"
                    tree_chance = 0.15
                end
            elseif elevation < 0.85 then
                if temperature < 0.3 then
                    tile = "stone"
                    tree_chance = 0.01
                else
                    tile = "mountain"
                    tree_chance = 0.05
                end
            else
                tile = "stone"
                tree_chance = 0
            end

            chunk:set_tile(lx, ly, tile)

            -- Randomly place trees on suitable tiles
            if tile == "grass" or tile == "forest" then
                -- Use deterministic random based on position
                local rand = self:noise(wx * 10, wy * 10, 1.0)
                if rand < tree_chance then
                    -- Place a tree (represented by forest tile for now)
                    chunk:set_tile(lx, ly, "forest")
                end
            end
        end
    end
end

return Generator
