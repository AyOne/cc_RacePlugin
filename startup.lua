-- making sure all the files are up to date
if arg[1] == "update" then
	local update = require("update") or error("Could not load the update script")
	local branch = arg[2] or "dev"
	update.get_config(branch)
	update.get_all_files(branch)
end

-- running the main script
require("main").run()
