local score_digits = 7

local font =
    love.graphics.newImageFont(
    "16x16Font.png",
    ' !"#$%€\'[]*+,-./0123456789:;<=>?'..
    '@abcdefghijklmnopqrstuvwxyz[\\]^_'..
    '`ABCDEFGHIJKLMNOPQRSTUVWXYZ{|}~©'
)

function next_row(num)
    local num = num or 1
    love.graphics.translate(0, 16 * num)
end

return function(high_score, initial_level, initial_speed, initial_virus_count)
    local high_score = high_score or 0
    local current_score = 0
    local level = initial_level or 1
    local speed = initial_speed or "slow"
    local virus = initial_virus_count or 0

    return {
        draw = function()
            love.graphics.push()
            love.graphics.setFont(font)
            love.graphics.print("HIGH SCORE")
            next_row()
            love.graphics.print(string.format("%0"..score_digits.."d", high_score))
            next_row(2)
            love.graphics.print("CURRENT SCORE")
            next_row()
            love.graphics.print(string.format("%0"..score_digits.."d", current_score))
            next_row(2)
            love.graphics.print("LEVEL")
            next_row()
            love.graphics.print(string.format("%02d", level))
            next_row(2)
            love.graphics.print("SPEED:" .. speed)
            next_row(2)
            love.graphics.print("VIRUS")
            next_row()
            love.graphics.print(string.format("%02d", virus))
            love.graphics.pop()
        end,
    }
end