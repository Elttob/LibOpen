--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Types = require(Package.ty.Types)

local Untyped: Types.FnUntyped = function(def)
	return def
end

return Untyped