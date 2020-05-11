recipe = ""
count = 0

for i=1, 16, 1 do
	turtle.select(i)
	if turtle.getItemCount() > 0 then
		item = turtle.getItemDetail()
		line = item.count .. ";" .. item.name .. ";" .. item.damage .. "|"

		print(line)
		recipe = recipe .. line
		count = count + 1
	end
end

if count > 1 then
	file = fs.open("recipes.csv", "a")
	file.writeLine(recipe)
	file.close()
	print("Recipe added")
else
	print("Less than 2 items found")
end