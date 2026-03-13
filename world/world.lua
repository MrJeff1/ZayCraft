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
    self.load_distance = 8  -- chunks in each direction
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
    if wx < 0 or wy < 0 then return "air" end  -- handle negatives later
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

-- Update chunks around a position (simple loading)
function World:update_center(cx, cy)
    -- For now, just ensure chunks within load_distance are generated
    for dx = -self.load_distance, self.load_distance do
        for dy = -self.load_distance, self.load_distance do
            self:get_chunk(cx + dx, cy + dy)
        end
    end
end

return World
