local scoreboard = {}

local monitor = peripheral.find("monitor") or error("No monitor found (required)")

local database = nil

function scoreboard.load(_database)
	database = _database
	monitor.setTextScale(1)
end

function scoreboard.format_score(score)
	local minutes = math.floor(score / 60000)
	local seconds = math.floor(score / 1000) % 60
	local milliseconds = score % 1000
	return string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)
end

function scoreboard.format_big_score(score)
	local hours = math.floor(score / 3600000)
	local minutes = math.floor(score / 60000)
	local seconds = math.floor(score / 1000) % 60
	local milliseconds = score % 1000
	return string.format("%03d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
end

function scoreboard.format_date(data)
	return os.date("%d-%b", data)
end

function scoreboard.sort(track_name)
	local scores = {}
	for name,data in pairs(database.data) do
		if data[track_name] ~= nil then
			table.insert(scores, {name, data[track_name]})
		end
	end
	table.sort(scores, function(a,b) return a[2].finish < b[2].finish end)
	return scores
end

--[[	wanted designs (scale with monitor size):


idle full pannel
==================== <race name> ====================
	Racer			Date			Best time 	Number of try	Total time racing
	-------			------			---------	-------------	-----------------
	<racer>			XX-JUN			xx:xx.xxx	<intager>		xxx:xx:xx.xxx
	<racer>			XX-JUN			xx:xx.xxx	<intager>		xxx:xx:xx.xxx
	<racer>			XX-JUN			xx:xx.xxx	<intager>		xxx:xx:xx.xxx
	<racer>			XX-JUN			xx:xx.xxx	<intager>		xxx:xx:xx.xxx
	<racer>			XX-JUN			xx:xx.xxx	<intager>		xxx:xx:xx.xxx
	<racer>			XX-JUN			xx:xx.xxx	<intager>		xxx:xx:xx.xxx
	<racer>			XX-JUN			xx:xx.xxx	<intager>		xxx:xx:xx.xxx


idle pannel #1
==================== <race name> ====================
	Racer			Date			Best time
	-------			------			---------
	<racer>			XX-JUN			xx:xx.xxx
	<racer>			XX-JUN			xx:xx.xxx
	<racer>			XX-JUN			xx:xx.xxx
	<racer>			XX-JUN			xx:xx.xxx
	<racer>			XX-JUN			xx:xx.xxx
	<racer>			XX-JUN			xx:xx.xxx

idle pannel #2
==================== <race name> ====================
	Racer			Number of try	Total time racing
	-------			-------------	-----------------
	<racer>			<intager>		xxx:xx:xx.xxx
	<racer>			<intager>		xxx:xx:xx.xxx
	<racer>			<intager>		xxx:xx:xx.xxx
	<racer>			<intager>		xxx:xx:xx.xxx
	<racer>			<intager>		xxx:xx:xx.xxx

racing pannel #1
==================== <race name> ====================
	
	Racing : <actual racer>
	Start : xx:xx.xxx [+/-xxxxms]			personnal best : xx:xx.xxx
	
	checkpoint X : xx:xx.xxx [+/-xxxxms]	personnal best : xx:xx.xxx
	checkpoint X : xx:xx.xxx [+/-xxxxms]	personnal best : xx:xx.xxx
	checkpoint X : xx:xx.xxx [+/-xxxxms]	personnal best : xx:xx.xxx
	checkpoint X : xx:xx.xxx [+/-xxxxms]	personnal best : xx:xx.xxx
	checkpoint X : xx:xx.xxx [+/-xxxxms]	personnal best : xx:xx.xxx
	checkpoint X : xx:xx.xxx [+/-xxxxms]	personnal best : xx:xx.xxx
	checkpoint X : xx:xx.xxx [+/-xxxxms]	personnal best : xx:xx.xxx
	checkpoint X : xx:xx.xxx [+/-xxxxms]	personnal best : xx:xx.xxx
	checkpoint X : xx:xx.xxx [+/-xxxxms]	personnal best : xx:xx.xxx
	checkpoint X : xx:xx.xxx [+/-xxxxms]	personnal best : xx:xx.xxx
	
	Finish : xx:xx.xxx [+/-xxxxms]			personnal best : xx:xx.xxx


--]]








function scoreboard.full_pannel(track_name, track_config)
	local players = scoreboard.sort(track_name)

	monitor.setBackgroundColor(colors.black)
	monitor.clear()
	monitor.setTextColor(colors.white)
	local size_x, size_y = monitor.getSize()

	-- Title
	local msg = " "..track_config.name.." "
	for i=1, math.ceil(size_x / 2) - #msg do
		msg = "="..msg.."="
	end
	monitor.setCursorPos(1, 1)
	monitor.write(msg)



	-- Header
	local max_name_length = 0
	for i=1, math.min(#players, 15) do
		if #players[i][1] > max_name_length then
			max_name_length = #players[i][1]
		end
	end
	local anchor = math.floor(size_x / 7)
	msg = "Racer"
	monitor.setCursorPos(anchor, 3)
	monitor.write(msg)
	monitor.setCursorPos(anchor, 4)
	for i=1, max_name_length do
		monitor.write("-")
	end
	
	anchor = math.floor(size_x / 7 * 2)
	msg = "Date"
	monitor.setCursorPos(anchor, 3)
	monitor.write(msg)
	monitor.setCursorPos(anchor, 4)
	for i=1, 6 do
		monitor.write("-")
	end

	anchor = math.floor(size_x / 7 * 3)
	msg = "Best time"
	monitor.setCursorPos(anchor, 3)
	monitor.write(msg)
	monitor.setCursorPos(anchor, 4)
	for i=1, 9 do
		monitor.write("-")
	end

	anchor = math.floor(size_x / 7 * 4)
	msg = "Number of try"
	monitor.setCursorPos(anchor, 3)
	monitor.write(msg)
	monitor.setCursorPos(anchor, 4)
	for i=1, 13 do
		monitor.write("-")
	end

	anchor = math.floor(size_x / 7 * 5)
	msg = "Total time racing"
	monitor.setCursorPos(anchor, 3)
	monitor.write(msg)
	monitor.setCursorPos(anchor, 4)
	for i=1, 18 do
		monitor.write("-")
	end



	-- Content
	local cur_y = 5
	for i=1, math.min(#players, 15) do
		anchor = math.floor(size_x / 7)
		msg = players[i][1]
		monitor.setCursorPos(anchor, cur_y)
		monitor.write(msg)

		anchor = math.floor(size_x / 7 * 2)
		msg = scoreboard.format_date(players[i][2].date or 0)
		monitor.setCursorPos(anchor, cur_y)
		monitor.write(msg)

		anchor = math.floor(size_x / 7 * 3)
		msg = scoreboard.format_score(players[i][2].finish)
		monitor.setCursorPos(anchor, cur_y)
		monitor.write(msg)

		anchor = math.floor(size_x / 7 * 4)
		msg = players[i][2].number_of_try or 0
		monitor.setCursorPos(anchor, cur_y)
		monitor.write(msg)

		anchor = math.floor(size_x / 7 * 5)
		msg = scoreboard.format_big_score(players[i][2].total_time_racing or 0)
		monitor.setCursorPos(anchor, cur_y)
		monitor.write(msg)

		cur_y = cur_y + 1
	end

end














function scoreboard.idle_1(track_name, track_config)
	local players = scoreboard.sort(track_name)

	monitor.setBackgroundColor(colors.black)
	monitor.clear()
	monitor.setTextColor(colors.white)
	local size_x, size_y = monitor.getSize()

	-- Title
	local msg = " "..track_config.name.." "
	for i=1, math.ceil((size_x - #msg) / 2) do
		msg = "="..msg.."="
	end
	monitor.setCursorPos(1, 1)
	monitor.write(msg)




	-- Header
	local max_name_length = 0
	for i=1, math.min(#players, 15) do
		if #players[i][1] > max_name_length then
			max_name_length = #players[i][1]
		end
	end
	local anchor = math.floor(size_x / 5)
	msg = "Racer"
	monitor.setCursorPos(anchor, 3)
	monitor.write(msg)
	monitor.setCursorPos(anchor, 4)
	for i=1, max_name_length do
		monitor.write("-")
	end

	anchor = math.floor(size_x / 5 * 2)
	msg = "Date"
	monitor.setCursorPos(anchor, 3)
	monitor.write(msg)
	monitor.setCursorPos(anchor, 4)
	for i=1, 6 do
		monitor.write("-")
	end

	anchor = math.floor(size_x / 5 * 3)
	msg = "Best time"
	monitor.setCursorPos(anchor, 3)
	monitor.write(msg)
	monitor.setCursorPos(anchor, 4)
	for i=1, 9 do
		monitor.write("-")
	end




	-- Content
	local cur_y = 5
	for i=1, math.min(#players, 15) do
		anchor = math.floor(size_x / 5)
		msg = players[i][1]
		monitor.setCursorPos(anchor, cur_y)
		monitor.write(msg)

		anchor = math.floor(size_x / 5 * 2)
		msg = scoreboard.format_date(players[i][2].date)
		monitor.setCursorPos(anchor, cur_y)
		monitor.write(msg)

		anchor = math.floor(size_x / 5 * 3)
		msg = scoreboard.format_score(players[i][2].finish)
		monitor.setCursorPos(anchor, cur_y)
		monitor.write(msg)

		cur_y = cur_y + 1
	end
end





function scoreboard.idle_2(track_name, track_config)
	local players = scoreboard.sort(track_name)

	monitor.setBackgroundColor(colors.black)
	monitor.clear()
	monitor.setTextColor(colors.white)
	local size_x, size_y = monitor.getSize()

	-- Title
	local msg = " "..track_config.name.." "
	for i=1, math.ceil((size_x - #msg) / 2) do
		msg = "="..msg.."="
	end
	monitor.setCursorPos(1, 1)
	monitor.write(msg)



	-- Header
	local max_name_length = 0
	for i=1, math.min(#players, 15) do
		if #players[i][1] > max_name_length then
			max_name_length = #players[i][1]
		end
	end

	local anchor = math.floor(size_x / 5)
	msg = "Racer"
	monitor.setCursorPos(anchor, 3)
	monitor.write(msg)
	monitor.setCursorPos(anchor, 4)
	for i=1, max_name_length do
		monitor.write("-")
	end

	anchor = math.floor(size_x / 5 * 2)
	msg = "Number of try"
	monitor.setCursorPos(anchor, 3)
	monitor.write(msg)
	monitor.setCursorPos(anchor, 4)
	for i=1, 13 do
		monitor.write("-")
	end

	anchor = math.floor(size_x / 5 * 3)
	msg = "Total time racing"
	monitor.setCursorPos(anchor, 3)
	monitor.write(msg)
	monitor.setCursorPos(anchor, 4)
	for i=1, 18 do
		monitor.write("-")
	end




	-- Content
	local cur_y = 5
	for i=1, math.min(#players, 15) do
		anchor = math.floor(size_x / 5)
		msg = players[i][1]
		monitor.setCursorPos(anchor, cur_y)
		monitor.write(msg)

		anchor = math.floor(size_x / 5 * 2)
		msg = math.floor(players[i][2].number_of_try or 0)
		monitor.setCursorPos(anchor, cur_y)
		monitor.write(msg)

		anchor = math.floor(size_x / 5 * 3)
		msg = scoreboard.format_big_score(players[i][2].total_time_racing or 0)
		monitor.setCursorPos(anchor, cur_y)
		monitor.write(msg)

		cur_y = cur_y + 1
	end



end


















function scoreboard.discard(race_data, player_name, track_name)
	local player = database.get_player(player_name)
	local last_time = race_data["finish"] or 0
	if (last_time == 0) then
		for k, v in pairs(race_data["checkpoints"]) do
			if (v > last_time) then
				last_time = v
			end
		end
	end
	if (not player or not player[track_name]) then
		database.update_player_number_of_try(player_name, track_name, 1)
		database.update_player_total_time_racing(player_name, track_name, last_time)
	else
		database.update_player_number_of_try(player_name, track_name, (player[track_name]["number_of_try"] or 0) + 1)
		database.update_player_total_time_racing(player_name, track_name, (player[track_name]["total_time_racing"] or 0) + last_time)
	end

	database.save()
end


function scoreboard.submit(race_data, player_name, track_name)
	local player = database.get_player(player_name)
	if (not player or not player[track_name]) then
		database.update_player_number_of_try(player_name, track_name, 1)
		database.update_player_total_time_racing(player_name, track_name, race_data["finish"])
	else
		database.update_player_number_of_try(player_name, track_name, (player[track_name]["number_of_try"] or 0) + 1)
		database.update_player_total_time_racing(player_name, track_name, (player[track_name]["total_time_racing"] or 0) + race_data["finish"])
	end

	if (player == nil or player[track_name]["finish"] > race_data["finish"]) then
		database.update_player_date(player_name, track_name, race_data.start_time)
		database.update_player_time(player_name, track_name, "start", race_data["start"])
		database.update_player_time(player_name, track_name, "finish", race_data["finish"])
		for i,time in pairs(race_data["checkpoints"]) do
			database.update_player_time(player_name, track_name, "checkpoint_"..i, time)
		end
		database.save()
		return true
	end
end



function scoreboard.status(status)
	error("scoreboard.status() is deprecated")
	local msg = "race status : "..status
	local x,y = monitor.getSize()
	monitor.setCursorPos(1, y)
	monitor.write(msg)
end

function scoreboard.display(track_name, status)
	error("scoreboard.display() is deprecated")
	local size_x, size_y = monitor.getSize()
	monitor.clear()
	local msg = "Ice Boat Racing - "..track_name.." - Scoreboard"
	monitor.setCursorPos(math.floor((size_x - #msg) / 2), 1)
	monitor.write(msg)
	msg = "Best PLayer"
	monitor.setCursorPos(math.floor(size_x / 5), 3)
	monitor.write(msg)
	monitor.setCursorPos(math.floor(size_x / 5), 4)
	for i=1, #msg do
		monitor.write("-")
	end
	msg = "Best Time"
	monitor.setCursorPos(math.floor(size_x / 5 * 3), 3)
	monitor.write(msg)
	monitor.setCursorPos(math.floor(size_x / 5 * 3), 4)
	for i=1, #msg do
		monitor.write("-")
	end
	local cur_y = 5

	local scores = scoreboard.sort(track_name)
	for i=1, math.min(#scores, 10) do
		msg = scores[i][1]
		monitor.setCursorPos(math.floor(size_x / 5), cur_y)
		monitor.write(msg)
		msg = scoreboard.format_score(scores[i][2])
		monitor.setCursorPos(math.floor(size_x / 5 * 3), cur_y)
		monitor.write(msg)
		cur_y = cur_y + 1
	end

	if status ~= nil then
		scoreboard.status(status)
	end
end













return scoreboard