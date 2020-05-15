recipe = ""
count = 0

chest = peripheral.wrap("front")
items = chest.list()

for i=1, table.getn(items), 1 do
	if items[i] ~= nil then
		local line = items[i].count .. ";" .. items[i].name .. ";" .. items[i].damage .. "|"

		print(line)
		recipe = recipe .. line
		count = count + 1
	end
end

if count > 1 then
	file = fs.open("recipes.txt", "a")
	file.writeLine(recipe)
	file.close()
	print("Recipe added")
else
	print("Less than 2 items found")
end