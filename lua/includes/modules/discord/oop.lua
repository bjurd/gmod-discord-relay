module("oop", package.discord)

--- Creates a new object of the given type
--- @param Type string
--- @return table|nil Object
function CreateNew(Type)
	local Metatable = FindMetaTable(Format("Discord::%s", Type))

	if not istable(Metatable) then
		logging.Log(LOG_ERROR, "Failed to create object of non-existent metatable %s", Type)
		return nil
	end

	local Object = {}
	setmetatable(Object, Metatable)

	if Metatable and isfunction(Metatable.__new) then
		-- LuaLS goes retarded if I don't have the 'Metatable and' because it can't
		-- see the check above :/
		Object:__new()
	end

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
