--[[
	This script will act as a database for the scoreboard and player data.

	the json structure of the scoreboard is as follow
	{
		<player_name> = {
			<track_name> = {
				start = <time>,
				<checkpointID> = <time>,
				<checkpointID+1> = <time>,
				...
				<checkpointID+n> = <time>,
				...
				finish = <time>
			}
		},
		...
	}

--]]
local database = {
	initalized = false,
}

local data_folder = "disk/"
local raw_data = "data.json"

local json = require("json")





function database.init()
	if database.initalized then
		return
	else
		database.initalized = true
	end
	-- Create the data folder if it doesn't exist
	if not fs.exists(data_folder) then
		fs.makeDir(data_folder)
	end

	-- Create the data file if it doesn't exist
	if not fs.exists(data_folder .. raw_data) then
		local file = fs.open(data_folder .. raw_data, "w")
		file.write("{}")
		file.close()
	end

	-- Load the data
	print("Loading data...")
	local file = fs.open(data_folder .. raw_data, "r")
	database.data = json.decode(file.readAll())
	file.close()
	print("data loaded")
end









function database.save()
	-- Save the scoreboard
	print("Saving data...")
	local file = fs.open(data_folder .. raw_data, "w")
	file.write(json.encode(database.data))
	file.close()
	print("data saved")
end

function database.get_data()
	return database.data
end

function database.get_player(name)
	return database.data[name]
end

function database.update_player_time(name, track_name, checkpoint, time)
	if not database.data[name] then
		database.data[name] = {}
	end
	if not database.data[name][track_name] then
		database.data[name][track_name] = {}
	end
	database.data[name][track_name][checkpoint] = time
end

function database.update_player_date(name, track_name, date)
	if not database.data[name] then
		database.data[name] = {}
	end
	if not database.data[name][track_name] then
		database.data[name][track_name] = {}
	end
	database.data[name][track_name]["date"] = date
end

function database.update_player_total_time_racing(name, track_name, total_time_racing)
	if not database.data[name] then
		database.data[name] = {}
	end
	if not database.data[name][track_name] then
		database.data[name][track_name] = {}
	end
	database.data[name][track_name]["total_time_racing"] = total_time_racing
end

function database.update_player_number_of_try(name, track_name, number_of_try)
	if not database.data[name] then
		database.data[name] = {}
	end
	if not database.data[name][track_name] then
		database.data[name][track_name] = {}
	end
	database.data[name][track_name]["number_of_try"] = number_of_try
end


return database