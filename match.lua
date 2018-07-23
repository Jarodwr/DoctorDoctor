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

    local falling_mode = false

    local turn_delay = 0.25
    local turn_timer = 0
    local faster_turn = false

    local controlled_pill = nil

    -- POPULATE BOARD WITH VIRUSES AND GET THE COLORS BEING USED THIS MATCH
    local virus_types = layout_generator(board, 2)

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

    function move_tile(x, y, dx, dy)
        assert(board.is_within_bounds(x, y), "Position must be within the bounds of the board.")
        local next_x, next_y = x + dx, y + dy
        if board.is_within_bounds(next_x, next_y) == false or board[next_x][next_y] ~= nil then
            return false
        end
        local tile = board[x][y]
        board[x][y] = nil
        board[next_x][next_y] = tile
        return true
    end

    function check_combo(x, y)
        assert(board.is_within_bounds(x, y), "x and y must be within the bounds of the board.")
        local master = board[x][y]
        local vertical_combo = {{x = x, y = y}}
        local horizontal_combo = {{x = x, y = y}}

        for cx = x + 1, board_width, 1 do
            local current_tile = board[cx][y]
            if current_tile == nil or current_tile.color ~= master.color then
                break
            end
            table.insert(horizontal_combo, {x = cx, y = y})
        end

        for cx = x - 1, 1, -1 do
            local current_tile = board[cx][y]
            if current_tile == nil or current_tile.color ~= master.color then
                break
            end
            table.insert(horizontal_combo, {x = cx, y = y})
        end

        for cy = y + 1, board_height, 1 do
            local current_tile = board[x][cy]
            if current_tile == nil or current_tile.color ~= master.color then
                break
            end
            table.insert(vertical_combo, {x = x, y = cy})
        end

        for cy = y - 1, 1, -1 do
            local current_tile = board[x][cy]
            if current_tile == nil or current_tile.color ~= master.color then
                break
            end
            table.insert(vertical_combo, {x = x, y = cy})
        end

        if #horizontal_combo > 3 then
            for _, coordinate in ipairs(horizontal_combo) do
                board[coordinate.x][coordinate.y] = nil
            end
        end

        if #vertical_combo > 3 then
            for _, coordinate in ipairs(vertical_combo) do
                board[coordinate.x][coordinate.y] = nil
            end
        end

        if #vertical_combo > 3 or #horizontal_combo > 3 then
            return true
        else
            return false
        end
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
            if faster_turn then
                turn_timer = turn_timer + dt * 2
            else
                turn_timer = turn_timer + dt
            end
            if turn_timer > turn_delay then
                turn_timer = 0
                if falling_mode then
                    -- Drop all of the half pills
                    -- Drop from bottom layer up
                    local keep_falling = false
                    for x = board_width, 1, -1 do
                        for y = board_height, 1, -1 do
                            local tile = board[x][y]

                            local complementary = {
                                ["left_horizontal_bar"] = {x = 1, y = 0, type = "right_horizontal_bar"},
                                ["right_horizontal_bar"] = {x = -1, y = 0, type = "left_horizontal_bar"},
                                ["top_vertical_bar"] = {x = 0, y = 1, type = "DOESNT MATTER"},
                                ["bottom_vertical_bar"] = {x = 0, y = -1, type = "DOESNT MATTER"}
                            }

                            if tile ~= nil then
                                complement = complementary[tile.type]
                                if complement then
                                    local next_x, next_y = complement.x + x, complement.y + y
                                    if
                                        not (board.is_within_bounds(next_x, next_y) and board[next_x][next_y] ~= nil and
                                            board[next_x][next_y].type == complement.type)
                                     then
                                        -- DROP THE PARTIAL PILLS
                                        if move_tile(x, y, 0, 1) then
                                            keep_falling = true
                                        else
                                            check_combo(x, y)
                                        end
                                    elseif
                                        board.is_within_bounds(x, y + 1) and board.is_within_bounds(next_x, next_y + 1)
                                     then
                                        if
                                            board[x][y + 1] == nil and
                                                (board[next_x][next_y + 1] == nil)
                                         then
                                            -- DROP UNSUPPORTED PILLS
                                            move_tile(x, y, 0, 1)
                                            move_tile(next_x, next_y, 0, 1)
                                         else
                                            check_combo(x, y)
                                        end
                                    else
                                    end
                                end
                            end
                        end
                    end
                    if not keep_falling then
                        falling_mode = false
                    end
                else
                    -- CREATE A NEW PILL IF THERE ARE CURRENTLY NO CONTROLLED PILLS
                    if controlled_pill == nil then
                        add_pill()
                    else
                        -- APPLY GRAVITY TO PILL, IF PILL CAN'T MOVE DOWN THEN SET IT
                        if not move_controlled(0, 1) then
                            for _, portion in ipairs(controlled_pill) do
                                if check_combo(portion.x, portion.y) then
                                    falling_mode = true
                                end
                            end
                            controlled_pill = nil
                        end
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
