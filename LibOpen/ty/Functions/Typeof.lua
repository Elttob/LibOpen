--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local Typeof: Types.FnTypeof = function(typeString)
	return Def.new(
		typeString,
		function(self, x)
			return typeof(x) == typeString
		end,
		function(self, x)
			if typeof(x) == typeString then
				return Maybe.Some(x)
			else
				return Maybe.None(`{self.NotOfTypeError}\n...because {tostring(x)} doesn't have typeof() == {typeString}`)
			end
		end
	)
end

return Typeof