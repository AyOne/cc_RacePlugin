main = {}

json = require("json")
datbase = require("database")
collisionDetection = require("collisionDetection")
config = fs.open("config.json", "r")
config = json.decode(config.readAll())


playerDetector = peripheral.find("playerDetector")
chatBox = peripheral.find("chatBox")
monitor = peripheral.find("monitor")
monitor.setTextScale(0.5)
monitor.clear()
cur_x, cur_y = 1,1
max_x, max_y = monitor.getSize()
monitor.setCursorPos(1,1)


racing_player = nil
racing_player_data = nil



function main.run()

	database.init()





	-- everything is initiated.
	race("test")
end

function race(race_name)
	racing_player = wait_for_player()
	racing_player_data = database.get_player(player)
	chatBox.sendMessageToPlayer("You have subscribe to the race, it will start soon !", racing_player, "Race Plugin")
	sleep(2)
	chatBox.sendMessageToPlayer("Be ready on the starting line in 10...", racing_player, "Race Plugin")
	for i=1, 9 do
		sleep(1)
		chatBox.sendMessageToPlayer((10 - i).."...", racing_player, "Race Plugin")
	end
	sleep(1)
	chatBox.sendMessageToPlayer("Gooo !!!", racing_player, "Race Plugin")

	local start_time = os.time()
	local current_time = start_time
	local current_checkpoint = 0
	raw_race = config["race"][race_name]
	checkpoint_to_reach = build_checkpoint(raw_race["start"]["from"], raw_race["start"]["to"])
	while true do
		if (player_passed_checkpoint(racing_player, checkpoint_to_reach)) then
			current_checkpoint = current_checkpoint + 1
			if (current_checkpoint > #raw_race["checkpoints"]) then
				checkpoint_to_reach = build_checkpoint(raw_race["finish"]["from"], raw_race["finish"]["to"])
			else
				checkpoint_to_reach = build_checkpoint(raw_race["checkpoints"][current_checkpoint]["from"], raw_race["checkpoints"][current_checkpoint]["to"])
			end
		end
	end
end


function build_checkpoint(from, to)
	hitbox = {}
	hitbox["max_x"] = math.max(from["x"], to["x"])
	hitbox["min_x"] = math.min(from["x"], to["x"])
	hitbox["max_y"] = math.max(from["y"], to["y"])
	hitbox["min_y"] = math.min(from["y"], to["y"])
	hitbox["max_z"] = math.max(from["z"], to["z"])
	hitbox["min_z"] = math.min(from["z"], to["z"])
	return hitbox
end



last_pos = nil
function player_passed_checkpoint(player, checkpoint)
	local pos = playerDetector.getPlayerPos(player)
	if not last_pos then
		last_pos = pos
		return false
	end

	if pos["x"] > checkpoint["max_x"] and pos["x"] < checkpoint["min_x"] and pos["y"] > checkpoint["max_y"] and pos["y"] < checkpoint["min_y"] and pos["z"] > checkpoint["max_z"] and pos["z"] < checkpoint["min_z"] then
		monitor.write(player.." passed the checkpoint !")
		cur_y = (cur_y + 1) % max_y
		monitor.setCursorPos(1, cur_y)

		last_pos = pos
		return true
	elseif collisionDetection.lineToHitbox(last_pos.x, last_pos.y, last_pos.z, pos.x, pos.y, pos.z, checkpoint["min_x"], checkpoint["min_y"], checkpoint["min_z"], checkpoint["max_x"], checkpoint["max_y"], checkpoint["max_z"]) then
		monitor.write(player.." passed the checkpoint !")
		cur_y = (cur_y + 1) % max_y
		monitor.setCursorPos(1, cur_y)

		last_pos = pos
		return true
	end

	last_pos = pos
	return false
end








function wait_for_player()
	local event, username, device = os.pullEvent("playerClick")
	return username
end









return main