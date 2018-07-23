local Board = require "board"
local UI = require "ui"
local layout_generator = require "layout_generator"

function tile(color, type)
    assert(color ~= nil, "Must assign a color to the tile")
    assert(type ~= nil, "Must assign a type to the tile")
    return {
        color = color,
        type = type
    }
end

local board_width, board_height = 8, 16

return function()
    local board = Board(board_width, board_height)
    local ui = UI()

    local turn_delay = 0.25
    local turn_timer = 0
    local faster_turn = false

    local controlled_pill = nil

    -- POPULATE BOARD WITH VIRUSES
    local virus_types = layout_generator(board, 5)

    function add_pill()
        controlled_pill = {
            rotation = "horizontal",
            {x = 1, y = 1, tile = tile(virus_types[love.math.random(#virus_types)], "left_horizontal_bar")},
            {x = 2, y = 1, tile = tile(virus_types[love.math.random(#virus_types)], "right_horizontal_bar")}
        }
        for _, portion in ipairs(controlled_pill) do
            board[portion.x][portion.y] = portion.tile
        end
    end

    function is_controlled(x, y)
        for _, portion in ipairs(controlled_pill) do
            if board[x][y] == portion.tile then
                return true
            end
        end
        return false
    end

    -- RETURN FALSE IF CANNOT ROTATE
    function rotate_controlled()
        local origin = controlled_pill[1]
        local orbiter = controlled_pill[2]
        local bound_x, bound_y = board.get_bounds()

        local next_x, next_y
        local next_origin_type, next_orbiter_type

        -- SET THE NEXT TILE TYPES AND POSITIONS
        if controlled_pill.rotation == "horizontal" then
            next_x, next_y = origin.x, origin.y - 1
            next_origin_type, next_orbiter_type = "bottom_vertical_bar", "top_vertical_bar"
            controlled_pill.rotation = "vertical"
        elseif controlled_pill.rotation == "vertical" then
            next_x, next_y = origin.x + 1, origin.y
            next_origin_type, next_orbiter_type = "left_horizontal_bar", "right_horizontal_bar"
            controlled_pill.rotation = "horizontal"
        end

        if board.is_within_bounds(next_x, next_y) and board[next_x][next_y] == nil then
            origin.tile.type, orbiter.tile.type = next_origin_type, next_orbiter_type
            board[orbiter.x][orbiter.y] = nil
            orbiter.x, orbiter.y = next_x, next_y
            board[orbiter.x][orbiter.y] = orbiter.tile

            -- SWITCH COLORS WHEN CHANGING FROM VERTICAL TO HORIZONTAL
            if controlled_pill.rotation == "horizontal" then
                local old_origin_color = origin.tile.color
                origin.tile.color = orbiter.tile.color
                orbiter.tile.color = old_origin_color
            end
            return true
        else
            return false
        end
    end

    function move_controlled(dx, dy)
        local bound_x, bound_y = board.get_bounds()

        -- CHECK IF PILL CAN BE MOVED DOWN
        for _, portion in ipairs(controlled_pill) do
            local next_x, next_y = portion.x + dx, portion.y + dy
            -- CHECK IF NEXT POSITION IS WITHIN BOUNDS OF BOARD
            if board.is_within_bounds(next_x, next_y) then
                -- MAKE SURE THAT THE NEXT POSITION IS EITHER CONTROLLED OR EMPTY
                if not (is_controlled(next_x, next_y) or board[next_x][next_y] == nil) then
                    return false
                end
            else
                return false
            end
        end

        -- WIPE FROM BOARD
        for _, portion in ipairs(controlled_pill) do
            board[portion.x][portion.y] = nil
        end

        -- REINSERT TO BOARD
        for _, portion in ipairs(controlled_pill) do
            portion.x, portion.y = portion.x + dx, portion.y + dy
            board[portion.x][portion.y] = portion.tile
        end

        return true
    end

    function pause()
        error("NYI")
    end

    function unpause()
        error("NYI")
    end

    return {
        update = function(dt)
            -- IF NO PILL IS BEING CONTROLLED, CREATE A NEW ONE
            if controlled_pill == nil then
                add_pill()
            else
                if faster_turn then
                    turn_timer = turn_timer + dt * 2
                else
                    turn_timer = turn_timer + dt
                end
                if turn_timer > turn_delay then
                    turn_timer = 0
                    -- APPLY GRAVITY TO PILL, IF PILL CAN'T MOVE DOWN THEN SET IT
                    if not move_controlled(0, 1) then
                        -- TODO: CHECK IF ANY COMBOS HAVE BEEN TRIGGERED
                        controlled_pill = nil
                    end
                end
            end
        end,
        draw = function()
            love.graphics.push()
            love.graphics.scale(2, 2)

            board.draw()
            love.graphics.push()

            local tile_width, tile_height = board.get_tile_dimensions()
            local board_width, board_height = board.get_dimensions()
            love.graphics.translate(tile_width + board_width, 0)

            ui.draw()
            love.graphics.pop()

            love.graphics.pop()
        end,
        keypressed = function(key)
            if controlled_pill then
                if key == "w" then
                    -- ROTATE
                    rotate_controlled()
                elseif key == "s" then
                    -- TURN FAST DROP ON
                    faster_turn = true
                elseif key == "a" then
                    -- MOVE LEFT
                    move_controlled(-1, 0)
                elseif key == "d" then
                    -- MOVE RIGHT
                    move_controlled(1, 0)
                end
            end

            if key == "space" then
                -- PAUSE
                if paused then
                    unpause()
                else
                    pause()
                end
            end
        end,
        keyreleased = function(key)
            if key == "s" then
                -- TURN FAST DROP OFF
                faster_turn = false
            end
        end
    }
end
