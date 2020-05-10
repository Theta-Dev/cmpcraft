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
        _, block = turtle.inspectDown()
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
            _, block = turtle.inspect()
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
    delta = r - rt
    if delta == 0 then return
    elseif Math.abs(delta) == 3 then
        if delta > 0 then turtle.turnLeft()
        else turtle.turnRight() end
    else
        for i=1, Math.abs(delta), 1 do
            if delta > 0 then turtle.turnRight()
            else turtle.turnLeft() end
        end
    end
end

function move(x, y, z, r)
    function moveX()

    end
end

function refuel()

end

home()