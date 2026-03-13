-- core/event_bus.lua
-- Simple pub/sub event system.

local EventBus = {}
EventBus.__index = EventBus

local subscribers = {}

function EventBus.subscribe(event, callback, once)
    if not subscribers[event] then
        subscribers[event] = {}
    end
    table.insert(subscribers[event], { callback = callback, once = once or false })
end

function EventBus.unsubscribe(event, callback)
    if not subscribers[event] then return end
    for i, sub in ipairs(subscribers[event]) do
        if sub.callback == callback then
            table.remove(subscribers[event], i)
            break
        end
    end
end

function EventBus.emit(event, ...)
    if not subscribers[event] then return end
    local to_remove = {}
    for i, sub in ipairs(subscribers[event]) do
        local success, err = pcall(sub.callback, ...)
        if not success then
            -- Use core prefix for logger
            local logger = require("core.logger")
            logger.error_trace(("Error in event '%s' callback: %s"):format(event, err))
        end
        if sub.once then
            table.insert(to_remove, i)
        end
    end
    for i = #to_remove, 1, -1 do
        table.remove(subscribers[event], to_remove[i])
    end
end

function EventBus.clear(event)
    if event then
        subscribers[event] = nil
    else
        subscribers = {}
    end
end

return EventBus
