-- core/state_manager.lua
-- Manages a stack of game states (menu, game, pause, etc.)

local StateManager = {}
StateManager.__index = StateManager

local stack = {}  -- Stack of state tables

--- Push a new state onto the stack.
-- Calls :enter() on the new state if it exists.
-- @param state (table) State table with optional enter/exit/update/draw etc.
function StateManager.push(state)
    if not state then
        error("Cannot push nil state")
    end
    table.insert(stack, state)
    if state.enter then
        state.enter()
    end
end

--- Pop the top state off the stack.
-- Calls :exit() on the state if it exists.
-- @return the popped state, or nil if stack was empty.
function StateManager.pop()
    local state = table.remove(stack)
    if state and state.exit then
        state.exit()
    end
    return state
end

--- Switch to a new state (replace the top).
-- Pops the current top and pushes the new one.
-- @param state (table) New state.
function StateManager.switch(state)
    StateManager.pop()
    StateManager.push(state)
end

--- Get the current top state.
-- @return state or nil.
function StateManager.current()
    return stack[#stack]
end

--- Update the current state.
-- @param dt (number) Delta time.
function StateManager.update(dt)
    local current = StateManager.current()
    if current and current.update then
        current.update(dt)
    end
end

--- Draw the current state.
function StateManager.draw()
    local current = StateManager.current()
    if current and current.draw then
        current.draw()
    end
end

--- Forward keypressed to current state (if implemented).
function StateManager.keypressed(key, scancode, isrepeat)
    local current = StateManager.current()
    if current and current.keypressed then
        return current.keypressed(key, scancode, isrepeat)
    end
    return false
end

--- Forward keyreleased to current state.
function StateManager.keyreleased(key, scancode)
    local current = StateManager.current()
    if current and current.keyreleased then
        return current.keyreleased(key, scancode)
    end
    return false
end

--- Forward mousemoved to current state.
function StateManager.mousemoved(x, y, dx, dy, istouch)
    local current = StateManager.current()
    if current and current.mousemoved then
        return current.mousemoved(x, y, dx, dy, istouch)
    end
    return false
end

--- Forward mousepressed to current state.
function StateManager.mousepressed(x, y, button, istouch, presses)
    local current = StateManager.current()
    if current and current.mousepressed then
        return current.mousepressed(x, y, button, istouch, presses)
    end
    return false
end

--- Forward mousereleased to current state.
function StateManager.mousereleased(x, y, button, istouch, presses)
    local current = StateManager.current()
    if current and current.mousereleased then
        return current.mousereleased(x, y, button, istouch, presses)
    end
    return false
end

--- Forward wheelmoved to current state.
function StateManager.wheelmoved(x, y)
    local current = StateManager.current()
    if current and current.wheelmoved then
        return current.wheelmoved(x, y)
    end
    return false
end

return StateManager
