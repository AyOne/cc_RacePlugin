--[[
	This script will act as a database for the scoreboard and player data.

	the json structure of the scoreboard is as follow
	{
		<player_name> = {
			<checkpointID> = <time>,
			<checkpointID+1> = <time>,
			...
			<checkpointID+n> = <time>,
			...
			arrival = <time>
		},
		...
	}

--]]
database = {
	data_folder = "disk/data/",
	raw_scoreboard = "scoreboard.json",
}

local json = require("json")








function database.init()
	-- Create the data folder if it doesn't exist
	if not fs.exists(database.data_folder) then
		fs.makeDir(database.data_folder)
	end

	-- Create the scoreboard file if it doesn't exist
	if not fs.exists(database.data_folder .. database.raw_scoreboard) then
		local file = fs.open(database.data_folder .. database.raw_scoreboard, "w")
		file.write("{}")
		file.close()
	end

	-- Load the scoreboard
	print("Loading scoreboard...")
	local file = fs.open(database.data_folder .. database.raw_scoreboard, "r")
	database.scoreboard = json.decode(file.readAll())
	file.close()
	print("Scoreboard loaded")
end

function database.save()
	-- Save the scoreboard
	print("Saving scoreboard...")
	local file = fs.open(database.data_folder .. database.raw_scoreboard, "w")
	file.write(json.encode(database.scoreboard))
	file.close()
	print("Scoreboard saved")
end

function database.get_scoreboard()
	return database.scoreboard
end

function database.get_player(name)
	return database.scoreboard[name]
end

function database.update_player(name, checkpoint, time)
	if not database.scoreboard[name] then
		database.scoreboard[name] = {}
	end
	database.scoreboard[name][checkpoint] = time
end

function database.sort_scoreboard(checkpoint)
	local scoreboard = {}
	for name, player in pairs(database.scoreboard) do
		if player[checkpoint] then
			table.insert(scoreboard, {name, player[checkpoint]})
		end
	end
	table.sort(scoreboard, function(a, b) return a[2] < b[2] end)
	return scoreboard
end


return database