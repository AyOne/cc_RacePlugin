-- making sure all the files are up to date
if arg[1] == "update" then
	local update = require("update") or error("Could not load the update script")
	update.get_config()
	update.get_all_files()
end

-- running the main script
local main = require("main") or error("Could not load the main script")
main.run(arg[2])
