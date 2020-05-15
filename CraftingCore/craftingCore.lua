BLOCK_CHEST = "minecraft:chest"
BLOCK_HOME = "minecraft:chest"

POS_HOME = vector.new(0,0,0)
POS_FUEL = vector.new(1,0,0)
POS_INJECTORS = {vector.new(0,1,0),vector.new(0,2,0),vector.new(0,3,0),vector.new(0,4,0),vector.new(0,5,0),
    vector.new(1,5,0),vector.new(1,4,0),vector.new(1,3,0),vector.new(1,2,0),vector.new(1,1,0),
    vector.new(2,1,0),vector.new(2,2,0),vector.new(2,3,0),vector.new(2,4,0),vector.new(2,5,0),
    vector.new(3,5,0),vector.new(3,4,0),vector.new(3,3,0),vector.new(3,2,0),vector.new(3,1,0),
    vector.new(4,1,0),vector.new(4,2,0),vector.new(4,3,0),vector.new(4,4,0),vector.new(4,5,0)}
POS_CORE = vector.new(1,0,0)
POS_REDSTONE = vector.new(1,0,0)

RT_HOME = 2
RT_FUEL = 2

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
        else
            while true do
                if not turtle.forward() then
                    turtle.turnRight()
                    turtle.forward()
                end
                _, block = turtle.inspectDown()
                if block.name == BLOCK_HOME then return end
            end
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

    inventory = {}

    move(POS_HOME, RT_HOME)
    local chest = peripheral.wrap("front")
    local items = chest.list()

    for i=1, table.getn(items), 1 do
        addInv(items[i])
    end
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
            return {id=i, n=math.min(n, 64)}
        end
    end
    return {id=0, n=0}
end

function craftRecipe(rcp)
    local recipe = recipes[rcp.id]

    function tryPushItem()
        if not peripheral.isPresent("bottom") then return false end

        return turtle.dropDown(1)
    end

    function pushItem()
        while not tryPushItem() do
            sleep(2)
        end
    end

    function discardItem()
        move(POS_HOME, RT_HOME)
        if not peripheral.isPresent("bottom") then return false end

        return turtle.dropDown()
    end

    function pullItem()
        turtle.suck(1)
        while turtle.getItemCount() == 0 do
            sleep(2)
            turtle.suck(1)
        end
    end

    print("Crafting Recipe" .. rcp.id)
    turtle.select(1)

    -- Place core item
    move(POS_HOME)
    redstone.setOutput("right", true)
    while true do
        pullItem()
        local item = turtle.getItemDetail()

        if item.name == recipe[1].name and item.damage == recipe[1].damage then
            redstone.setOutput("right", false)
            move(POS_CORE)
            pushItem()
            break
        else
            discardItem()
        end
    end
    table.remove(recipe, 1)

    -- Place crafting items
    local injector = 1

    while table.getn(recipe) > 0 do
        move(POS_HOME, RT_HOME)

        for i=1, 16, 1 do
            if table.getn(recipe) == 0 then break end
            turtle.select(i)

            local itemOK = false
            redstone.setOutput("right", true)
            while not itemOK do
                pullItem()
                local item = turtle.getItemDetail()

                for j=1, table.getn(recipe), 1 do
                    if item.name == recipe[j].name and item.damage == recipe[j].damage then
                        itemOK = true
                        break
                    end
                end
                if not itemOK then discardItem() end
            end
            redstone.setOutput("right", false)
        end

        for i=1, 16, 1 do
            turtle.select(i)
            if turtle.getItemCount == 0 then break end
            move(POS_INJECTORS[injector])
            pushItem()
            injector = injector + 1
        end
    end

end

readFile()
home()

readInventory()
craftRecipe(checkRecipe())