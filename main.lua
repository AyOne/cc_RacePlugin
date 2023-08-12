main = {}

json = require("json")
datbase = require("database")
collisionDetection = require("collisionDetection")
config = fs.open("config.json", "r")
config = json.decode(config.readAll())


playerDetector = peripheral.find("playerDetector")
chatBox = peripheral.find("chatBox")
monitor = peripheral.find("monitor")
speaker = peripheral.find("speaker")
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
	while true do
		race("test")
		sleep(5)
	end
end

function race(race_name)
	racing_player = wait_for_player()
	racing_player_data = database.get_player(player)
	monitor.clear()
	cur_x, cur_y = 1,1
	monitor.setCursorPos(1,1)
	monitor.write(racing_player.." is racing !")
	cur_y = (cur_y + 1) % max_y
	chatBox.sendMessageToPlayer("You have subscribe to the race, it will start soon !", racing_player, "Race Plugin")
	sleep(2)
	chatBox.sendMessageToPlayer("Be ready on the starting line in 10...", racing_player, "Race Plugin")
	for i=1, 9 do
		sleep(1)
		speaker.playSound("bell", 3, 20)
		chatBox.sendMessageToPlayer((10 - i).."...", racing_player, "Race Plugin")
	end
	sleep(1)
	speaker.playSound("bell", 3, 24)
	chatBox.sendMessageToPlayer("Gooo !!!", racing_player, "Race Plugin")

	local start_time = os.epoch("utc")
	local current_time = start_time
	local current_checkpoint = 0
	raw_race = config["race"][race_name]
	checkpoint_to_reach = build_checkpoint(raw_race["start"]["from"], raw_race["start"]["to"])
	last = false
	while true do
		if (player_passed_checkpoint(racing_player, checkpoint_to_reach)) then

			checkpoint_time = os.epoch("utc") - current_time
			current_time = os.epoch("utc")

			monitor.write("Checkpoint "..current_checkpoint.." in "..math.floor((os.epoch("utc") - start_time) / 1000).."."..math.floor((os.epoch("utc") - start_time) % 1000).."s with a total time of "..math.floor((os.epoch("utc") - start_time) / 1000).."."..math.floor((os.epoch("utc") - start_time) % 1000).."s")
			cur_y = (cur_y + 1) % max_y
			monitor.setCursorPos(1, cur_y)




			current_checkpoint = current_checkpoint + 1
			if (last == true) then
				speaker.playSound("bell", 3, 24)
				sleep(0.2)
				speaker.playSound("bell", 3, 24)
				sleep(0.2)
				speaker.playSound("bell", 3, 24)
				break
			end
			if (current_checkpoint > #raw_race["checkpoints"]) then
				checkpoint_to_reach = build_checkpoint(raw_race["finish"]["from"], raw_race["finish"]["to"])
				speaker.playSound("bell", 3, 10)
				last = true
			else
				checkpoint_to_reach = build_checkpoint(raw_race["checkpoints"][current_checkpoint]["from"], raw_race["checkpoints"][current_checkpoint]["to"])
				speaker.playSound("bell", 3, 10)
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
		last_pos = pos
		return true
	elseif collisionDetection.lineToHitbox(last_pos.x, last_pos.y, last_pos.z, pos.x, pos.y, pos.z, checkpoint["min_x"], checkpoint["min_y"], checkpoint["min_z"], checkpoint["max_x"], checkpoint["max_y"], checkpoint["max_z"]) then
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