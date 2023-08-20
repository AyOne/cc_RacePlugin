-- run this script on a new computer to install the scripts
-- wget run https://raw.githubusercontent.com/AyOne/cc_RaceScript/main/RaceController/installer.lua

local branch = "dev"

local raw_updater = http.get("https://raw.githubusercontent.com/AyOne/cc_RaceScript/"..branch.."/RaceController/update.lua")
if raw_updater then
	local file = fs.open("updater.lua", "w")
	file.write(raw_updater.readAll())
	file.close()
	raw_updater.close()
end

local updater = require("updater")
updater.get_config(branch)
updater.get_all_files(branch)





local json = require("json")
local config = {}
local file = fs.open("config.json", "r")
config = json.decode(file.readAll())
file.close()


local ok = false
local default_track_name = ""
while not ok do
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1,1)
	print("Track name (case sensitive):")
	print("\n")
	local i = 1
	for k,v in pairs(config["race"]) do
		print(" -> "..k)
		i = i + 1
	end
	print("\n")
	print(">>")
	term.setCursorPos(4, i + 3)
	default_track_name = read()

	term.clear()
	term.setCursorPos(1,1)
	print("This computer is in charge of the track "..default_track_name..".")
	print("Is this correct ? (Y/n)")
	print("\n")
	print(">>")
	term.setCursorPos(4, 4)
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
file = fs.open("config.json", "w")
file.write(json.encode(config))
file.close()

os.setComputerLabel("Race Controller : "..default_track_name)

print("Installation complete. Rebooting...")
sleep(2)
os.reboot()