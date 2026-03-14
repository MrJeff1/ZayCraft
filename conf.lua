-- conf.lua
-- Love2D configuration file.

function love.conf(t)
    t.title = "ZayCraft Legends"
    t.version = "11.4"
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = true
    t.window.minwidth = 800
    t.window.minheight = 600
    t.window.icon = "assets/icon.png"
    -- t.window.vsync = 1
    t.window.msaa = 0
    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true
    t.modules.thread = true
end
