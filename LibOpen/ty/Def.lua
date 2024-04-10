--!strict
-- ty (Elttob Suite monorepo edition - no static types)
-- By Daniel P H Fox, licensed under MIT

local Package = script.Parent.Parent
local Types = require(Package.ty.Types)
local Maybe = require(Package.Maybe)

local Def = {}

Def.methodMeta = {__index = nil :: Types.Methods?}

local function linkMethods(
	def
): Types.Def
	setmetatable(def, Def.methodMeta)
	return def :: any
end

function Def.new<CastTo>(
	expectsType: string,
	matches: (self: Types.Def, unknown) -> boolean,
	cast: (self: Types.Def, unknown) -> Maybe.Maybe<any>
): Types.Def
	local def = {}
	def.Matches = matches
	def.ExpectsType = expectsType
	def.NotOfTypeError = `Type is not {expectsType}`
	def.Cast = cast
	return linkMethods(def)
end

return Def