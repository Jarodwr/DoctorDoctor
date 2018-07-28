love.graphics.setDefaultFilter('nearest', 'nearest')
local main_menu = require "main_menu"

local scene

function change_scene(next_scene, ...)
    scene = require(next_scene)(change_scene, ...)
end

function love.load()
    scene = main_menu(change_scene)
    -- match = require("match")(0, 2, "fast")
end

function love.update(dt)
    scene.update(dt)
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(16, 16)
    scene.draw()
    love.graphics.pop()
end

function love.keypressed(key, scancode, isrepeat)
    scene.keypressed(key)
end

function love.keyreleased(key, scancode)
    scene.keyreleased(key)
end