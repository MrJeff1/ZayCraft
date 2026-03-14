-- renderer/tilemap_renderer.lua
-- Renders chunks with textures

local TilemapRenderer = {}
TilemapRenderer.__index = TilemapRenderer

function TilemapRenderer.new()
    local self = setmetatable({}, TilemapRenderer)
    return self
end

function TilemapRenderer:draw_chunk(chunk, tile_registry, camera)
    local cx, cy = chunk.cx, chunk.cy

    -- Calculate chunk bounds in pixels
    local chunk_x = cx * 16 * 32
    local chunk_y = cy * 16 * 32
    local chunk_size = 16 * 32

    -- Frustum culling
    local cam_left = camera.x
    local cam_top = camera.y
    local cam_right = camera.x + love.graphics.getWidth() / camera.scale
    local cam_bottom = camera.y + love.graphics.getHeight() / camera.scale

    if chunk_x + chunk_size < cam_left or
        chunk_x > cam_right or
        chunk_y + chunk_size < cam_top or
        chunk_y > cam_bottom then
        return -- Off screen
    end

    -- Draw chunk
    for ly = 1, 16 do
        for lx = 1, 16 do
            local tile_id = chunk:get_tile(lx, ly)
            if tile_id and tile_id ~= "air" then
                local tile_def = tile_registry[tile_id]
                if tile_def then
                    if tile_def.texture then
                        -- Draw with texture
                        love.graphics.setColor(1, 1, 1, tile_def.color and tile_def.color[4] or 1)
                        love.graphics.draw(tile_def.texture,
                            chunk_x + (lx - 1) * 32,
                            chunk_y + (ly - 1) * 32)
                    else
                        -- Fallback to colored rectangle
                        love.graphics.setColor(tile_def.color or { 1, 1, 1 })
                        love.graphics.rectangle("fill",
                            chunk_x + (lx - 1) * 32,
                            chunk_y + (ly - 1) * 32,
                            32, 32)
                    end
                end
            end
        end
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

return TilemapRenderer
