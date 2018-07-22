local level_rows = {10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 12, 12, 13}

-- ALGORITHM FROM: https://tetris.wiki/Dr._Mario#Virus_Generation

return function(board, virus_level, colors)
    local board_width, board_height = board.get_bounds()
    local virus_level = virus_level
    local remaining_viruses = virus_level * 4
    local max_virus_row = level_rows[virus_level] or 13

    -- TODO: Randomly generate these
    local virus_types = colors

    function check_virus_tile(x, y, type)
        local check_list = {}
        for _, type in ipairs(virus_types) do
            check_list[type] = false
        end

        local count = 0
        for _, coordinate in ipairs(
            {
                {x = x + 2, y = y},
                {x = x - 2, y = y},
                {x = x, y = y + 2},
                {x = x, y = y - 2}
            }
        ) do
            if board.is_within_bounds(coordinate.x, coordinate.y) and board[coordinate.x][coordinate.y] ~= nil then
                local color = board[coordinate.x][coordinate.y].color
                if check_list[color] == false then
                    count = count + 1
                end
                check_list[color] = true
            end
        end

        return count ~= 3
    end

    function generate_candidate(x, y, type)
        local candidate = {x = x, y = y, type = type}
        while board[candidate.x][candidate.y] ~= nil and check_virus_tile(candidate.x, candidate.y, candidate.type) do
            candidate.x = candidate.x + 1
            if candidate.x > board_width then
                candidate.x = 1
                candidate.y = candidate.y + 1
                if candidate.y > board_height then
                    return
                end
            end
        end
        return candidate
    end

    function generate_virus()
        local virus_position = {
            x = math.random(1, board_width),
            y = math.random(max_virus_row, board_height)
        }

        local virus_type = virus_types[(remaining_viruses % 3) + 1]

        local candidate = generate_candidate(virus_position.x, virus_position.y, virus_type)
        if candidate ~= nil then
            local pass = true
            for _, coordinate in ipairs(
                {
                    {x = candidate.x + 2, y = candidate.y},
                    {x = candidate.x - 2, y = candidate.y},
                    {x = candidate.x, y = candidate.y + 2},
                    {x = candidate.x, y = candidate.y - 2}
                }
            ) do
                if
                    board.is_within_bounds(coordinate.x, coordinate.y) and board[coordinate.x][coordinate.y] ~= nil and
                        board[coordinate.x][coordinate.y].color == candidate.type
                 then
                    pass = false
                    break
                end
            end
            if pass then
                board[candidate.x][candidate.y] = tile(candidate.type, "heart")
            else
                -- PLEASE REMEMBER HOW TO DO THIS IN THE MORNING FUCK
            end
        else
            return remaining_viruses
        end

        -- TODO
        return remaining_viruses - 1
    end

    while (remaining_viruses > 0) do
        remaining_viruses = generate_virus()
    end
end