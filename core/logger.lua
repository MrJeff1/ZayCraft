-- core/logger.lua
-- Simple logging module with levels and optional file output.

local Logger = {}
Logger.__index = Logger

-- Log levels
Logger.levels = {
    DEBUG = 1,
    INFO  = 2,
    WARN  = 3,
    ERROR = 4
}

Logger.colors = {
	DEBUG = "\x1B[0;37m",
	INFO  = "\x1B[0;34m",
	WARN  = "\x1B[0;33m",
	ERROR = "\x1B[0;31m",
	RESET = "\x1B[0m"
}

-- Current log level (set to DEBUG for development)
Logger.level = Logger.levels.DEBUG
Logger.color = Logger.colors.DEBUG

-- If true, also write to a log file in the save directory.
Logger.file_output = false
Logger.log_file = nil

function Logger.init()
    -- Called from main to set up file logging if desired.
    -- For now, we keep it disabled.
end

local function get_timestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

local function log_message(level_name, color, message)
    local timestamp = get_timestamp()
    local output = string.format("%s[%s] [%s] %s%s", color, timestamp, level_name, message, Logger.colors.RESET)
    print(output) -- Always print to console

    if Logger.file_output and Logger.log_file then
        Logger.log_file:write(output .. "\n")
        Logger.log_file:flush()
    end
end

function Logger.debug(message)
    if Logger.level <= Logger.levels.DEBUG and Logger.colors.DEBUG then
        log_message("DEBUG", Logger.colors.DEBUG, message)
    end
end

function Logger.info(message)
    if Logger.level <= Logger.levels.INFO and Logger.colors.INFO then
        log_message("INFO", Logger.colors.INFO, message)
    end
end

function Logger.warn(message)
    if Logger.level <= Logger.levels.WARN and Logger.colors.WARN then
        log_message("WARN", Logger.colors.WARN, message)
    end
end

function Logger.error(message)
    if Logger.level <= Logger.levels.ERROR and Logger.colors.ERROR then
        log_message("ERROR", Logger.colors.ERROR, message)
    end
end

-- For errors caught with pcall, include traceback.
function Logger.error_trace(err)
    Logger.error(err)
    Logger.debug(debug.traceback())
end

return Logger