admin = {}




function admin.test()
	-- run a dry command to see if this is command computer
	if not commands then
		return false
	end
	success, data = commands.exec("particle minecraft:happy_villager ~ ~ ~ 1 1 1 1 1")
	return success
end

function admin.is_player_in_boat(player)
	success, data = commands.exec("execute if entity @a[name=\""..player.."\",nbt={RootVehicle:{Entity:{id:\"minecraft:boat\"}}}]")
	return success
end

function admin.play_sound(player, sound, pitch, volume)
	if (sound == "bell") then
		sound = "minecraft:block.note_block.bell"
	end

	commands.exec("playsound "..sound.." voice "..player.." ~ ~ ~ "..volume.." "..pitch)
end







return admin