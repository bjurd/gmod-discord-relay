relay.detours = relay.detours or {}
local detours = relay.detours

detours.Store = detours.Store or {}
detours.Meta = detours.Meta or { __index = _G }

--- Finds a detour store datatable
--- @param Key function The function to search, either the old or new
--- @return table|nil
function detours.Find(Key)
	local Count = #detours.Store
	for i = 1, Count do
		local DataTable = detours.Store[i]

		if DataTable.Old == Key or DataTable.New == Key then
			return DataTable
		end
	end

	return nil
end

--- Creates a detour of a function
--- @param Old function The original function to detour
--- @param New function The new function
--- @return function Createed The created detour function, in the detour fenv
function detours.Create(Old, New)
	local Found = detours.Find(Old)

	if Found ~= nil then
		discord.logging.Log(LOG_WARNING, "Detour is being re-created! Removing old!")
		detours.Destroy(Found.Old)
	end

	local fenv = { __original = Old }
	setmetatable(fenv, detours.Meta)

	local DataTable = {}
	DataTable.Old = Old
	DataTable.New = New
	DataTable.fenv = fenv
	DataTable.Index = table.insert(detours.Store, DataTable) -- This is not the most optimal way of storing these, but detours aren't created/destroyed very often

	return setfenv(New, fenv)
end

--- Removes a detour of a function
--- @param Key function The function to search, either the old or new
--- @return function Old The old function, returns the passed in Key if not found
function detours.Destroy(Key)
	local DataTable = detours.Find(Key)

	if DataTable == nil then
		return Key
	end

	table.remove(detours.Store, DataTable.Index)

	return DataTable.Old
end
