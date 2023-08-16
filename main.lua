main = {}


local json = require("json")
local database = require("database")
local admin = require("admin")
local scoreboard = require("scoreboard")
local collisionDetection = require("collisionDetection")


local config = fs.open("config.json", "r")
config = json.decode(config.readAll())


local playerDetector = peripheral.find("playerDetector") or error(" No player detector found (required) ")
local chatBox = peripheral.find("chatBox") or error(" No chat box found (required) ")
local speaker = peripheral.find("speaker") or nil


local racing_player = nil
local racing_player_data = nil

local is_admin = admin.test()

function main.run()

	database.init()
	scoreboard.load(database)





	-- everything is initiated.
	while true do
		scoreboard.display("ice_test", "idle")
		race("ice_test")
	end
end

function race(track_name)
	racing_player = wait_for_player()
	scoreboard.status("countdown for "..racing_player)
	racing_player_data = database.get_player(racing_player) or {}
	if not racing_player_data[track_name] then
		racing_player_data[track_name] = {}
	end
	racing_data = {
		["start"] = 0,
		["finish"] = 0,
		["checkpoints"] = {}
	}


	chatBox.sendMessageToPlayer("You have subscribe to the race, it will start soon !", racing_player, "Race Script")
	sleep(2)
	chatBox.sendMessageToPlayer("Be ready on the starting line in 10...", racing_player, "Race Script")
	for i=1, 9 do
		sleep(1)
		speaker.playNote("bell", 3, 20)
		chatBox.sendMessageToPlayer((10 - i).."...", racing_player, "Race Script")
	end
	sleep(1)
	speaker.playNote("bell", 3, 24)
	scoreboard.status(racing_player.." is racing !")
	chatBox.sendMessageToPlayer("Gooo !!!", racing_player, "Race Script")

	local start_time = os.epoch("utc")
	local current_time = start_time
	local current_checkpoint = 0
	raw_race = config["race"][track_name]
	checkpoint_to_reach = build_checkpoint(raw_race["start"]["from"], raw_race["start"]["to"])
	last = false
	disqualified = false
	last_time = 0
	while true do
		local passed, timeFactor = player_passed_checkpoint(racing_player, checkpoint_to_reach)
		if (passed) then
			if (admin and not admin.is_player_in_boat(racing_player)) then
				disqualified = true
				break
			end

			current_time = os.epoch("utc")
			checkpoint_time = current_time - start_time

			-- save the time
			local time_save = nil
			if (current_checkpoint == 0) then
				time_save = checkpoint_time - (racing_player_data[track_name]["start"] or 999999999)
				racing_data["start"] = checkpoint_time
			elseif (last == true) then
				time_save = checkpoint_time - (racing_player_data[track_name]["finish"] or 999999999)
				racing_data["finish"] = checkpoint_time
			else
				time_save = checkpoint_time - (racing_player_data[track_name]["checkpoint_"..current_checkpoint] or 999999999)
				racing_data["checkpoints"][current_checkpoint] = checkpoint_time
			end
			local msg = nil
			if (time_save < 0) then
				msg = "Checkpoint : "..scoreboard.format_score(checkpoint_time).." ms ["..time_save.." ms]"
			else
				msg = "Checkpoint : "..scoreboard.format_score(checkpoint_time).." ms [+"..time_save.." ms]"
			end
			chatBox.sendMessageToPlayer(msg, racing_player, "Race Script")



			current_checkpoint = current_checkpoint + 1
			if (last == true) then
				speaker.playNote("bell", 3, 24)
				sleep(0.2)
				speaker.playNote("bell", 3, 24)
				sleep(0.2)
				speaker.playNote("bell", 3, 24)
				break
			elseif (current_checkpoint > #raw_race["checkpoints"]) then
				checkpoint_to_reach = build_checkpoint(raw_race["finish"]["from"], raw_race["finish"]["to"])
				speaker.playNote("bell", 3, 10)
				last = true
			else
				checkpoint_to_reach = build_checkpoint(raw_race["checkpoints"][current_checkpoint]["from"], raw_race["checkpoints"][current_checkpoint]["to"])
				speaker.playNote("bell", 3, 10)
			end
		end
	end

	-- save the score
	if not disqualified then
		scoreboard.submit(racing_data, racing_player, track_name)
	else
		speaker.playNote("didgeridoo", 3, -1)
		sleep(0.2)
		speaker.playNote("didgeridoo", 3, -1)
		sleep(0.2)
		speaker.playNote("didgeridoo", 3, -1)
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
		return true, 1
	end
	local hit, factor = collisionDetection.lineToHitbox(last_pos.x, last_pos.y, last_pos.z, pos.x, pos.y, pos.z, checkpoint["min_x"], checkpoint["min_y"], checkpoint["min_z"], checkpoint["max_x"], checkpoint["max_y"], checkpoint["max_z"])
	if (hit) then
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