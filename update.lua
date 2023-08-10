-- update the scritp from github
github_branch = "dev"
github_url = "https://raw.githubusercontent.com/AyOne/cc_RacePlugin/"..github_branch.."/"
config_file = github_url.."config.json"
json_file = "https://raw.githubusercontent.com/rxi/json.lua/master/json.lua"




local update = {}





-- get the config file and the json script
function update.get_config()
	local config = http.get(config_file) or error("Could not get the config file from github")
	local json = http.get(json_file) or error("Could not get the json script from github")
	if config then
		local file = fs.open("config.json", "w")
		file.write(config.readAll())
		file.close()
		config.close()
	end
	if json then
		local file = fs.open("json.lua", "w")
		file.write(json.readAll())
		file.close()
		json.close()
	end
end

-- get all the files from github
function update.get_all_files()
	local config = fs.open("config.json", "r")
	local json = require("json")
	local config = json.decode(config.readAll())
	for i, file in ipairs(config.files) do
		local file = http.get(github_url..file) or error("Could not get the file from github")
		if file then
			local file = fs.open(file, "w")
			file.write(file.readAll())
			file.close()
			file.close()
		end
	end
end

return update