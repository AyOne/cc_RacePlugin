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

	local start_time = os.time()
	local current_time = start_time
	local current_checkpoint = 0
	while true do
		checkpoint_to_reach = nil
		if (current_checkpoint == 0) then
			racing_player_data["checkpoints"]["start"]
		elseif (current_checkpoint < #config["checkpoints"]) then
			checkpoint_to_reach = racing_player_data["checkpoints"][current_checkpoint]
		else
			checkpoint_to_reach = racing_player_data["checkpoints"]["finish"]
		end

		if (checkpoint_to_reach ~= nil) then
			local pos = playerDetector.getPlayerPos(racing_player)
			-- check if player pos are in between checkpoint_to_reach.from and checkpoint_to_reach.to

			if (pos.x >= checkpoint_to_reach.from.x and pos.x <= checkpoint_to_reach.to.x) then
				if (pos.y >= checkpoint_to_reach.from.y and pos.y <= checkpoint_to_reach.to.y) then
					if (pos.z >= checkpoint_to_reach.from.z and pos.z <= checkpoint_to_reach.to.z) then
						-- player is in the checkpoint
						current_checkpoint = current_checkpoint + 1
						racing_player_data["checkpoints"][current_checkpoint] = current_time - start_time
						-- database.update_player(racing_player, racing_player_data)
					end
				end
			end
		end
	end
end


function wait_for_player()
	local event, username, device = os.pullEvent("playerClick")
	return username
end









return main