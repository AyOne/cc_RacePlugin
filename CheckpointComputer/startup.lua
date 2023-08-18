local json = require("json")

local config_file = fs.open("config.json", "r")
local config = json.decode(config_file.readAll())
config_file.close()

local checkpoint_name = config.checkpoint_name

local modem = peripheral.find("modem") or error("No modem found")
local speaker = peripheral.find("speaker") or nil
modem.open(323)


function wait_for_event()
	while true do
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
		message = json.decode(message)
		if message["to"] == checkpoint_name then
			behavior(message["event_name"], message["event_data"])
		end
	end
end


function behavior(event_name, event_data)
	-- will trigger then the player pass the checkpoint
	if (event_name == "played_passed") then
		if speaker then
			if (checkpoint_name ~- "finish") then
				speaker.playNote("bell", 3, 20)
			elseif (checkpoint_name == "finish") then
				speaker.playNote("bell", 3, 24)
				sleep(0.2)
				speaker.playNote("bell", 3, 24)
				sleep(0.2)
				speaker.playNote("bell", 3, 24)
			end
		end
	-- will trigger then the player pass the previous checkpoint
	elseif (event_name == "next_checkpoint") then

	end
end

wait_for_event()