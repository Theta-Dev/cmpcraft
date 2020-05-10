for i=1, 17, 1 do
	if turtle.getItemCount() > 0 then
		item = turtle.getItemDetail()
		line = item.count .. ':' .. item.name .. ':' .. item.damage .. ';'

		print(line)
	end
end