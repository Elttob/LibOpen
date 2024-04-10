--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local Or: Types.FnOr = function<F, L>(first: Types.Def, last: Types.Def)
	return Def.new(
		`{first.ExpectsType} | {last.ExpectsType}`,
		function(self, x)
			return first:Matches(x) or last:Matches(x)
		end,
		function(self, x)
			local firstResult = first:Cast(x)
			if firstResult.some then
				return (firstResult :: any) :: Maybe.Maybe<F | L>
			end
			local lastResult = last:Cast(x)
			return if lastResult.some then lastResult else Maybe.None(`{self.NotOfTypeError}\n...because neither inner type fits:\nFirst type: {firstResult.reason}\nSecond type: {lastResult.reason}`)
		end
	)
end

return Or