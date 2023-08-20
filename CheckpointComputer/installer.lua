-- run this script on a new computer to install the scripts
-- wget run https://raw.githubusercontent.com/AyOne/cc_RaceScript/main/CheckpointComputer/installer.lua

local branch = "dev"

local raw_startup = http.get("https://raw.githubusercontent.com/AyOne/cc_RaceScript/"..branch.."/CheckpointComputer/startup.lua")
if raw_startup then
	local file = fs.open("startup.lua", "w")
	file.write(raw_startup.readAll())
	file.close()
	raw_startup.close()
end

local raw_json = http.get("https://raw.githubusercontent.com/rxi/json.lua/master/json.lua")
if raw_json then
	local file = fs.open("json.lua", "w")
	file.write(raw_json.readAll())
	file.close()
	raw_json.close()
end

local ok = false
local checkpoint_name = ""
while not ok do
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1,1)
	print("Checkpoint name (case sensitive):")
	print(" -- start")
	print(" -- <checkpoint index [1-99]>")
	print(" -- finish")
	print("\n")
	print(">>")
	local cx, cy = term.getCursorPos()
	term.setCursorPos(4, cy - 1)
	checkpoint_name = read()

	term.clear()
	term.setCursorPos(1,1)
	print("This computer is in charge of checkpoint "..checkpoint_name..".")
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

os.setComputerLabel("Checkpoint controller : "..checkpoint_name)

local json = require("json")

local config = {
	["checkpoint_name"] = checkpoint_name
}
local file = fs.open("config.json", "w")
file.write(json.encode(config))
file.close()

print("Installation complete. Rebooting...")
sleep(2)
os.reboot()