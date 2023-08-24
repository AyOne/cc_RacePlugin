local race = {}


local json = require("json")
local database = require("database")
local admin = require("admin")
local scoreboard = require("scoreboard")
local collisionDetection = require("collisionDetection")


local config_file = fs.open("config.json", "r")
local config = json.decode(config_file.readAll())
config_file.close()


local playerDetector = peripheral.find("playerDetector") or error(" No player detector found (required) ")
local chatBox = peripheral.find("chatBox") or error(" No chat box found (required) ")
local modem = peripheral.wrap("top") or error(" No modem found (required) ")

-- global variables that needs to be accessed by other threads
local player = nil
local player_data = nil
local race_data = nil
local disqualified = true
local stop_thread = false
local track_name = nil
local race_state = "idle"
local racing_data = nil



local firework = {
	["WOOOW"] = {
		["number"] = 24,
		["color"] = 16766720,
		["flicker"] = 16777215,
		["type"] = "star"
	},
	["world_record"] = {
		["number"] = 12,
		["color"] = 16766720,
		["flicker"] = 16777215,
		["type"] = "star"
	},
	["2nd"] = {
		["number"] = 6,
		["color"] = 12632256,
		["flicker"] = 16777215,
		["type"] = "large"
	},
	["3rd"] = {
		["number"] = 3,
		["color"] = 13467442,
		["flicker"] = 16777215,
		["type"] = "large"
	},
	["personal_best"] = {
		["number"] = 1,
		["color"] = 2515356,
		["flicker"] = 16777215,
		["type"] = "small"
	}
}


--[[
	TODO : firework on pb
	TODO : better scoreboard display when someone is racing
	TODO : better scoreboard display when someone finish
	TODO : better redstone signal for checkpoints
	TODO : chat message when someone make it to the podium
--]]




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
	race_data["boundary"] = config["race"][_track_name]["boundary"]

	race_data["player_reset"] = config["race"][_track_name]["player_reset"]
end



function race.start()
	stop_thread = false
	parallel.waitForAny(Full_race, Disconnect_thread, Scoreboard_thread)
	stop_thread = true
end






function Full_race()

	-- we wait for the player to click on the chatbox
	player = Wait_for_player()

	race_state = "racing"


	-- we update the status on the scoreboard
	--scoreboard.status("countdown for "..player)

	-- we update the redstone to active for the walls
	Send_redstone("start", "back", 1)



	player_data = database.get_player(player) or {}
	if not player_data[track_name] then
		player_data[track_name] = {}
	end
	racing_data = {
		["start_time"] = 0,
		["start"] = 0,
		["finish"] = 0,
		["checkpoints"] = {}
	}


	-- we spawn the boat and let the player get in place. we also change the redstone output
	chatBox.sendMessageToPlayer("You have subscribe to the race, good luck ;)", player, "Race Script")
	sleep(1.5)
	chatBox.sendMessageToPlayer("A boat has spawn for you. hope in ! It'll start soon", player, "Race Script")

	admin.kill_all_boat(race_data["boundary"]["x"], race_data["boundary"]["y"], race_data["boundary"]["z"], race_data["boundary"]["dx"], race_data["boundary"]["dy"], race_data["boundary"]["dz"])
	local boat_name = admin.summon_boat(race_data["boat"]["x"], race_data["boat"]["y"], race_data["boat"]["z"], race_data["boat"]["rotation"])
	
	
	sleep(1.5)
	chatBox.sendMessageToPlayer("Be ready on the starting line in ~5s", player, "Race Script")

	for i=1, 5 do
		sleep(1)
		Send_redstone("start", "back", i+1)
		Send_sound("start", "bell", 3, 20)
		--chatBox.sendMessageToPlayer((10 - i).."...", player, "Race Script")
	end

	-- we update the redstone to inactive for the walls
	

	sleep(1)
	Send_redstone("start", "back", 0)

	Send_sound("start", "bell", 3, 24)
	--scoreboard.status(player.." is racing !  ")
	--chatBox.sendMessageToPlayer("Gooo !!!", player, "Race Script")


	local start_time = os.epoch("utc")
	racing_data["start_time"] = start_time
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
				time_save = checkpoint_time - (player_data[track_name]["start"] or 0)
				racing_data["start"] = checkpoint_time
			elseif (last_checkpoint == true) then
				time_save = checkpoint_time - (player_data[track_name]["finish"] or 0)
				racing_data["finish"] = checkpoint_time
			else
				time_save = checkpoint_time - (player_data[track_name]["checkpoint_"..current_checkpoint] or 0)
				racing_data["checkpoints"][current_checkpoint] = checkpoint_time
			end

			-- display the time save to the player
			local msg = nil
			if (time_save == checkpoint_time) then
				msg = "Checkpoint : "..scoreboard.format_score(checkpoint_time)
			elseif (time_save < 0) then
				msg = "Checkpoint : "..scoreboard.format_score(checkpoint_time).." ["..time_save.." ms]"
			else
				msg = "Checkpoint : "..scoreboard.format_score(checkpoint_time).." [+"..time_save.." ms]"
			end
			chatBox.sendMessageToPlayer(msg, player, "Race Script")

			if (current_checkpoint == 0) then
				Send_sound("start", "bell", 3, 24)
			elseif (last_checkpoint == true) then
				Send_sound("finish", "bell", 3, 24)
				sleep(0.2)
				Send_sound("finish", "bell", 3, 24)
				sleep(0.2)
				Send_sound("finish", "bell", 3, 24)
			else
				Send_sound(current_checkpoint, "bell", 3, 24)
			end



			-- load the next checkpoint
			current_checkpoint = current_checkpoint + 1
			if (last_checkpoint == true) then
				break
			elseif (current_checkpoint > race_data.number_of_checkpoints) then
				checkpoint_to_reach = race_data.finish
				last_checkpoint = true
			else
				checkpoint_to_reach = race_data["checkpoint_"..current_checkpoint]
			end
		end
	end

	-- we make sure to remove the boat
	admin.kill_boat(boat_name)

	-- save the score
	if not disqualified then
		race_state = "finished"
		local pb, before, after = scoreboard.submit(racing_data, player, track_name)
		if (pb) then
			if (((before ~= 0 and after < before) or before == 0) and after <= 3) then
				if (after == 1) then
					for i=1, firework["world_record"].number do
						admin.firework(race_data.finish.max_x, race_data.finish.max_y, race_data.finish.max_z, 20, 2, firework.world_record.type, firework.world_record.color, firework.world_record.flicker)
						admin.firework(race_data.finish.min_x, race_data.finish.max_y, race_data.finish.min_z, 20, 2, firework.world_record.type, firework.world_record.color, firework.world_record.flicker)
						sleep(0.0001)
					end
					chatBox.sendMessage("Congratulation to "..player.." who got the World Record ["..scoreboard.format_score(racing_data.finish).."] on the track "..config.race[track_name].name.." !!!", "Race Script")
				elseif (after == 2) then
					for i=1, firework["2nd"].number do
						admin.firework(race_data.finish.max_x, race_data.finish.max_y, race_data.finish.max_z, 20, 2, firework["2nd"].type, firework["2nd"].color, firework["2nd"].flicker)
						admin.firework(race_data.finish.min_x, race_data.finish.max_y, race_data.finish.min_z, 20, 2, firework["2nd"].type, firework["2nd"].color, firework["2nd"].flicker)
						sleep(0.0001)
					end
					chatBox.sendMessage("Congratulation to "..player.." who got the 2d place ["..scoreboard.format_score(racing_data.finish).."] on the track "..config.race[track_name].name.." !!!", "Race Script")
				elseif (after == 3) then
					for i=1, firework["3rd"].number do
						admin.firework(race_data.finish.max_x, race_data.finish.max_y, race_data.finish.max_z, 20, 2, firework["3rd"].type, firework["3rd"].color, firework["3rd"].flicker)
						admin.firework(race_data.finish.min_x, race_data.finish.max_y, race_data.finish.min_z, 20, 2, firework["3rd"].type, firework["3rd"].color, firework["3rd"].flicker)
						sleep(0.0001)
					end
					chatBox.sendMessage("Congratulation to "..player.." who got the 3rd place ["..scoreboard.format_score(racing_data.finish).."] on the track "..config.race[track_name].name.." !!!", "Race Script")
				end
			elseif (before == after and after == 1) then
				for i=1, firework["WOOOW"].number do
					admin.firework(race_data.finish.max_x, race_data.finish.max_y, race_data.finish.max_z, 20, 2, firework["WOOOW"].type, firework["WOOOW"].color, firework["WOOOW"].flicker)
					admin.firework(race_data.finish.min_x, race_data.finish.max_y, race_data.finish.min_z, 20, 2, firework["WOOOW"].type, firework["WOOOW"].color, firework["WOOOW"].flicker)
					sleep(0.0001)
				end
				chatBox.sendMessage("Congratulation to "..player.." who beat his/her own World Record ["..scoreboard.format_score(racing_data.finish).."] on the track "..config.race[track_name].name.." !!!", "Race Script")
			else
				for i=1, firework["personal_best"].number do
					admin.firework(race_data.finish.max_x, race_data.finish.max_y, race_data.finish.max_z, 20, 2, firework["personal_best"].type, firework["personal_best"].color, firework["personal_best"].flicker)
					admin.firework(race_data.finish.min_x, race_data.finish.max_y, race_data.finish.min_z, 20, 2, firework["personal_best"].type, firework["personal_best"].color, firework["personal_best"].flicker)
					sleep(0.0001)
				end
			end
		end
	else
		race_state = "disqualified"
		scoreboard.discard(racing_data, player, track_name)
		admin.teleport(player, race_data.player_reset.x, race_data.player_reset.y, race_data.player_reset.z, race_data.player_reset.rotation)
		sleep(0.5)
		chatBox.sendMessageToPlayer("Something is not right... your race has been canceled.", player, "Race Script")
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
		["to"] = checkpoint.."",
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
		["to"] = checkpoint.."",
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


function Scoreboard_thread()
	local pannel = 1
	while not stop_thread do
		if (race_state == "idle") then
			if (pannel == 1) then
				scoreboard.idle_1(track_name, config.race[track_name])
				pannel = 2
			elseif (pannel == 2) then
				scoreboard.idle_2(track_name, config.race[track_name])
				pannel = 1
			end
			sleep(3)
		elseif (race_state == "racing") then
			scoreboard.racing_pannel(track_name, config.race[track_name], player, racing_data)
			sleep(1)
		elseif (race_state == "disqualified") then
			race_state = "idle"
			sleep(7)
			pannel = 1
		elseif (race_state == "finished") then
			race_state = "idle"
			sleep(7)
			pannel = 1
		end
	end
end




return race