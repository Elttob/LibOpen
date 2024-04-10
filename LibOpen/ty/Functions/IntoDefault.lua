--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local IntoDefault: Types.FnIntoDefault = function(innerDef, defaultValue)
	return Def.new(
		`\@default<{defaultValue}>({innerDef.ExpectsType})`,
		function(self, x)
			return x == nil or innerDef:Matches(x)
		end,
		function(self, x)
			if x == nil then
				return Maybe.Some(defaultValue)
			else
				return innerDef:Cast(x)
			end
		end
	)
end

return IntoDefault