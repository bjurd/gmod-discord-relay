module("cache", package.discord)

Data = {}

--- Gets the entire cache data table
--- @return table
function GetData()
	return Data
end

--- Creates a timed cache table that will be removed automatically
--- @param Key string
--- @param Life number Lifetime in seconds. This is independant of game time, as it uses SysTime
--- @return table
function CreateTimed(Key, Life)
	local DataTable = {}

	Data[Key] = {
		DataTable = DataTable,
		Life = Life,
		Created = SysTime()
	}

	return DataTable
end

--- Fetches a table from the datacache, nil if it doesn't exist or expired
--- @param Key string
--- @return table|nil
function Get(Key)
	local TableData = Data[Key]
	if not istable(TableData) then return nil end

	local CurrentTime = SysTime()
	local Elapsed = CurrentTime - TableData.Created

	if Elapsed > TableData.Life then
		Data[Key] = nil
		return nil
	end

	return TableData.DataTable
end
