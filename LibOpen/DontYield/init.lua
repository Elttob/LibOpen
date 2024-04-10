--!strict
-- (c) Daniel P H Fox, licensed under MIT

local function DontYield(
	callback: any,
	...: any
): any
	local coro = coroutine.create(callback)
	local pack = table.pack(coroutine.resume(coro))
	assert(coroutine.status(coro) == "dead", "Yielded inside of a DontYield block")
	return table.unpack(pack, 1, pack.n)
end

return DontYield :: <Return..., Args...>(
	callback: (Args...) -> Return..., 
	Args...
) -> (
	boolean, 
	Return...
)