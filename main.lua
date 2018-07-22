local match

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    match = require("match")()
end

function love.update(dt)
    match.update(dt)
end

function love.draw()
    match.draw()
end

function love.keypressed(key, scancode, isrepeat)
    match.keypressed(key)
end

function love.keyreleased(key, scancode)
    match.keyreleased(key)
end