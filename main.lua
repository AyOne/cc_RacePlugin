main = {}

json = require("json")
datbase = require("database")
config = fs.open("config.json", "r")
config = json.decode(config.readAll())


playerDetector = peripheral.find("playerDetector")
chatBox = peripheral.find("chatBox")
monitor = peripheral.find("monitor")
monitor.setTextScale(0.5)
monitor.clear()
cur_x, cur_y = 1,1
monitor.setCursorPos(1,1)


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
	chatBox.sendMessageToPlayer("Be ready on the starting line in 10...", racing_player, "Race Plugin")
	for i=1, 9 do
		sleep(1)
		charBox.sendMessageToPlayer(10 - i.."..."m racing_player, "Race Plugin")
	end
	sleep(1)
	chatBox.sendMessageToPlayer("Gooo !!!", racing_player, "Race Plugin")

	local start_time = os.time()
	local current_time = start_time
	local current_checkpoint = 0
	checkpoint_to_reach = build_checkpoint(config["checkpoints"]["start"]["from"], config["checkpoints"]["start"]["to"])
	while true do
		if (player_in_checkpoint(racing_player, checkpoint_to_reach)) then
			current_checkpoint = current_checkpoint + 1
			if (current_checkpoint > #config["checkpoints"]) then
				checkpoint_to_reach = build_checkpoint(config["checkpoints"]["finish"]["from"], config["checkpoints"]["finish"]["to"])
			else
				checkpoint_to_reach = build_checkpoint(config["checkpoints"][current_checkpoint]["from"], config["checkpoints"][current_checkpoint]["to"])
			end
		end
	end
end


function build_checkpoint(from, to)
	hitbox = {}
	hitbox["max_x"] = math.max(from.x, to.x)
	hitbox["min_x"] = math.min(from.x, to.x)
	hitbox["max_y"] = math.max(from.y, to.y)
	hitbox["min_y"] = math.min(from.y, to.y)
	hitbox["max_z"] = math.max(from.z, to.z)
	hitbox["min_z"] = math.min(from.z, to.z)
	return hitbox
end

function player_in_checkpoint(player, checkpoint)
	local pos = playerDetector.getPlayerPos(player)
	monitor.write(player.name.." : "..pos.x.." "..pos.y.." "..pos.z)
	cur_y = cur_y + 1
	monitor.setCursorPos(1, cur_y)
	if (pos.x >= checkpoint.from.x and pos.x <= checkpoint.to.x) then
		if (pos.y >= checkpoint.from.y and pos.y <= checkpoint.to.y) then
			if (pos.z >= checkpoint.from.z and pos.z <= checkpoint.to.z) then
				return true
			end
		end
	end
	return false
end



function wait_for_player()
	local event, username, device = os.pullEvent("playerClick")
	return username
end









return main