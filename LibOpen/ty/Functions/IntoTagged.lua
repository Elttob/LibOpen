--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local IntoTagged: Types.FnIntoTagged = function(innerDef, tag)
	return Def.new(
		`\@tagged<{tag}>({innerDef.ExpectsType})`,
		function(self, x)
			return innerDef:Matches(x)
		end,
		function(self, x)
			local result = innerDef:Cast(x)
			if not result.some then
				return Maybe.None(`{self.NotOfTypeError}\n...because of the inner type: {result.reason}`)
			else
				local value = 
					if typeof(result.value) == "table"
					then table.clone(result.value :: any) :: any
					else {value = result.value}
				value.__tag = tag
				return Maybe.Some(value)
			end
		end
	)
end

return IntoTagged