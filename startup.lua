-- making sure all the files are up to date
local update = require("update") or error("Could not load the update script")
update.get_config()
update.get_all_files()

-- running the main script
local main = require("main") or error("Could not load the main script")
main.run()
