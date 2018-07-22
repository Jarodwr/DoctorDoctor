local Board = require "board"
local UI = require "ui"

local board = Board(8, 16)
local ui = UI()

function love.load()
end

function love.update(dt)
end

function love.draw()
    board.draw()
    love.graphics.push()
    love.graphics.translate(board.get_dimensions(), 0)
    ui.draw()
    love.graphics.pop()
end
