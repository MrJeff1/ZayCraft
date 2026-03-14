-- world/world.lua
-- World container with dynamic render distance

local Chunk = require("world.chunk")
local Generator = require("world.generator")
local Logger = require("core.logger")

local World = {}
World.__index = World

function World.new(seed)
    local self = setmetatable({}, World)
    self.seed = seed or os.time()
    self.chunks = {}
    self.generator = Generator.new(self.seed)
    self.last_center_cx = nil
    self.last_center_cy = nil
    return self
end

function World:get_chunk(cx, cy)
    local key = cx .. "," .. cy
    if not self.chunks[key] then
        self.chunks[key] = Chunk.new(cx, cy)
        self.generator:generate(self.chunks[key], cx, cy)
    end
    return self.chunks[key]
end

function World:get_tile(wx, wy)
    local cx = math.floor(wx / 16)
    local cy = math.floor(wy / 16)
    local lx = (wx % 16) + 1
    local ly = (wy % 16) + 1
    local chunk = self:get_chunk(cx, cy)
    return chunk:get_tile(lx, ly) or "air"
end

function World:set_tile(wx, wy, tile_id)
    local cx = math.floor(wx / 16)
    local cy = math.floor(wy / 16)
    local lx = (wx % 16) + 1
    local ly = (wy % 16) + 1
    local chunk = self:get_chunk(cx, cy)
    chunk:set_tile(lx, ly, tile_id)
end

function World:update_center(cx, cy)
    -- Get render distance from settings
    local render_dist = ZLC.settings and ZLC.settings:get("render_distance", 8) or 8

    -- Only update if we've moved to a new chunk center
    if self.last_center_cx == cx and self.last_center_cy == cy then
        return
    end

    self.last_center_cx = cx
    self.last_center_cy = cy

    -- Generate chunks within render distance
    for dx = -render_dist, render_dist do
        for dy = -render_dist, render_dist do
            self:get_chunk(cx + dx, cy + dy)
        end
    end

    -- Unload distant chunks
    self:unload_distant_chunks(cx, cy, render_dist + 2)
end

function World:unload_distant_chunks(cx, cy, unload_distance)
    for key, chunk in pairs(self.chunks) do
        local distance = math.max(math.abs(chunk.cx - cx), math.abs(chunk.cy - cy))
        if distance > unload_distance then
            self.chunks[key] = nil
        end
    end
end

return World
