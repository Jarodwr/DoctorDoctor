return function(filepath, width, height, key_generator)
    local key_generator = key_generator or function() end

    local refs = {}
    local quads = {}
    local image = love.graphics.newImage(filepath)

    local image_width, image_height = image:getDimensions()

    local count = {x = image_width / width, y = image_height / height}

    for x = 0, count.x - 1 do
        quads[x] = {}
        for y = 0, count.y - 1 do
            local left, top = x * width, y * height
            quads[x][y] = love.graphics.newQuad(left, top, width, height, image_width, image_height)
            local key = key_generator(x, y)
            if key then
                refs[key] = quads[x][y]
            end
        end
    end

    return {
        draw = function(gx, gy, ...)
            love.graphics.draw(image, quads[gx][gy], ...)
        end,
        drawk = function(key, ...)
            love.graphics.draw(image, refs[key], ...)
        end,
        get_tile_dimensions = function()
            return width, height
        end
    }
end