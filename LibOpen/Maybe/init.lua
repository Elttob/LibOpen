--!strict
--!nolint LocalShadow
-- Maybe - Non-throwing error values
-- (c) Daniel P H Fox, licensed under MIT

export type Some<Value> = {some: true, value: Value}
export type None<Reason = string> = {some: false, reason: Reason}
export type Maybe<Value, Reason = string> = Some<Value> | None<Reason>

local Maybe = {}

function Maybe.Some<Value>(
	value: Value
): Some<Value>
	return {some = true, value = value}
end

function Maybe.None<Reason>(
	reason: Reason
): None<Reason>
	return {some = false, reason = reason}
end

return Maybe