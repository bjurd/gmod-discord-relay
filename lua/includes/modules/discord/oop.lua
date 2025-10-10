module("oop", package.discord)

--- Creates a new object from a metatable
--- The metatable must have a __new function defined
--- @param Metatable table
--- @return table Object
function CreateFrom(Metatable)
	local Object = {}
	setmetatable(Object, Metatable)

	Object:__new()

	return Object
end

--- Creates a new object of the given type
--- @param Type string
--- @return table|nil Object
function CreateNew(Type)
	local Metatable = FindMetaTable(Format("Discord::%s", Type))

	if not istable(Metatable) then
		logging.Log(LOG_ERROR, "Failed to create object of non-existent metatable %s", Type)
		return nil
	end

	local Object = CreateFrom(Metatable)

	return Object
end

--- Creates and constructs a new object from a metatable
--- The metatable must have __new and __constr functions defined
--- @param Metatable table
--- @param Data table The data table to be passed into the constructor
--- @return table Object
function ConstructFrom(Metatable, Data)
	local Object = CreateFrom(Metatable)

	Object:__constr(Data)

	return Object
end

--- Creates a new object of the given type with the provided data
--- @param Type string
--- @param Data any
--- @return table|nil Object
function ConstructNew(Type, Data)
	local Object = CreateNew(Type)
	if not Object then return nil end

	if not isfunction(Object.__constr) then
		logging.Log(LOG_ERROR, "Failed to construct of non-constructable object %s", Type)
		return nil
	end

	Object:__constr(Data)

	return Object
end
