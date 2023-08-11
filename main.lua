main = {}

json = require("json")
datbase = require("database")
config = fs.open("config.json", "r")
config = json.decode(config.readAll())


playerDetector = peripheral.find("playerDetector")
chatBox = peripheral.find("chatBox")



racing_player = nil
racing_player_data = nil



function main.run()

	database.init()





	-- everything is initiated.
	race()
end

function race()
	racing_player = wait_for_player()
	racing_player_data = database.get_player(player)
	chatBox.sendMessageToPlayer("You have subscribe to the race, it will start soon !", racing_player, "Race Plugin")
	sleep(2)
	chatBox.sendMessageToPlayer("Be ready on the starting line in 3...", racing_player, "Race Plugin")
	sleep(1)
	chatBox.sendMessageToPlayer("2...", racing_player, "Race Plugin")
	sleep(1)
	chatBox.sendMessageToPlayer("1...", racing_player, "Race Plugin")
	sleep(1)
	chatBox.sendMessageToPlayer("Gooo !!!", racing_player, "Race Plugin")

	-- todo
end


function wait_for_player()
	local event, username, device = os.pullEvent("playerClick")
	return username
end









return main