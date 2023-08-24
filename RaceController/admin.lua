local admin = {}




function admin.test()
	if not commands then
		return false
	end
	return true
end

function admin.teleport(player, x, y, z, rotation)
	commands.exec("tp "..player.." "..x.." "..y.." "..z.." "..rotation.." 0")
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
		local rng = math.random(1,#charset)
		return string.random(length - 1) .. string.sub(charset, rng, rng + 1)
	else
		return ""
	end
end

function admin.summon_boat(x, y, z, rotation)
	local name = string.random(10)
	commands.exec("summon minecraft:boat "..x.." "..y.." "..z.." {Rotation:["..rotation.."f,0f],CustomName:\"\\\""..name.."\\\"\"}")
	return name
end

function admin.kill_boat(name)
	commands.exec("kill @e[type=minecraft:boat,nbt={CustomName:'{\"text\":\""..name.."\"}'}]")
end

function admin.kill_all_boat(x,y,z,dx,dy,dz)
	commands.exec("kill @e[type=minecraft:boat,x="..x..",y="..y..",z="..z..",dx="..dx..",dy="..dy..",dz="..dz.."]")
end

function admin.firework(x, y, z, lifeTime, flightTime, type, expl_color, flicker_color)
	-- /summon firework_rocket ~ ~ ~ {LifeTime:20,FireworksItem:{id:firework_rocket,Count:1,tag:{Fireworks:{Flight:2,Explosions:[{Type:2,Flicker:1b,Trail:1b,Colors:[I;16766720],FadeColors:[I;16777215]}]}}}}
	local command = "summon firework_rocket "
	command = command..x.." "..y.." "..z.." "
	command = command.."{LifeTime:"..lifeTime..",FireworksItem:{id:firework_rocket,Count:1,tag:{Fireworks:{Flight:"..flightTime
	local expl_type = nil
	if (type == "small") then
		expl_type = "1b"
	elseif (type == "big") then
		expl_type = "1"
	elseif (type == "star") then
		expl_type = "2"
	elseif (type == "creeper") then
		expl_type = "3"
	elseif (type == "burst") then
		expl_type = "4"
	end
	command = command..",Explosions:[{Type:"..expl_type..",Flicker:1b,Trail:1b,Colors:[I;"..expl_color.."],FadeColors:[I;"..flicker_color.."]}]}}}}"
	commands.exec(command)
end



return admin