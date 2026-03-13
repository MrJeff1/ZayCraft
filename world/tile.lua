-- world/tile.lua
-- Base tile class and registry helper.

local Tile = {}
Tile.__index = Tile

-- Tile properties:
-- id: string unique identifier (e.g., "grass")
-- name: display name
-- solid: boolean (can entities walk through?)
-- transparent: boolean (light passes through?)
-- light_emission: number (0-1, for lighting)
-- texture: texture coordinates or color (simplified for now)
function Tile.new(id, def)
    local self = setmetatable({}, Tile)
    self.id = id
    self.name = def.name or id
    self.solid = def.solid ~= false -- default solid
    self.transparent = def.transparent or false
    self.light_emission = def.light_emission or 0
    -- For now, just store a color for rendering
    self.color = def.color or { 1, 1, 1 }
    return self
end

return Tile
