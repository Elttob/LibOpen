--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local Nicknamed: Types.FnNicknamed = function<T>(innerDef, newName)
	return Def.new(
		newName,
		innerDef.Matches,
		innerDef.Cast
	)
end

return Nicknamed