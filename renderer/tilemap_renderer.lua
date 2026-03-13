-- renderer/tilemap_renderer.lua
-- Renders chunks with SpriteBatch for performance.

local TilemapRenderer = {}
TilemapRenderer.__index = TilemapRenderer

-- We'll need a texture atlas. For now, we'll just draw colored rectangles.
-- But to prepare for sprites, we'll use a dummy texture.
local dummy_texture = nil

function TilemapRenderer.new()
    local self = setmetatable({}, TilemapRenderer)
    -- Create a 1x1 white pixel texture for colored rectangles
    dummy_texture = love.graphics.newImage(love.image.newImageData(1, 1))
    dummy_texture:setFilter("nearest", "nearest")
    return self
end

function TilemapRenderer:render_chunk(chunk, tile_registry)
    if not chunk then return end

    -- If chunk is dirty, rebuild its sprite batch
    if chunk.dirty or not chunk.sprite_batch then
        self:rebuild_chunk(chunk, tile_registry)
    end

    -- Draw the sprite batch at chunk position
    if chunk.sprite_batch then
        love.graphics.draw(chunk.sprite_batch, chunk.cx * 16, chunk.cy * 16)
    end
end

function TilemapRenderer:rebuild_chunk(chunk, tile_registry)
    if not chunk then return end

    -- Create a new sprite batch
    chunk.sprite_batch = love.graphics.newSpriteBatch(dummy_texture, 16*16)
    chunk.sprite_batch:clear()

    -- For each tile in chunk, add a colored quad
    for ly = 1, 16 do
        for lx = 1, 16 do
            local tile_id = chunk:get_tile(lx, ly) or "air"
            local tile_def = tile_registry[tile_id]
            if tile_def and tile_id ~= "air" then
                -- Add a colored rectangle
                local color = tile_def.color
                -- We need to set color per quad. With a dummy texture, we can use love.graphics.setColor before drawing the batch,
                -- but that would affect all tiles. Instead we'll use a hack: draw individual rectangles for now.
                -- For proper batching, we need a texture atlas and quads with colors via shader or separate batches per color.
                -- Since this is Phase 2, we'll simplify: draw rectangles individually.
                -- But to keep the code structure, we'll just draw them in the render loop.
                -- We'll change approach: not use sprite batch yet, just draw rects.
            end
        end
    end

    -- For simplicity, we'll mark chunk as not dirty but we won't use the batch.
    -- We'll handle drawing in the main render loop.
    chunk.dirty = false
    chunk.sprite_batch = nil  -- disable batching for now
end

-- Alternative simple drawing: just draw colored rectangles directly.
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
                        (cx * 16 + lx - 1) * 32,  -- tile size 32 pixels
                        (cy * 16 + ly - 1) * 32,
                        32, 32)
                end
            end
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return TilemapRenderer
