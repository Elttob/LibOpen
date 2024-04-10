--!strict
-- Radium - Luau interface to the Roblox API Dump
-- (c) Daniel P H Fox, licensed under MIT

local HttpService = game:GetService("HttpService")

local API_DUMP_URL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json"

export type Dump = {
	Classes: {DumpClass},
	Enums: {DumpEnum},
	Version: number
}

export type DumpClass = {
	Name: string,
	Members: {DumpClassMember},
	Tags: {string}?,
	Superclass: string,
	MemoryCategory: string
}

export type DumpClassMember = DumpClassProperty
	| DumpClassFunction
	| DumpClassEvent
	| DumpClassCallback

export type DumpClassProperty = {
	MemberType: "Property",
	Name: string,
	Tags: {string}?,
	ValueType: DumpType,
	Security: {
		Read: DumpSecurity,
		Write: DumpSecurity
	},
	Serialization: {
		CanLoad: boolean,
		CanSave: boolean
	},
	ThreadSafety: DumpThreadSafety,
	Category: string
}

export type DumpClassFunction = {
	MemberType: "Function",
	Name: string,
	Tags: {string}?,
	Parameters: {DumpFunctionParameter},
	ReturnType: DumpType,
	Security: DumpSecurity,
	ThreadSafety: DumpThreadSafety
}

export type DumpClassEvent = {
	MemberType: "Event",
	Name: string,
	Tags: {string}?,
	Parameters: {DumpFunctionParameter},
	Security: DumpSecurity,
	ThreadSafety: DumpThreadSafety
}

export type DumpClassCallback = {
	MemberType: "Callback",
	Name: string,
	Tags: {string}?,
	Parameters: {DumpFunctionParameter},
	ReturnType: DumpType,
	Security: DumpSecurity,
	ThreadSafety: DumpThreadSafety
}

export type DumpFunctionParameter = {
	Name: string,
	Type: DumpType
}

export type DumpType = {
	Name: string,
	Category: string
}

export type DumpSecurity = "None"
	| "LocalUserSecurity"
	| "NotAccessibleSecurity"
	| "PluginSecurity"
	| "RobloxScriptSecurity"
	| "RobloxSecurity"

export type DumpThreadSafety = "Unsafe"
	| "ReadSafe"
	| "Safe"

export type DumpEnum = {
	Name: string,
	Items: {DumpEnumItem}
}

export type DumpEnumItem = {
	Name: string,
	Value: number
}

local Radium = {}

Radium.dump = nil :: Dump?

export type DownloadResult = {
	ok: true
} | {
	ok: false,
	id: "httpFail",
	error: string,
	humanReadable: string
} | {
	ok: false,
	id: "jsonFail",
	error: string,
	humanReadable: string
}

function Radium.download(): DownloadResult
	local httpOK, httpResult = pcall(HttpService.GetAsync, HttpService, API_DUMP_URL)
	if not httpOK then
		return {
			ok = false,
			id = "httpFail",
			error = httpResult,
			humanReadable = `HTTP error while loading API dump; {httpResult}`
		}
	end

	local jsonOK, jsonResult = pcall(HttpService.JSONDecode, HttpService, httpResult)
	if not jsonOK then
		return {
			ok = false,
			id = "jsonFail",
			error = jsonResult,
			humanReadable = "Could not parse API dump as JSON"
		}
	end

	-- We like to live type-unsafely.
	Radium.dump = (jsonResult :: any) :: Dump?

	-- Luau doesn't give our caches table an indexer. Ugh.
	for _, cache in pairs(Radium.caches) do
		table.clear(cache)
	end

	return {
		ok = true
	}
end

function Radium.unload()
	Radium.dump = nil :: Dump?

	for _, cache in Radium.caches do
		table.clear(cache)
	end
end

Radium.caches = {
	listClassNames = nil :: {string}?,
	findClass = {} :: {[string]: {value: DumpClass?}},
	findSubclassNames = {} :: {[string]: {value: {DumpClass}}},
	findAllInheritedMembers = {} :: {[string]: {value: {[string]: DumpClassMember}?}}
}

function Radium.listClassNames(
	saveToCache: boolean?
)
	assert(Radium.dump ~= nil, "Call Radium.download() to get a copy of the Roblox API first.")
	if Radium.caches.listClassNames ~= nil then
		return Radium.caches.listClassNames
	end

	local list = {}
	for _, class in Radium.dump.Classes do
		table.insert(list, class.Name)
	end
	if saveToCache ~= false then
		Radium.caches.listClassNames = list
	end
	return list
end

function Radium.findClass(
	className: string,
	saveToCache: boolean?
): DumpClass?
	assert(Radium.dump ~= nil, "Call Radium.download() to get a copy of the Roblox API first.")
	local cached = Radium.caches.findClass[className]
	if cached ~= nil then
		return cached.value
	end
	for _, class in Radium.dump.Classes do
		if class.Name == className then
			if saveToCache ~= false then
				Radium.caches.findClass[className] = { value = class }
			end
			return class
		end
	end
	if saveToCache ~= false then
		Radium.caches.findClass[className] = { value = nil }
	end
	return nil
end

function Radium.findSubclasses(
	superclassName: string,
	saveToCache: boolean?
): {DumpClass}
	assert(Radium.dump ~= nil, "Call Radium.download() to get a copy of the Roblox API first.")
	local cached = Radium.caches.findSubclassNames[superclassName]
	if cached ~= nil then
		return cached.value
	end
	local found = {}
	for _, class in Radium.dump.Classes do
		if class.Superclass == superclassName then
			table.insert(found, class)
		end
	end
	if saveToCache ~= false then
		Radium.caches.findSubclassNames[superclassName] = { value = found }
	end
	return found
end

function Radium.findAllInheritedMembers(
	className: string,
	saveToCache: boolean?
): {[string]: DumpClassMember}?
	assert(Radium.dump ~= nil, "Call Radium.download() to get a copy of the Roblox API first.")
	local cached = Radium.caches.findAllInheritedMembers[className]
	if cached ~= nil then
		return cached.value
	end

	local classAncestry = {} :: {DumpClass}
	do
		local current = Radium.findClass(className, saveToCache)
		if current == nil then
			if saveToCache ~= false then
				Radium.caches.findAllInheritedMembers[className] = { value = nil }
			end
			return nil
		end
		while current ~= nil and current.Superclass ~= "<<<ROOT>>>" do
			table.insert(classAncestry, current)
			current = Radium.findClass(current.Superclass, saveToCache)
		end
	end

	local members = {}
	for index = #classAncestry, 1, -1 do
		for _, member in classAncestry[index].Members do
			members[member.Name] = member
		end
	end

	if saveToCache ~= false then
		Radium.caches.findAllInheritedMembers[className] = { value = members }
	end
	return members
end

return Radium