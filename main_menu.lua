local match = require "match"
local font =
love.graphics.newImageFont(
"16x16Font.png",
' !"#$%€\'[]*+,-./0123456789:;<=>?'..
'@abcdefghijklmnopqrstuvwxyz[\\]^_'..
'`ABCDEFGHIJKLMNOPQRSTUVWXYZ{|}~©'
)

return function(scene_change_callback)
    local level_select = true

    local level = 1
    local speed = "fast"

    return {
        draw = function()
            love.graphics.setFont(font)
            love.graphics.push()
            love.graphics.print(level)
            love.graphics.translate(0, 20)
            love.graphics.print(speed)
            love.graphics.translate(0, 20)
            love.graphics.print("PRESS RETURN/ENTER TO START")
            love.graphics.pop()
        end,
        update = function(dt)

        end,
        keypressed = function(key)
            if key == "up" or key == "down" then
                level_select = not level_select
            elseif key == "left" then
                if level_select then
                    level = level-1>0 and level-1 or level
                else
                    if speed == "fast" then
                        speed = "medium"
                    elseif speed == "medium" then
                        speed = "slow"
                    end
                end
            elseif key == "right" then
                if level_select then
                    level = level+1<20 and level+1 or level
                else
                    if speed == "slow" then
                        speed = "medium"
                    elseif speed == "medium" then
                        speed = "fast"
                    end
                end
            elseif key == "return" then
                scene_change_callback("match", 0, level, speed)
            end
        end,
        keyreleased = function(key)

        end
    }
end
