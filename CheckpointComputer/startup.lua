local json = require("json")

local config_file = fs.open("config.json", "r")
local config = json.decode(config_file.readAll())
config_file.close()

local checkpoint_name = config.checkpoint_name

local modem = peripheral.find("modem") or error("No modem found")
local speaker = peripheral.find("speaker") or nil
modem.open(323)


function Wait_for_event()
	while true do
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
		message = json.decode(message)
		if message["to"] == checkpoint_name then
			Behavior(message["event_name"], message["event_data"])
		end
	end
end


function Behavior(event_name, event_data)
	-- will trigger then the player pass the checkpoint
	if (event_name == "play_sound") then
		if speaker then
			local instrument = event_data["instrument"]
			local volume = event_data["volume"]
			local pitch = event_data["pitch"]
			speaker.playNote(instrument, volume, pitch)
		end
	elseif (event_name == "redstone_change") then
		local side = event_data["side"]
		local strength = event_data["strength"]
		redstone.setAnalogOutput(side, strength)
	end
end

Wait_for_event()