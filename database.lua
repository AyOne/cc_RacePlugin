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
database = {
	initalized = false,
}

data_folder = "disk/",
raw_data = "data.json"

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

function database.update_player(name, track_name, checkpoint, time)
	if not database.data[name] then
		database.data[name] = {}
	end
	if not database.data[name][track_name]
		database.data[name][track_name] = {}
	end
	database.data[name][track_name][checkpoint] = time
end

return database