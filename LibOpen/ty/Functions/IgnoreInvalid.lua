--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local IgnoreInvalid: Types.FnIgnoreInvalid = function<T>(innerDef: Types.Def)
	return Def.new(
		`@ignoreInvalid({innerDef.ExpectsType})`,
		function(self, x)
			return true
		end,
		function(self, x)
			local result = innerDef:Cast(x)
			return if result.some then result else Maybe.Some(nil)
		end
	)
end

return IgnoreInvalid