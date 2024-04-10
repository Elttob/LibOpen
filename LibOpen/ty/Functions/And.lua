--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local And: Types.FnAnd = function(first, last)
	return Def.new(
		`({first.ExpectsType}) & ({last.ExpectsType})`,
		function(self, x)
			return first:Matches(x) and last:Matches(x)
		end,
		function(self, x)
			local result = first:Cast(x)
			if not result.some then
				return Maybe.None(`{self.NotOfTypeError}\n...because of the first & type: {result.reason}`)
			end
			local result = last:Cast(result.value)
			if not result.some then
				return Maybe.None(`{self.NotOfTypeError}\n...because of the last & type: {result.reason}`)
			end
			return result
		end
	)
end

return And