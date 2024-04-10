--!strict
-- (c) Daniel P H Fox, licensed under MIT

local Package = script.Parent
local doCleanup = require(Package.doCleanup)

local function FinallyTask<Args...>(
	taskExec: (
		callback: ({unknown}, Args...) -> (),
		scope: {unknown},
		Args...
	) -> thread,
	callback: ({unknown}, Args...) -> (),
	...: Args...
): () -> ()
	local destroyed = false
	local scope: {unknown} = {}
	local coro: thread = taskExec(
		function(scope, ...)
			local ok, result = xpcall(callback :: any, function(err)
				destroyed = true
				doCleanup(scope)
				return err
			end, scope, ...)
			if not ok then
				error(result)
			end
		end,
		scope,
		...
	)
	return function()
		if destroyed then
			return
		end
		pcall(task.cancel, coro)
		destroyed = true
		doCleanup(scope)
	end
end

return FinallyTask