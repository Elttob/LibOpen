--!strict
-- Tabby - Some table manipulation utils
-- (c) Daniel P H Fox, licensed under MIT

local function findSortedInsertPoint<T>(
	array: {T},
	value: T,
	order: (T) -> number
): number
	local from = 1
	local to = #array
	local valueOrder = order(value)
	while from <= to do
		local median = (from + to) // 2
		local medianOrder = order(array[median])
		if valueOrder == medianOrder then
			return median
		elseif valueOrder < medianOrder then
			to = median - 1
		else
			from = median + 1
		end
	end
	return from
end

return findSortedInsertPoint