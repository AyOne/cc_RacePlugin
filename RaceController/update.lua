local json_file = "https://raw.githubusercontent.com/rxi/json.lua/master/json.lua"

local update = {}





-- get the config file and the json script
function update.get_config(branch)
	local github_url = "https://raw.githubusercontent.com/AyOne/cc_RaceScript/"..branch.."/RaceController/"
	local config_file = github_url.."config.json"

	print("Getting the config file from github...")
	local config = http.get(config_file) or error("Could not get the config file from github")
	print("Saving the config file...")
	if config then
		local file = fs.open("config.json", "w")
		file.write(config.readAll())
		file.close()
		config.close()
	end
	print("Config file saved.")
	print("Getting the json script from github...")
	local json = http.get(json_file) or error("Could not get the json script from github")
	print("Saving the json script...")
	if json then
		local file = fs.open("json.lua", "w")
		file.write(json.readAll())
		file.close()
		json.close()
	end
	print("Json script saved.")
end

-- get all the files from github
function update.get_all_files(branch)
	local github_url = "https://raw.githubusercontent.com/AyOne/cc_RaceScript/"..branch.."/RaceController/"
	print("Getting all the files from github...")
	local config_file = fs.open("config.json", "r")
	local json = require("json")
	local config = json.decode(config_file.readAll())
	config_file.close()
	for i, fileName in ipairs(config.files) do
		local file = http.get(github_url..fileName) or error("Could not get the file from github")
		if file then
			local localfile = fs.open(fileName, "w")
			localfile.write(file.readAll())
			localfile.close()
			file.close()
		end
	end
	print("All files saved.")
end


function update.ask_default_track()

	local json = require("json")
	local config_file = fs.open("config.json", "r")
	local config = json.decode(config_file.readAll())
	config_file.close()

	local ok = false
	local default_track_name = ""
	while not ok do
		term.setBackgroundColor(colors.black)
		term.clear()
		term.setCursorPos(1,1)
		print("Track name (case sensitive):")
		print("\n")
		for k,v in pairs(config["race"]) do
			print(" -> "..k)
		end
		print("\n")
		print(">>")
		local cx, cy = term.getCursorPos()
		term.setCursorPos(4, cy - 1)
		default_track_name = read()

		term.clear()
		term.setCursorPos(1,1)
		print("This computer is in charge of the track "..default_track_name..".")
		print("Is this correct ? (Y/n)")
		print("\n")
		print(">>")
		cx, cy = term.getCursorPos()
		term.setCursorPos(4, cy - 1)
		local answer = read()
		if answer == "y" or answer == "Y" or answer == "" then
			ok = true
		elseif answer == "n" or answer == "N" then
			ok = false
		else
			ok = false
		end
	end
	
	config["default_track_name"] = default_track_name
	config_file = fs.open("config.json", "w")
	config_file.write(json.encode(config))
	config_file.close()

	os.setComputerLabel("Race Controller : "..default_track_name)
end
return update