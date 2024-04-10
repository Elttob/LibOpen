--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local Optional: Types.FnOptional = function<T>(innerDef: Types.Def)
	return Def.new(
		`({innerDef.ExpectsType})?`,
		function(self, x)
			if x == nil then
				return true
			end
			return innerDef:Matches(x)
		end,
		function(self, x)
			if x == nil then
				return Maybe.Some(nil) :: Maybe.Maybe<T?>
			end
			local result = innerDef:Cast(x)
			return if result.some then result else Maybe.None(`{self.NotOfTypeError}\n...because of the inner type: {result.reason}`)
		end
	)
end

return Optional