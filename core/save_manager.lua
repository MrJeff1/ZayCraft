-- core/save_manager.lua
-- Handles saving and loading worlds, player data, and configuration.

local SaveManager = {}
SaveManager.__index = SaveManager

-- Use core prefix for requires
local Logger = require("core.logger")

-- Base save directory (love.filesystem handles OS-appropriate paths)
local SAVE_ROOT = "saves"

--- Initialize the save manager (create directories if needed).
function SaveManager.init()
    local success, err = love.filesystem.createDirectory(SAVE_ROOT)
    if not success then
        Logger.error("Failed to create save root directory: " .. tostring(err))
    else
        Logger.debug("Save root directory ready.")
    end
end

--- Get the path to a world folder.
-- @param world_name (string) Name of the world.
-- @return string path relative to save root.
function SaveManager.get_world_path(world_name)
    return SAVE_ROOT .. "/" .. world_name
end

--- Save world metadata (e.g., seed, time).
-- @param world_name (string)
-- @param data (table) Serializable table.
-- @return boolean success
function SaveManager.save_world_meta(world_name, data)
    local path = SaveManager.get_world_path(world_name) .. "/world.json"
    -- We'll add JSON support later
    Logger.info("Saving world meta to " .. path)
    return true
end

--- Load world metadata.
function SaveManager.load_world_meta(world_name)
    Logger.info("Loading world meta for " .. world_name)
    return {}
end

--- Save player data.
function SaveManager.save_player(world_name, player_data)
    local path = SaveManager.get_world_path(world_name) .. "/player.json"
    Logger.info("Saving player data to " .. path)
    return true
end

--- Load player data.
function SaveManager.load_player(world_name)
    Logger.info("Loading player data for world " .. world_name)
    return {}
end

--- Save a chunk to disk.
-- @param world_name (string)
-- @param cx (number) chunk X coordinate
-- @param cy (number) chunk Y coordinate
-- @param chunk_data (string/table) binary or serialized data
function SaveManager.save_chunk(world_name, cx, cy, chunk_data)
    local path = SaveManager.get_world_path(world_name) .. "/chunks"
    -- Ensure chunks directory exists
    love.filesystem.createDirectory(path)
    local filename = string.format("chunk_%d_%d.bin", cx, cy)
    local full = path .. "/" .. filename
    Logger.debug("Saving chunk " .. full)
    return true
end

--- Load a chunk from disk.
function SaveManager.load_chunk(world_name, cx, cy)
    local path = SaveManager.get_world_path(world_name) .. "/chunks/" .. string.format("chunk_%d_%d.bin", cx, cy)
    Logger.debug("Loading chunk " .. path)
    return nil
end

--- Save tech system state.
function SaveManager.save_tech_state(world_name, tech_data)
    local path = SaveManager.get_world_path(world_name) .. "/tech_state.json"
    Logger.info("Saving tech state to " .. path)
    return true
end

--- Load tech system state.
function SaveManager.load_tech_state(world_name)
    Logger.info("Loading tech state for world " .. world_name)
    return {}
end

return SaveManager
