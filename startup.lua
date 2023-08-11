-- making sure all the files are up to date
if args[1] == "update" then
	local update = require("update") or error("Could not load the update script")
	update.get_config()
	update.get_all_files()
	return
end

-- running the main script
local main = require("main") or error("Could not load the main script")
main.run()
