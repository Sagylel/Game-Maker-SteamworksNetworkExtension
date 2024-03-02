if(!global.is_server){
	NetworkRequestServerVariables();
}
NetworkPlayerSpawn(random(room_width), random(room_height), 0, global.steam_id);