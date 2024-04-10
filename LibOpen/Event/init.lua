--!strict
-- (c) Daniel P H Fox, licensed under MIT

export type Connect<Args...> = (callback: (Args...) -> ()) -> () -> ()

local function Event<Args...>(): (
	Connect<Args...>, 
	(Args...) -> ()
)
	local listeners: {[{}]: (Args...) -> ()} = {}
	local function connect(
		callback: (Args...) -> ()
	): () -> ()
		local id = {}
		listeners[id] = callback
		return function(): ()
			listeners[id] = nil
		end
	end
	local function fire(
		...: Args...
	): ()
		for _, listener in listeners do
			task.spawn(listener, ...)
		end
	end
	return connect, fire
end

return Event