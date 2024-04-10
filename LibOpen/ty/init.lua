--!strict
--!nolint LocalShadow
-- ty (Elttob Suite monorepo edition - no static types)
-- (c) Daniel P H Fox, licensed under MIT

local Package = script.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

export type Def = Types.Def
export type Constants = Types.Constants
export type Methods = Types.Methods
export type Optional = Types.Optional
export type Or = Types.Or
export type And = Types.And
export type MapOf = Types.MapOf
export type Array = Types.Array
export type Struct = Types.Struct
export type IntoTagged = Types.IntoTagged

-- TODO: need methods to limit table size and depth
-- TODO: need methods to handle cyclic data
local methods: Types.Methods = {
	Predicate = require(Package.ty.Functions.Predicate),
	Typeof = require(Package.ty.Functions.Typeof),
	Just = require(Package.ty.Functions.Just),
	Optional = require(Package.ty.Functions.Optional),
	IgnoreInvalid = require(Package.ty.Functions.IgnoreInvalid),
	Or = require(Package.ty.Functions.Or),
	And = require(Package.ty.Functions.And),
	MapOf = require(Package.ty.Functions.MapOf),
	Array = require(Package.ty.Functions.Array),
	Struct = require(Package.ty.Functions.Struct),
	Tuple = require(Package.ty.Functions.Tuple),
	IntoTagged = require(Package.ty.Functions.IntoTagged),
	IntoString = require(Package.ty.Functions.IntoString),
	IntoNumber = require(Package.ty.Functions.IntoNumber),
	IntoDefault = require(Package.ty.Functions.IntoDefault),
	Retype = require(Package.ty.Functions.Retype),
	Untyped = require(Package.ty.Functions.Untyped),
	Nicknamed = require(Package.ty.Functions.Nicknamed),
	CastOrError = require(Package.ty.Functions.CastOrError)
}
Def.methodMeta.__index = methods

local constants: Types.Constants = {
	Unknown = Def.new(
		"unknown",
		function(self, x) return true end,
		function(self, x) return Maybe.Some(x) end
	),
	Never = Def.new(
		"never",
		function(self, x) return false end,
		function(self, x) return Maybe.None(self.NotOfTypeError) end
	),

	Number = methods.Typeof("number"),
	Boolean = methods.Typeof("boolean"),
	String = methods.Typeof("string"),
	Thread = methods.Typeof("thread"),
	Table = methods.Typeof("table"),
	Function = methods.Typeof("function"),
	
	True = methods.Just(true) :: any,
	False = methods.Just(false) :: any,
	Nil = methods.Just(nil)
}

local ty: Types.Methods & Types.Constants = setmetatable(constants, Def.methodMeta) :: any
return ty