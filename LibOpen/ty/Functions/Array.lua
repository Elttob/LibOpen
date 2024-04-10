--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

-- TODO: ensure arrays have no holes, and empty arrays are allowed
local Array: Types.FnArray = function<V>(values: Types.Def)
	return Def.new(
		`\{{values.ExpectsType}}`,
		function(self, x)
			if typeof(x) ~= "table" then
				return false
			end
			local x = x :: {[unknown]: unknown}
			local expected = #x
			local encountered = 0
			for key, value in pairs(x) do
				encountered += 1
				if encountered > expected or typeof(key) ~= "number" or not values:Matches(value) then
					return false
				end
			end
			return true
		end,
		function(self, x)
			if typeof(x) ~= "table" then
				return Maybe.None(`{self.NotOfTypeError}\n...because {tostring(x)} isn't an array`)
			end
			local x = x :: {[unknown]: unknown}
			local modifiedReturn = {}
			local expected = #x
			local encountered = 0
			for key, value in pairs(x) do
				encountered += 1
				if encountered > expected or typeof(key) ~= "number" then
					return Maybe.None(`{self.NotOfTypeError}\n...because {tostring(key)} isn't a valid array index`)
				end
				local castedValue = values:Cast(value)
				if not castedValue.some then
					return Maybe.None(`{self.NotOfTypeError}\n...because, at key {tostring(key)}: {castedValue.reason}`)
				end
				if castedValue ~= nil then
					table.insert(modifiedReturn, castedValue.value :: any)
				end
			end
			return Maybe.Some(modifiedReturn)
		end
	)
end

return Array