main = {}


json = require("json")
datbase = require("database")
admin = require("admin")
collisionDetection = require("collisionDetection")


config = fs.open("config.json", "r")
config = json.decode(config.readAll())


playerDetector = peripheral.find("playerDetector") or error(" No player detector found (required) ")
chatBox = peripheral.find("chatBox") or error(" No chat box found (required) ")
speaker = peripheral.find("speaker") or nil


racing_player = nil
racing_player_data = nil

is_admin = admin.test()

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
	racing_data = {
		["start"] = 0,
		["finish"] = 0,
		["checkpoints"] = {}
	}


	chatBox.sendMessageToPlayer("You have subscribe to the race, it will start soon !", racing_player, "Race Plugin")
	sleep(2)
	chatBox.sendMessageToPlayer("Be ready on the starting line in 10...", racing_player, "Race Plugin")
	for i=1, 9 do
		sleep(1)
		if (is_admin) then
			admin.play_sound(racing_player, "bell", 1.7, 10)
		elseif (speaker) then
			speaker.playNote("bell", 3, 20)
		end
		chatBox.sendMessageToPlayer((10 - i).."...", racing_player, "Race Plugin")
	end
	sleep(1)
	if (is_admin) then
		admin.play_sound(racing_player, "bell", 2, 10)
	elseif (speaker) then
		speaker.playNote("bell", 3, 24)
	end
	chatBox.sendMessageToPlayer("Gooo !!!", racing_player, "Race Plugin")

	local start_time = os.epoch("utc")
	local current_time = start_time
	local current_checkpoint = 0
	raw_race = config["race"][race_name]
	checkpoint_to_reach = build_checkpoint(raw_race["start"]["from"], raw_race["start"]["to"])
	last = false
	last_time = 0
	while true do
		local passed, timeFactor = player_passed_checkpoint(racing_player, checkpoint_to_reach)
		if (passed) then

			current_time = os.epoch("utc")
			checkpoint_time = current_time - start_time

			-- save the time
			time_save = nil
			if (current_checkpoint == 0) then
				time_save = checkpoint_time - racing_player_data[race_name]["start"]
				racing_data["start"] = checkpoint_time
			elseif (last == true) then
				time_save = checkpoint_time - racing_player_data[race_name]["finish"]
				racing_data["finish"] = checkpoint_time
			else
				time_save = checkpoint_time - racing_player_data[race_name]["checkpoints"][current_checkpoint]
				racing_data["checkpoints"][current_checkpoint] = checkpoint_time
			end



			current_checkpoint = current_checkpoint + 1
			if (last == true) then
				if (admin) then
					admin.play_sound(racing_player, "bell", 2, 10)
					sleep(0.2)
					admin.play_sound(racing_player, "bell", 2, 10)
					sleep(0.2)
					admin.play_sound(racing_player, "bell", 2, 10)
				elseif (speaker) then
					speaker.playNote("bell", 3, 24)
					sleep(0.2)
					speaker.playNote("bell", 3, 24)
					sleep(0.2)
					speaker.playNote("bell", 3, 24)
				end
				break
			elseif (current_checkpoint > #raw_race["checkpoints"]) then
				checkpoint_to_reach = build_checkpoint(raw_race["finish"]["from"], raw_race["finish"]["to"])
				if (admin) then
					admin.play_sound(racing_player, "bell", 1, 10)
				elseif (speaker) then
					speaker.playNote("bell", 3, 10)
				end
				last = true
			else
				checkpoint_to_reach = build_checkpoint(raw_race["checkpoints"][current_checkpoint]["from"], raw_race["checkpoints"][current_checkpoint]["to"])
				if (admin) then
					admin.play_sound(racing_player, "bell", 1, 10)
				elseif (speaker) then
					speaker.playNote("bell", 3, 10)
				end
			end
		end
	end

	-- save the score
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
		return true, 1
	end
	local hit, factor = collisionDetection.lineToHitbox(last_pos.x, last_pos.y, last_pos.z, pos.x, pos.y, pos.z, checkpoint["min_x"], checkpoint["min_y"], checkpoint["min_z"], checkpoint["max_x"], checkpoint["max_y"], checkpoint["max_z"]
	elseif (hit) then
		last_pos = pos
		return true, factor
	end

	last_pos = pos
	return false, 0
end








function wait_for_player()
	local event, username, device = os.pullEvent("playerClick")
	return username
end









return main