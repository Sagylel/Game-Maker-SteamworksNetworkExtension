if(!instance_exists(oCo_Networking)) return;
if(!global.steam_connected) return;

draw_set_color(c_white);
draw_set_alpha(1);

if(global.lobby_created){
	//Lobby ID
	draw_text(4, 4, string(steam_lobby_get_data("name")) + ": " + string(steam_lobby_get_lobby_id()));
	
	for(var i = 0; i < steam_lobby_get_member_count(); i ++){
		var _player_id = steam_lobby_get_member_id(i);
			
		draw_text(4, 32 + (12 * i), "- " + string(steam_get_user_persona_name_sync(_player_id)) + " (" + string(steam_lobby_get_member_id(i)) + ")");
	}
}

if(global.lobby_list_ready){
	if(ds_list_size(global.lobby_list) > 0){
		draw_set_halign(fa_right);
		draw_set_color(c_yellow);
		for(var i = 0; i < ds_list_size(global.lobby_list); i ++){
			draw_text_transformed(room_width - 4, 4 + (12 * i), ds_list_find_value(global.lobby_list, i), .5, .5, 0);
		}
		draw_set_halign(fa_left);
	}
}