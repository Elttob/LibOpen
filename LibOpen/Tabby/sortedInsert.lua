--!strict
-- Tabby - Some table manipulation utils
-- (c) Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent
local findSortedInsertPoint = require(Package.Tabby.findSortedInsertPoint)

local function sortedInsert<T>(
	array: {T},
	value: T,
	order: (T) -> number
): number
	local index = findSortedInsertPoint(array, value, order)
	table.insert(array, index, value)
	return index
end

return sortedInsert