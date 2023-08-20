local race = {}


local json = require("json")
local database = require("database")
local admin = require("admin")
local scoreboard = require("scoreboard")
local collisionDetection = require("collisionDetection")


local config_file = fs.open("config.json", "r")
local config = json.decode(config.readAll())
config_file.close()


local playerDetector = peripheral.find("playerDetector") or error(" No player detector found (required) ")
local chatBox = peripheral.find("chatBox") or error(" No chat box found (required) ")
local modem = peripheral.wrap("top") or error(" No modem found (required) ")

-- global variables that needs to be accessed by other threads
local player = nil
local player_data = nil
local race_data = nil
local disqualified = false
local stop_thread = false
local track_name = nil





function race.init(_track_name)
	track_name = _track_name
	race_data = {
		number_of_checkpoints = #config["race"][_track_name]["checkpoints"],
	}
	for k,v in pairs(config["race"][_track_name]["checkpoints"]) do
		race_data["checkpoint_"..k] = Build_checkpoint(v["from"], v["to"])
	end
	race_data["start"] = Build_checkpoint(config["race"][_track_name]["start"]["from"], config["race"][_track_name]["start"]["to"])
	race_data["finish"] = Build_checkpoint(config["race"][_track_name]["finish"]["from"], config["race"][_track_name]["finish"]["to"])

	race_data["boat"] = config["race"][_track_name]["boat"]
end



function race.start()
	stop_thread = false
	parallel.waitForAny(Full_race, Disconnect_thread)
	stop_thread = true
end






function Full_race()

	-- we wait for the player to click on the chatbox
	player = Wait_for_player()


	-- we update the status on the scoreboard
	scoreboard.status("countdown for "..player)

	-- we update the redstone to active for the walls
	Send_redstone("start", "back", 15)



	player_data = database.get_player(player) or {}
	if not player_data[track_name] then
		player_data[track_name] = {}
	end
	local racing_data = {
		["start"] = 0,
		["finish"] = 0,
		["checkpoints"] = {}
	}



	-- we spawn the boat and let the player get in place. we also change the redstone output
	chatBox.sendMessageToPlayer("You have subscribe to the race, good luck ;)", player, "Race Script")
	sleep(1)
	chatBox.sendMessageToPlayer("A boat has spawn for you. hope in ! It'll start soon", player, "Race Script")

	admin.kill_all_boat(race_data["boundry"]["x"], race_data["boundry"]["y"], race_data["boundry"]["z"], race_data["boundry"]["dx"], race_data["boundry"]["dy"], race_data["boundry"]["dz"])
	local boat_name = admin.summon_boat(race_data["boat"]["x"], race_data["boat"]["y"], race_data["boat"]["z"])
	
	sleep(1)
	chatBox.sendMessageToPlayer("Be ready on the starting line in 10...", player, "Race Script")

	for i=1, 9 do
		sleep(1)
		Send_sound("start", "bell", 3, 20)
		chatBox.sendMessageToPlayer((10 - i).."...", player, "Race Script")
	end

	-- we update the redstone to inactive for the walls
	Send_redstone("start", "back", 0)



	sleep(1)
	Send_sound("start", "bell", 3, 24)
	scoreboard.status(player.." is racing !  ")
	chatBox.sendMessageToPlayer("Gooo !!!", player, "Race Script")


	local start_time = os.epoch("utc")
	local current_time = start_time

	local current_checkpoint = 0
	local checkpoint_to_reach = race_data["start"]
	local last_checkpoint = false
	disqualified = false
	while not disqualified do

		-- check if the player is still in the boat we gave him
		if (not admin.is_player_in_boat(player, boat_name)) then
			disqualified = true -- if not, he's disqualified
			break
		end

		-- check if the player passed the checkpoint
		local passed, timeFactor = Player_passed_checkpoint(player, checkpoint_to_reach)
		if (passed) then

			-- calculate the time
			current_time = os.epoch("utc")
			local checkpoint_time = current_time - start_time

			-- calculate the time save compared with personal best
			local time_save = nil
			if (current_checkpoint == 0) then
				time_save = checkpoint_time - (player_data[track_name]["start"] or 999999999)
				racing_data["start"] = checkpoint_time
			elseif (last_checkpoint == true) then
				time_save = checkpoint_time - (player_data[track_name]["finish"] or 999999999)
				racing_data["finish"] = checkpoint_time
			else
				time_save = checkpoint_time - (player_data[track_name]["checkpoint_"..current_checkpoint] or 999999999)
				racing_data["checkpoints"][current_checkpoint] = checkpoint_time
			end

			-- display the time save to the player
			local msg = nil
			if (time_save > 1000000) then
				msg = "Checkpoint : "..scoreboard.format_score(checkpoint_time)
			elseif (time_save < 0) then
				msg = "Checkpoint : "..scoreboard.format_score(checkpoint_time).." ["..time_save.." ms]"
			else
				msg = "Checkpoint : "..scoreboard.format_score(checkpoint_time).." [+"..time_save.." ms]"
			end
			chatBox.sendMessageToPlayer(msg, player, "Race Script")


			-- load the next checkpoint
			current_checkpoint = current_checkpoint + 1
			if (last_checkpoint == true) then
				Send_sound("finish", "bell", 3, 24)
				sleep(0.2)
				Send_sound("finish", "bell", 3, 24)
				sleep(0.2)
				Send_sound("finish", "bell", 3, 24)
				break
			elseif (current_checkpoint > race_data["number_of_checkpoints"]) then
				checkpoint_to_reach = race_data["finish"]
				Send_sound(current_checkpoint - 1, "bell", 3, 10)
				last_checkpoint = true
			else
				checkpoint_to_reach = race_data["checkpoint_"..current_checkpoint]
				Send_sound(current_checkpoint - 1, "bell", 3, 10)
			end
		end
	end

	-- we make sure to remove the boat
	admin.kill_boat(boat_name)

	-- save the score
	if not disqualified then
		scoreboard.submit(racing_data, player, track_name)
	else
		chatBox.sendMessageToPlayer("something is not right... your race has been canceled.", "Race Script")
	end
end


function Build_checkpoint(from, to)
	local hitbox = {}
	hitbox["max_x"] = math.max(from["x"], to["x"])
	hitbox["min_x"] = math.min(from["x"], to["x"])
	hitbox["max_y"] = math.max(from["y"], to["y"])
	hitbox["min_y"] = math.min(from["y"], to["y"])
	hitbox["max_z"] = math.max(from["z"], to["z"])
	hitbox["min_z"] = math.min(from["z"], to["z"])
	return hitbox
end


function Send_sound(checkpoint, instrument, volume, pitch)
	local msg = {
		["to"] = checkpoint,
		["event_name"] = "play_sound",
		["event_data"] = {
			["instrument"] = instrument,
			["volume"] = volume,
			["pitch"] = pitch
		}
	}
	modem.transmit(323, 0, json.encode(msg))
end

function Send_redstone(checkpoint, side, strength)
	local msg = {
		["to"] = checkpoint,
		["event_name"] = "redstone_change",
		["event_data"] = {
			["side"] = side,
			["strength"] = strength
		}
	}
	modem.transmit(323, 0, json.encode(msg))
end

local last_pos = nil
function Player_passed_checkpoint(username, checkpoint)
	local pos = playerDetector.getPlayerPos(username)
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


function Wait_for_player()
	local event, username, device = os.pullEvent("playerClick")
	return username
end

function Disconnect_thread()
	while not stop_thread do
		local event, username = os.pullEvent("playerLeave")
		if username == player then
			disqualified = true
		end
	end
end







return race