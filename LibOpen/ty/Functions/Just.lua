--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local Just: Types.FnJust = function(literal, type)
	return Def.new(
		type or tostring(literal),
		function(self, x)
			return rawequal(x, literal)
		end,
		function(self, x)
			if rawequal(x, literal) then
				return Maybe.Some(x)
			else
				return Maybe.None(`{self.NotOfTypeError}\n...because only {tostring(literal)} is accepted, but received {tostring(x)}`)
			end
		end
	)
end

return Just