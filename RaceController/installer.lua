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
updater.ask_default_track()


term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)
print("Installation complete. Rebooting...")
sleep(2)
os.reboot()