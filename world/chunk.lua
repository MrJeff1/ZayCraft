-- world/chunk.lua
-- Represents a 16x16 chunk of tiles.

local CHUNK_SIZE = 16

local Chunk = {}
Chunk.__index = Chunk

function Chunk.new(cx, cy)
    local self = setmetatable({}, Chunk)
    self.cx = cx
    self.cy = cy
    -- Tile data: 2D array of tile IDs (strings) or nil for air
    self.tiles = {}
    for y = 1, CHUNK_SIZE do
        self.tiles[y] = {}
        for x = 1, CHUNK_SIZE do
            self.tiles[y][x] = "air" -- default air
        end
    end
    self.dirty = true       -- needs mesh rebuild
    self.sprite_batch = nil -- will be created by renderer
    return self
end

function Chunk:set_tile(lx, ly, tile_id)
    if lx >= 1 and lx <= CHUNK_SIZE and ly >= 1 and ly <= CHUNK_SIZE then
        self.tiles[ly][lx] = tile_id or "air"
        self.dirty = true
    end
end

function Chunk:get_tile(lx, ly)
    if lx >= 1 and lx <= CHUNK_SIZE and ly >= 1 and ly <= CHUNK_SIZE then
        return self.tiles[ly][lx]
    end
    return nil
end

return Chunk
