main = {}

json = require("json")
datbase = require("database")
config = fs.open("config.json", "r")
config = json.decode(config.readAll())


playerDetector = peripheral.find("playerDetector")
chatBox = peripheral.find("chatBox")


function main.run()

	database.init()

	while true do
		local event, username, fromDim, toDim = os.pullEvent("playerChangedDimension")
		chatBox.sendMessage(username.." changed dimension from "..fromDim.." to "..toDim, "sneeky spy")
	end





	-- everything is initiated.
	race()
end

function race()
	local player = wait_for_player()
	local player_data = database.get_player(player)

end


function wait_for_player()
	local event, username, device = os.pullEvent("playerClick")
	return username
end






return main