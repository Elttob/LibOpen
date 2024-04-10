--!strict
-- (c) Daniel P H Fox, licensed under MIT

local Package = script.Parent
local doCleanup = require(Package.doCleanup)

local function Finally<Return, Args...>(
	fallible: ({unknown}, Args...) -> Return,
	...: Args...
): Return
	local scope = {}
	local ok, result = pcall(fallible, scope, ...)
	doCleanup(scope)
	if ok then
		return result
	else
		error(result)
	end
end

return Finally