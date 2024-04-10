--!strict
-- From 'ty' by Elttob, MIT license

local Package = script.Parent.Parent
local Maybe = require(Package.Maybe)

export type Def = DefNoMethods & Methods
type DefNoMethods = {
	ExpectsType: string,
	NotOfTypeError: string,
	Matches: (self: Def, unknown) -> boolean,
	Cast: (self: Def, unknown) -> Maybe.Maybe<unknown>
}

export type Constants = {
	Unknown: Def,
	Never: Def,

	Number: Def,
	Boolean: Def,
	String: Def,
	Thread: Def,
	Table: Def,
	Function: Def,

	True: Def,
	False: Def,
	Nil: Def
}

export type Methods = {
	Predicate: FnPredicate,
	Typeof: FnTypeof,
	Just: FnJust,
	Optional: FnOptional,
	IgnoreInvalid: FnIgnoreInvalid,
	Or: FnOr,
	And: FnAnd,
	MapOf: FnMapOf,
	Array: FnArray,
	Struct: FnStruct,
	Tuple: FnTuple,
	IntoTagged: FnIntoTagged,
	IntoString: FnIntoString,
	IntoNumber: FnIntoNumber,
	IntoDefault: FnIntoDefault,
	Retype: FnRetype,
	Untyped: FnUntyped,
	Nicknamed: FnNicknamed,
	CastOrError: FnCastOrError
}

export type FnPredicate = (
	predicate: (unknown) -> boolean
) -> Def

export type FnTypeof = (
	typeString: string
) -> Def

export type FnJust = (
	literal: unknown,
	type: string?
) -> Def

export type Optional = Def
export type FnOptional = (
	innerDef: Def
) -> Optional

export type IgnoreInvalid = Def
export type FnIgnoreInvalid = (
	innerDef: Def
) -> IgnoreInvalid

export type Or = Def
export type FnOr = (
	first: Def,
	last: Def
) -> Or


export type And = Def
export type FnAnd = (
	first: Def,
	last: Def
) -> And

export type MapOf = Def
export type FnMapOf = (
	keys: Def,
	values: Def
) -> MapOf


export type Array = Def
export type FnArray = <V>(
	values: Def
) -> Array

-- FUTURE: suboptimal type for this; try keyof when it launches?
export type Struct = Def
export type FnStruct = (
	options: {
		exhaustive: boolean
	},
	object: {[string]: Def}
) -> Struct

export type Tuple = Def
export type FnTuple = (
	options: {
		exhaustive: boolean
	},
	tuple: {[number]: Def}
) -> Tuple

export type IntoTagged = Def
export type FnIntoTagged = (
	innerDef: Def,
	tag: unknown
) -> IntoTagged

export type FnIntoString = (
	innerDef: Def
) -> Def

export type FnIntoNumber = (
	innerDef: Def,
	base: number?
) -> Def

export type FnIntoDefault = (
	innerDef: Def,
	defaultValue: any
) -> Def

export type FnRetype = (
	def: Def
) -> Def

export type FnUntyped = (
	def: Def
) -> Def

export type FnNicknamed = (
	innerDef: Def,
	newName: string
) -> Def

export type FnCastOrError = (
	def: Def,
	x: unknown
) -> unknown

return nil