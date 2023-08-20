local scoreboard = {}

local monitor = peripheral.find("monitor") or error("No monitor found (required)")


local database = nil


function scoreboard.load(_database)
	database = _database
	monitor.setTextScale(1)
end

function scoreboard.submit(race_data, player_name, track_name)
	local player = database.get_player(player_name)
	if (player == nil or player[track_name]["finish"] > race_data["finish"]) then
		database.update_player(player_name, track_name, "start", race_data["start"])
		database.update_player(player_name, track_name, "finish", race_data["finish"])
		for i,time in pairs(race_data["checkpoints"]) do
			database.update_player(player_name, track_name, "checkpoint_"..i, time)
		end
		database.save()
	end
end



function scoreboard.sort(track_name)
	local scores = {}
	for name,data in pairs(database.data) do
		if data[track_name] ~= nil then
			table.insert(scores, {name, data[track_name].finish})
		end
	end
	table.sort(scores, function(a,b) return a[2] < b[2] end)
	return scores
end

function scoreboard.format_score(score)
	local minutes = math.floor(score / 60000)
	local seconds = math.floor(score / 1000) % 60
	local milliseconds = score % 1000
	return string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)
end

function scoreboard.status(status)
	local msg = "race status : "..status
	local x,y = monitor.getSize()
	monitor.setCursorPos(1, y)
	monitor.write(msg)
end

function scoreboard.display(track_name, status)
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