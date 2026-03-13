-- renderer/tilemap_renderer.lua
-- Renders chunks efficiently.

local TilemapRenderer = {}
TilemapRenderer.__index = TilemapRenderer

function TilemapRenderer.new()
    local self = setmetatable({}, TilemapRenderer)
    self.chunk_cache = {}  -- Cache of rendered chunks
    return self
end

-- Optimized drawing with culling
function TilemapRenderer:draw_chunk_simple(chunk, tile_registry, camera_x, camera_y, screen_width, screen_height)
    local cx, cy = chunk.cx, chunk.cy
    
    -- Calculate chunk bounds in pixels
    local chunk_pixel_x = cx * 16 * 32
    local chunk_pixel_y = cy * 16 * 32
    local chunk_pixel_size = 16 * 32
    
    -- Simple culling: only draw if chunk is visible on screen
    local chunk_right = chunk_pixel_x + chunk_pixel_size
    local chunk_bottom = chunk_pixel_y + chunk_pixel_size
    local screen_right = camera_x + screen_width / 2
    local screen_bottom = camera_y + screen_height / 2
    local screen_left = camera_x - screen_width / 2
    local screen_top = camera_y - screen_height / 2
    
    if chunk_right < screen_left or 
       chunk_pixel_x > screen_right or 
       chunk_bottom < screen_top or 
       chunk_pixel_y > screen_bottom then
        return  -- Chunk is off-screen, skip drawing
    end
    
    -- Draw the chunk
    for ly = 1, 16 do
        for lx = 1, 16 do
            local tile_id = chunk:get_tile(lx, ly)
            if tile_id and tile_id ~= "air" then
                local tile_def = tile_registry[tile_id]
                if tile_def then
                    love.graphics.setColor(tile_def.color)
                    love.graphics.rectangle("fill", 
                        (cx * 16 + lx - 1) * 32,
                        (cy * 16 + ly - 1) * 32,
                        32, 32)
                end
            end
        end
    end
end

return TilemapRenderer