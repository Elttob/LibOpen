--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local Predicate: Types.FnPredicate = function(predicate)
	return Def.new(
		`@predicate`,
		function(self, x)
			return predicate(x)
		end,
		function(self, x)
			if predicate(x) then
				return Maybe.Some(x)
			else
				return Maybe.None(`Type did not satisfy predicate`)
			end
		end
	)
end

return Predicate