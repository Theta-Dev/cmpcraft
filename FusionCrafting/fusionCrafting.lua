BLOCK_FIELD = "minecraft:quartz_block"
BLOCK_HOME = "minecraft:lapis_block"
BLOCK_CHEST = "minecraft:chest"

POS_HOME = vector.new(0,0,0)
POS_FUEL = vector.new(1,0,0)

RT_HOME = 2
RT_FUEL = 2

pos = vector.new(0,0,0)
rt = 2

function home()
    function moveHome()
        -- Move down
        while turtle.down() do end
        local _, block = turtle.inspectDown()
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
            local _, block = turtle.inspect()
            if block.name == BLOCK_CHEST then return
            else
                turtle.turnRight()
            end
        end
        error("Could not detect chest")
    end

    moveHome()
    rotateHome()

    pos.x = POS_HOME.x
    pos.y = POS_HOME.y
    pos.z = POS_HOME.z
    rt = RT_HOME
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

function move(p, r)

    function moveX(mx)
        local delta = mx - pos.x

        if delta == 0 then return true end

        if rt~=1 and rt~=3 then rotate(1) end

        for i=1, math.abs(delta), 1 do
            local res
            if (rt==1 and delta>0) or (rt==3 and delta<0) then res = turtle.forward()
            else res = turtle.back() end
            if not res then return false end
        end
        pos.x = mx
        return true
    end

    function moveY(my)
        local delta = my - pos.y

        if delta == 0 then return true end

        if rt~=0 and rt~=2 then rotate(0) end

        for i=1, math.abs(delta), 1 do
            local res
            if (rt==0 and delta>0) or (rt==2 and delta<0) then res = turtle.forward()
            else res = turtle.back() end
            if not res then return false end
        end
        pos.y = my
        return true
    end

    function moveZ(mz)
        local delta = mz - pos.z

        if delta == 0 then return true end

        for i=1, math.abs(delta), 1 do
            local res
            if delta>0 then res = turtle.up()
            else res = turtle.down() end
            if not res then return false end
        end
        pos.z = mz
        return true
    end

    local res = false
    for i=1, 2, 1 do
        res = moveX(p.x)
        res = res and moveY(p.y)
        res = res and moveZ(p.z)

        if not res then moveZ(2)
        else return true end
    end

    if not res then error("Movement error") end

    rotate(r)
    return
end

function refuel()
    --if turtle.getFuelLevel() > 100 then return end

    for i=1, 16, 1 do
        turtle.select(i)
        if turtle.getItemCount() == 0 then return end
    end
    if turtle.getItemCount() > 0 then return end
    
    move(POS_FUEL, RT_FUEL)
    turtle.suck()
    if turtle.refuel() then
        print("Turtle refueled. Fuel level: " .. turtle.getFuelLevel())
    end
end

home()
refuel()