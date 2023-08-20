-- making sure all the files are up to date
if arg[1] == "update" then
	local update = require("update") or error("Could not load the update script")
	local branch = arg[2] or "main"
	update.get_config(branch)
	update.get_all_files(branch)
	update.ask_default_track()
end

-- running the main script
function Run()
	local json = require("json")
	local database = require("database")
	local scoreboard = require("scoreboard")
	local race = require("race")

	database.init()
	scoreboard.load(database)

	local config_file = fs.open("config.json", "r")
	local config = json.decode(config_file.readAll())
	config_file.close()
	
	local track = config["default_track_name"]
	race.init(track)

	while true do
		scoreboard.display(track, "idle")
		race.start()
	end
end


Run()