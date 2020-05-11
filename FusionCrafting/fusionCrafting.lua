BLOCK_FIELD = "minecraft:quartz_block"
BLOCK_HOME = "minecraft:lapis_block"
BLOCK_CHEST = "minecraft:chest"

POS_HOME = vector.new(0,0,0)
POS_FUEL = vector.new(1,0,0)
POS_INJECTORS = {vector.new(0,0,0), vector.new(0,0,1), vector.new(0,0,2), vector.new(0,1,2), vector.new(0,1,1), vector.new(0,1,0), vector.new(0,2,0), vector.new(0,2,1), vector.new(0,2,2),
    vector.new(2,2,1), vector.new(2,2,0), vector.new(2,1,0), vector.new(2,0,0)}
POS_CORE = vector.new(0,1,1)
POS_REDSTONE = vector.new(1,0,0)

RT_HOME = 2
RT_FUEL = 2
RT_INJECTORS = {3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1}
RT_CORE = 1

pos = vector.new(0,0,0)
rt = 2

recipes = {}
inventory = {}

function home()
    function moveHome()
        -- Move down
        while turtle.down() do end
        local _, block = turtle.inspectDown()
        if block.name == BLOCK_HOME then return
        elseif block.name == BLOCK_FIELD then
            for i=1, 10, 1 do
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

    function tryMove()
        local res = false
        for i=1, 2, 1 do
            res = moveX(p.x)
            res = res and moveY(p.y)
            res = res and moveZ(p.z)

            if not res then moveZ(2)
            else break end
        end

        if not res then return false end

        if r ~= nil then rotate(r) end
        return true
    end

    while not tryMove() do
        print("Movement failed")
        sleep(5)
    end
end

function refuel()
    if turtle.getFuelLevel() > 100 then return end

    for i=1, 16, 1 do
        turtle.select(i)
        if turtle.getItemCount() == 0 then break end
    end
    if turtle.getItemCount() > 0 then return end

    move(POS_FUEL, RT_FUEL)
    turtle.suck()
    if turtle.refuel() then
        print("Turtle refueled. Fuel level: " .. turtle.getFuelLevel())
    end
end

function readFile()
    local file = fs.open("recipes.txt", "r")
    recipes = {}

    while true do
        local line = file.readLine()
        if line == nil then break end
        local recipe = {}
        
        for itemstr in string.gmatch(line, "[^|]+") do
            local item = string.gmatch(itemstr, "[^;]+")
            table.insert(recipe, {count=tonumber(item(0)), name=item(1), damage=tonumber(item(2))})
            --print(item(0) .. " : " .. item(1) .. " : " .. item(2))
        end
        table.insert(recipes, recipe)
    end
    file.close()
end

function readInventory()
    function addInv(item)
        for i=1, table.getn(inventory), 1 do
            if inventory[i].name == item.name and inventory[i].damage == item.damage then
                inventory[i].count = inventory[i].count + item.count
                return
            end
        end
        table.insert(inventory, item)
    end

    for i=1, 16, 1 do
        turtle.select(i)
        if turtle.getItemCount() > 0 then
            local item = turtle.getItemDetail()
            addInv(item)
        end
    end
    print(table.getn(inventory))
end

function checkRecipe()
    for i=1, table.getn(recipes), 1 do
        local n = 10000
        for j=1, table.getn(recipes[i]), 1 do
            local item = recipes[i][j]
            local found = false

            for k=1, table.getn(inventory), 1 do
                if inventory[k].name == item.name and inventory[k].damage == item.damage then
                    n = math.min(n, math.floor(inventory[k].count / item.count))
                    found = true
                    break
                end
            end

            if not found then
                n = 0
                break
            end
        end
        if n > 0 and n < 10000 then
            return {id=i, n=n}
        end
    end
    return {id=0, n=0}
end

function craftRecipe(recipe)
    function pushItem(item)
        if not peripheral.isPresent("front") then return false end

        local count = item.count

        for i=1, 16, 1 do
            turtle.select(i)
            if turtle.getItemCount() > 0 then
                local it = turtle.getItemDetail()
                
                if it.name == item.name and it.damage == item.damage then
                    turtle.drop(count)
                    count = count - it.count
                end
            end

            if count <= 0 then return true end
        end
        return false
    end

    if recipe.id == 0 or recipe.n == 0 then return 0 end

    -- Place core item
    move(POS_CORE, RT_CORE)
    pushItem(recipes[recipe.id][1])
end

function test()
    for i=1, #POS_INJECTORS, 1 do
        move(POS_INJECTORS[i], RT_INJECTORS[i])
        sleep(1)
    end
end


home()
refuel()
readFile()
readInventory()
craftRecipe(checkRecipe())