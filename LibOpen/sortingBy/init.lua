--!strict
-- (c) Daniel P H Fox, licensed under MIT

local function sortingBy<T>(
	extract: (T) -> {number | string}
): (T, T) -> boolean
	return function(a, b)
		local extractA = extract(a)
		local extractB = extract(b)
		assert(#extractA == #extractB, "sortingBy expects the same number of values to be provided at all times")
		local comparison = false
		for index, valueA in extractA do
			local valueB = extractB[index]
			comparison = valueA < valueB
			if valueA ~= valueB then
				break
			end
		end
		return comparison
	end
end

return sortingBy