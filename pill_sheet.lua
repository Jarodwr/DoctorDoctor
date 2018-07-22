local sheeter = require "sheeter"

local color_map = {
    [0] = {[0] = "steel", [1] = "grey", [2] = "coal"},
    [1] = {[0] = "white", [1] = "iron", [2] = "dirt"},
    [2] = {[0] = "red", [1] = "tawny", [2] = "crimson"},
    [3] = {[0] = "cream", [1] = "orange", [2] = "chocolate"},
    [4] = {[0] = "banana", [1] = "apricot", [2] = "bronze"},
    [5] = {[0] = "grass", [1] = "green", [2] = "forest"},
    [6] = {[0] = "cyan", [1] = "blue", [2] = "river"},
    [7] = {[0] = "lake", [1] = "night", [2] = "ocean"}
}

local type_map = {
    [1] = {
        [1] = "single_bar",
        [2] = "top_vertical_bar",
        [3] = "middle_vertical_bar",
        [4] = "bottom_vertical_bar",
        [5] = "yin_yang"
    },
    [2] = {
        [1] = "left_horizontal_bar",
        [2] = "single_block",
        [3] = "top_vertical_block",
        [4] = "middle_vertical_block",
        [5] = "bottom_vertical_block"
    },
    [3] = {
        [1] = "middle_horizontal_bar",
        [2] = "left_horizontal_block",
        [3] = "top_left_block",
        [4] = "left_block",
        [5] = "bottom_left_block"
    },
    [4] = {
        [1] = "right_horizontal_bar",
        [2] = "middle_horizontal_block",
        [3] = "top_block",
        [4] = "middle_block",
        [5] = "bottom_block"
    },
    [5] = {
        [1] = "hoop",
        [2] = "right_horizontal_block",
        [3] = "top_right_block",
        [4] = "right_block",
        [5] = "bottom_right_block"
    },
    [6] = {
        [1] = "triangle",
        [2] = "rectangle",
        [3] = "star",
        [4] = "hexagon",
        [5] = "heart"
    },

}

return sheeter(
    "puhzil.png",
    16,
    16,
    function(x, y)
        if y ~= 0 then
            local chunk = {
                x = math.floor(x / 7),
                y = math.floor((y - 1) / 6)
            }

            local offset = {
                x = x % 7,
                y = (y - 1) % 6
            }

            if chunk.x < 8 and chunk.y < 3 then
                if offset.x > 0 and offset.y > 0 then
                    local color = color_map[chunk.x][chunk.y]
                    local type = type_map[offset.x][offset.y]
                    return color .. ":" .. type
                end
            end

            return chunk.x .. "," .. chunk.y .. ":" .. offset.x .. "," .. offset.y
        end
    end
)
