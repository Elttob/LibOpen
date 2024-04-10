--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local Tuple: Types.FnTuple = function<V>(options, tuple)
	local expectTypeParts = {}
	for key, value in tuple do
		assert(typeof(key) == "number", "Tuple requires numeric arguments")
		table.insert(expectTypeParts, `[{key}]: {value.ExpectsType}`)
	end
	return Def.new(
		`\{{table.concat(expectTypeParts, ", ")}}`,
		function(self, x)
			if typeof(x) ~= "table" then
				return false
			end
			local x = x :: {[unknown]: unknown}
			for key, value in pairs(x) do
				if typeof(key) ~= "number" then
					return false
				end
				local key = key :: number
				local innerDef = tuple[key]
				if innerDef == nil or not innerDef:Matches(value) then
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
			for key, innerDef in pairs(tuple) do
				local value = x[key]
				local castedValue = innerDef:Cast(value)
				if not castedValue.some then
					return Maybe.None(`{self.NotOfTypeError}\n...because of the value at key {tostring(key)}: {castedValue.reason}`)
				end
				modifiedReturn[key] = castedValue.value :: any
			end
			for key in pairs(x) do
				if typeof(key) ~= "number" then
					return Maybe.None(`{self.NotOfTypeError}\n...because {tostring(key)} isn't a valid tuple key`)
				elseif options.exhaustive and tuple[key] == nil then
					return Maybe.None(`{self.NotOfTypeError}\n...because the tuple is exhaustive and {tostring(key)} isn't included`)
				end
			end
			return Maybe.Some(modifiedReturn)
		end
	)
end

return Tuple