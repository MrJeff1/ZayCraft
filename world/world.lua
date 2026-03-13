-- world/world.lua
-- World container, loads/unloads chunks.

local Chunk = require("world.chunk")
local Generator = require("world.generator")
local Logger = require("core.logger")

local World = {}
World.__index = World

function World.new(seed)
    local self = setmetatable({}, World)
    self.seed = seed or os.time()
    self.chunks = {}  -- key = "cx,cy" -> chunk
    self.generator = Generator.new(self.seed)
    self.load_distance = 6  -- Reduced from 8 to 6 (13x13 chunks = 169 chunks instead of 289)
    self.last_center_cx = nil
    self.last_center_cy = nil
    return self
end

-- Get chunk at chunk coordinates, generate if not exists
function World:get_chunk(cx, cy)
    local key = cx .. "," .. cy
    if not self.chunks[key] then
        self.chunks[key] = Chunk.new(cx, cy)
        self.generator:generate(self.chunks[key], cx, cy)
    end
    return self.chunks[key]
end

-- Get tile ID at world coordinates (tile coordinates, not chunk)
function World:get_tile(wx, wy)
    local cx = math.floor(wx / 16)
    local cy = math.floor(wy / 16)
    local lx = (wx % 16) + 1
    local ly = (wy % 16) + 1
    local chunk = self:get_chunk(cx, cy)
    return chunk:get_tile(lx, ly) or "air"
end

-- Set tile at world coordinates
function World:set_tile(wx, wy, tile_id)
    local cx = math.floor(wx / 16)
    local cy = math.floor(wy / 16)
    local lx = (wx % 16) + 1
    local ly = (wy % 16) + 1
    local chunk = self:get_chunk(cx, cy)
    chunk:set_tile(lx, ly, tile_id)
end

-- Update chunks around a position (only if center changed)
function World:update_center(cx, cy)
    -- Only update if we've moved to a new chunk center
    if self.last_center_cx == cx and self.last_center_cy == cy then
        return
    end
    
    self.last_center_cx = cx
    self.last_center_cy = cy
    
    -- Generate chunks within load_distance
    for dx = -self.load_distance, self.load_distance do
        for dy = -self.load_distance, self.load_distance do
            self:get_chunk(cx + dx, cy + dy)
        end
    end
    
    -- Optional: Unload distant chunks to save memory
    self:unload_distant_chunks(cx, cy)
end

-- Unload chunks that are too far away
function World:unload_distant_chunks(cx, cy)
    local unload_distance = self.load_distance + 2
    for key, chunk in pairs(self.chunks) do
        local distance = math.max(math.abs(chunk.cx - cx), math.abs(chunk.cy - cy))
        if distance > unload_distance then
            self.chunks[key] = nil
        end
    end
end

return World