--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local IntoString: Types.FnIntoString = function(innerDef)
	return Def.new(
		`@tostring({innerDef.ExpectsType})`,
		function(self, x)
			local Cast = innerDef:Cast(x)
			return Cast.some and tostring(Cast.value) ~= nil
		end,
		function(self, x)
			local result = innerDef:Cast(x)
			if not result.some then
				return Maybe.None(`{self.NotOfTypeError}\n...because of the inner type: {result.reason}`)
			else
				local str = tostring(result.value)
				if str == nil then
					return Maybe.None(`{self.NotOfTypeError}\n...because it couldn't be turned into a string`)
				else
					return Maybe.Some(str)
				end
			end
		end
	)
end

return IntoString