scoreboard = {}

monitor = peripheral.find("monitor") or error("No monitor found (required)")


database = nil


function scoreboard.load(_database)
	database = _database
	monitor.setTextScale(0.5)
end


function scoreboard.display(track_name)
	size_x, size_y = monitor.getSize()
	monitor.clear()
	msg = "Ice Boat Racing - "..track_name.." - Scoreboard"
	monitor.setCursorPos(math.floor((size_x - #msg) / 2), 1)
	monitor.write(msg)
	msg = "Best PLayer"
	monitor.setCursorPos(math.floor((size_x - #msg) / 3), 3)
	monitor.write(msg)
	monitor.setCursorPos(math.floor((size_x - #msg) / 3), 4)
	for i=1, #msg do
		monitor.write("-")
	end
	msg = "Best Time"
	monitor.setCursorPos(math.floor((size_x - #msg) / 3 * 2), 3)
	monitor.write(msg)
	monitor.setCursorPos(math.floor((size_x - #msg) / 3 * 2), 4)
	for i=1, #msg do
		monitor.write("-")
	end
	cur_y = 5
	for name,data in pairs(database.data) do
		if data[track_name] ~= nil then
			msg = name
			monitor.setCursorPos(math.floor((size_x - #msg) / 3), cur_y)
			monitor.write(msg)
			msg = data[track_name].finish
			monitor.setCursorPos(math.floor((size_x - #msg) / 3 * 2), cur_y)
			monitor.write(msg)
			cur_y = cur_y + 1
		end
	end
end













return scoreboard