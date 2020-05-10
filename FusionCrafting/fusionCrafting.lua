BLOCK_FIELD = "minecraft:quartz_block"
BLOCK_HOME = "minecraft:lapis_block"
BLOCK_CHEST = "minecraft:chest"

posX = 0
posY = 0
posZ = 0
rotation = 2

function home()
    function moveHome()
        -- Move down
        while turtle.down() do end
        _, block = turtle.inspectDown()
        if block.name == BLOCK_HOME then return
        elseif block.name == BLOCK_FIELD then
            for i=0, 3, 1 do
                turtle.turnRight()
                turtle.forward()
                _, block = turtle.inspectDown()
                if block.name == BLOCK_HOME then return
                elseif block.name != BLOCK_FIELD then
                    turtle.back()
                end
            end
            error("Could not detect field")
        else
            error("Could not detect floor")
        end
    end

    function rotateHome()
        for i=0, 3, 1 do
            _, block = turtle.inspect()
            if block.name == BLOCK_CHEST then return
            turtle.turnRight()
        end
        error("Could not detect chest")
    end

    moveHome()
    rotateHome()

    posX = 0
    posY = 0
    posZ = 0
    rotation = 2
end

function move(x, y, z)

end

function refuel()

end

home()