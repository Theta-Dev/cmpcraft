BLOCK_FIELD = "minecraft:quartz_block"
BLOCK_HOME = "minecraft:lapis_block"
BLOCK_CHEST = "minecraft:chest"

posX = 0
posY = 0
posZ = 0
rt = 2

function home()
    function moveHome()
        -- Move down
        while turtle.down() do end
        _, local block = turtle.inspectDown()
        if block.name == BLOCK_HOME then return
        elseif block.name == BLOCK_FIELD then
            for i=1, 5, 1 do
                if not turtle.forward() then
                    turtle.turnRight()
                end
                _, block = turtle.inspectDown()
                if block.name == BLOCK_HOME then return
                elseif block.name ~= BLOCK_FIELD then
                    turtle.back()
                    turtle.turnRight()
                end
            end
            error("Could not detect field")
        else
            error("Could not detect floor")
        end
    end

    function rotateHome()
        for i=1, 4, 1 do
            _, local block = turtle.inspect()
            if block.name == BLOCK_CHEST then return
            else
                turtle.turnRight()
            end
        end
        error("Could not detect chest")
    end

    moveHome()
    rotateHome()

    posX = 0
    posY = 0
    posZ = 0
    rt = 2
end

function rotate(r)
    local delta = r - rt
    if delta == 0 then return
    elseif math.abs(delta) == 3 then
        if delta > 0 then turtle.turnLeft()
        else turtle.turnRight() end
    else
        for i=1, math.abs(delta), 1 do
            if delta > 0 then turtle.turnRight()
            else turtle.turnLeft() end
        end
    end
    rt = r
end

function move(x, y, z, r)
    -- Handle nil parameters
    if x == nil then x = posX end
    if y == nil then y = posY end
    if z == nil then z = posZ end
    if r == nil then r = rt end

    function moveX()
        local delta = x - posX

        if delta == 0 then return end

        if rt~=1 and rt~=3 then rotate(1) end

        for i=1, math.abs(delta), 1 do
            if (rt==1 and delta>0) or (rt==3 and delta<0) then turtle.forward()
            else turtle.back() end
        end
    end

    moveX()

    posX = x
    posY = y
    posZ = z
end

function refuel()

end

home()
move(2,,,)