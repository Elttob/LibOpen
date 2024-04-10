--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local MapOf: Types.FnMapOf = function<K, V>(keys: Types.Def, values: Types.Def)
	return Def.new(
		`\{[{keys.ExpectsType}]: {values.ExpectsType}}`,
		function(self, x)
			if typeof(x) ~= "table" then
				return false
			end
			local x = x :: {[unknown]: unknown}
			for key, value in pairs(x) do
				if not keys:Matches(key) or not values:Matches(value) then
					return false
				end
			end
			return true
		end,
		function(self, x)
			if typeof(x) ~= "table" then
				return Maybe.None(`{self.NotOfTypeError}\n...because {tostring(x)} isn't a table`)
			end
			local x = x :: {[unknown]: unknown}
			local modifiedReturn = {}
			for key, value in pairs(x) do
				local castedKey = keys:Cast(key)
				if not castedKey.some then
					return Maybe.None(`{self.NotOfTypeError}\n...because of the key {tostring(key)}: {castedKey.reason}`)
				end
				local castedValue = values:Cast(value)
				if not castedValue.some then
					return Maybe.None(`{self.NotOfTypeError}\n...because of the value at key {tostring(key)}: {castedValue.reason}`)
				end
				modifiedReturn[castedKey.value :: any] = castedValue.value :: any
			end
			return Maybe.Some(modifiedReturn)
		end
	)
end

return MapOf