var _type = async_load[? "event_type"];

switch(_type){
	case "lobby_created":
		//Server
		if (async_load[? "success"]){
			global.lobby_created = true;
			global.lobby_joined = true;
			global.is_server = true;
			
			steam_lobby_set_data("game", "treasure_royale");
			steam_lobby_set_data("name", global.steam_name + "'s lobby");
			steam_lobby_set_data("size", 8);
			steam_lobby_set_joinable(true);
		
	        show_debug_message("Lobby created");
		}else{
	        show_debug_message("Failed to create lobby");
		}
	break;
	
	case "lobby_joined":
		//Client
		if (async_load[? "success"]){
			global.is_server = false;
			global.lobby_joined = true;
		
			show_debug_message("Lobby joined");
		}else{
			show_debug_message("Failed to join lobby");
		}
	break;
	
	case "lobby_left":
		if (async_load[? "success"]){
			global.is_server = false;
			global.lobby_joined = false;
			global.lobby_server_id = -1;
		
			show_debug_message("Lobby left");
		}else{
			show_debug_message("Failed to leave lobby");
		}
	break;
	
	case "lobby_list":
		if (async_load[? "success"]){
			ds_list_clear(global.lobby_list);
	
			var _lobby_count = steam_lobby_list_get_count();
		    for (var i = 0; i < _lobby_count; i++)
		    {
		        var _lobby_id = steam_lobby_list_get_lobby_id(i);
		        var _lobby_name = steam_lobby_list_get_data(i, "name");
		        var _lobby_member_count = steam_lobby_list_get_lobby_member_count(i);
				var _lobby_size = steam_lobby_list_get_data(i, "size");
			
				ds_list_add(global.lobby_list,{id: _lobby_id, name: _lobby_name, member_count: _lobby_member_count, size: _lobby_size});
		    }
		
			global.lobby_list_ready = 1;
		
			show_debug_message("Lobby list received");
		}else{
			show_debug_message("Failed to received lobby");
		}
	break;
}