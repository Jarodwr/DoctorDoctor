local pill_sheet = require "pill_sheet"

return function(width, height)
    assert(type(width) == "number", "Width must be a number.")
    assert(type(height) == "number", "Height must be a number.")
    assert(width % 2 == 0, "Width of the board must be divisible by 2.")
    assert(height % 2 == 0, "Height of the board must be divisible by 2.")

    local tile_width, tile_height = pill_sheet.get_tile_dimensions()

    local wall = {
        top = 0,
        bottom = (height + 1) * tile_height,
        left = 0,
        right = (width + 1) * tile_width
    }

    local board = {}
    for x = 1, width do
        local column = {}
        -- Metatable only allows creation and modification of indexes within bounds of board
        board[x] =
            setmetatable(
            {},
            {
                __index = function(table, key)
                    return column[key]
                end,
                __newindex = function(table, key, value)
                    assert(type(key) == "number", "Key must be a number.")
                    assert(
                        key > 0 and key <= height,
                        "Key must be a valid index, valid indexes are from 1 to " .. height .. "."
                    )
                    column[key] = value
                end
            }
        )
    end

    function board.draw()
        -- DRAW THE BORDER
        -- Make sure to keep an opening in the top for the new pill
        local top_opening = math.floor(width / 2)
        for x = 1, width do
            local current_column = x * tile_width
            if x ~= top_opening and x ~= top_opening + 1 then
                -- TOP BORDER
                pill_sheet.drawk("steel:bottom_block", current_column, wall.left)
            end
            -- BOTTOM BORDER
            pill_sheet.drawk("steel:top_block", current_column, wall.bottom)
        end

        for y = 1, height do
            local current_row = y * tile_height
            -- LEFT BORDER
            pill_sheet.drawk("steel:right_block", wall.left, current_row)
            -- RIGHT BORDER
            pill_sheet.drawk("steel:left_block", wall.right, current_row)
        end

        for _, horizontal in ipairs({wall.left, wall.right}) do
            for _, vertical in ipairs({wall.top, wall.bottom}) do
                pill_sheet.drawk("steel:middle_block", horizontal, vertical)
            end
        end

        -- DRAW THE CONTENTS
        for x = 1, width do
            for y = 1, height do
                if board[x][y] then
                    local tile = board[x][y]
                    pill_sheet.drawk(tile.color .. ":" .. tile.type, x * tile_width, y * tile_height)
                -- else
                --     pill_sheet.drawk("green:heart", x * tile_width, y * tile_height)
                end
            end
        end
    end

    local calculated_width = (width + 2) * tile_width
    local calculated_height = (height + 2) * tile_height

    function board.get_dimensions()
        return calculated_width, calculated_height
    end

    function board.get_bounds()
        return width, height
    end

    function board.get_tile_dimensions()
        return pill_sheet.get_tile_dimensions()
    end

    function board.is_within_bounds(x, y)
        return x >= 1 and x <= width and y >= 1 and y <= height
    end

    return setmetatable(
        {},
        {
            __index = function(table, key)
                return board[key]
            end,
            __newindex = function(table, key, value)
                error("You are not meant to directly set the columns of the board.")
            end
        }
    )
end
