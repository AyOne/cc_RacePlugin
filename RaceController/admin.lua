local admin = {}




function admin.test()
	if not commands then
		return false
	end
	return true
end

function admin.is_player_in_boat(player, boat_name)
	if boat_name then
		local success, data = commands.exec("execute if entity @a[name=\""..player.."\",nbt={RootVehicle:{Entity:{id:\"minecraft:boat\",CustomName:'{\"text\":\""..boat_name.."\"}'}}}]")
		return success
	else
		local success, data = commands.exec("execute if entity @a[name=\""..player.."\",nbt={RootVehicle:{Entity:{id:\"minecraft:boat\"}}}]")
		return success
	end
end

local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
function string.random(length)
	if length > 0 then
		return string.random(length - 1) .. charset:sub(math.random(1, #charset), 1)
	else
		return ""
	end
end

function admin.summon_boat(x, y, z)
	local name = string.random(10)
	commands.exec("summon minecraft:boat "..x.." "..y.." "..z.." {CustomName:\"\\\""..name.."\\\"\"}")
	return name
end

function admin.kill_boat(name)
	commands.exec("kill @e[type=minecraft:boat,nbt={CustomName:\"\\\""..name.."\\\"\"}]")
end

function admin.kill_all_boat(x,y,z,dx,dy,dz)
	commands.exec("kill @e[type=minecraft:boat,x="..x..",y="..y..",z="..z..",dx="..dx..",dy="..dy..",dz="..dz.."]")
end

return admin