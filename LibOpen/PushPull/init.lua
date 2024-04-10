--!strict
-- (c) Daniel P H Fox, licensed under MIT

local Package = script.Parent
local Maybe = require(Package.Maybe)

type Pack = {[number]: unknown, n: number}

local PushPull = {}

function PushPull.yield<Values...>(): (
	(Values...) -> (),
	() -> (Values...)
)
	local waiting: {[thread]: true} = {}
	local buffer: {Pack} = {}
	local function push(...)
		table.insert(buffer, table.pack(...))
		local thread = next(waiting)
		if thread ~= nil then
			waiting[thread] = nil
			task.spawn(thread)
		end
	end
	local function pull()
		while #buffer == 0 do
			waiting[coroutine.running()] = true
			coroutine.yield()
		end
		local values = table.remove(buffer, 1) :: Pack
		return table.unpack(values, 1, values.n)
	end
	return
		push,
		pull :: any
end

function PushPull.maybe<Value>(): (
	(Value) -> (),
	() -> Maybe.Maybe<Value>
)
	local buffer: {Value} = {}
	local function push(v)
		table.insert(buffer, v)
	end
	local function pull(): Maybe.Maybe<Value>
		if #buffer == 0 then
			return Maybe.None("No value pushed")
		else
			return Maybe.Some(table.remove(buffer, 1) :: Value)
		end
	end
	return
		push,
		pull :: any
end

return PushPull