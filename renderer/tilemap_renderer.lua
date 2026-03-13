-- renderer/tilemap_renderer.lua
-- Renders chunks with SpriteBatch for performance.

local TilemapRenderer = {}
TilemapRenderer.__index = TilemapRenderer

function TilemapRenderer.new()
    local self = setmetatable({}, TilemapRenderer)
    return self
end

-- Simple drawing: draw colored rectangles directly.
function TilemapRenderer:draw_chunk_simple(chunk, tile_registry)
    local cx, cy = chunk.cx, chunk.cy
    for ly = 1, 16 do
        for lx = 1, 16 do
            local tile_id = chunk:get_tile(lx, ly)
            if tile_id and tile_id ~= "air" then
                local tile_def = tile_registry[tile_id]
                if tile_def then
                    love.graphics.setColor(tile_def.color)
                    love.graphics.rectangle("fill",
                        (cx * 16 + lx - 1) * 32, -- tile size 32 pixels
                        (cy * 16 + ly - 1) * 32,
                        32, 32)
                end
            end
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return TilemapRenderer
