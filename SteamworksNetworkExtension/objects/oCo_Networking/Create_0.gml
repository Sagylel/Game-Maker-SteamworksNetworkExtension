#macro IS_RUN_FROM_IDE parameter_count()==3&&string_count("GMS2TEMP",parameter_string(2))
#macro STEAM_REFRESH_RATE 5 //Refresh Steam connection every 5 Seconds
#macro DEBUG_ENABLED true //Set to false for PUBLISHING BUILD

randomize();

global.debugging = -1;
alarm[2] = 1;//Reset Debug Overlay
#region Debug Overlay
dbg_view("game", false);
dbg_var_instance_count = 0;
dbg_watch(ref_create(self, "dbg_var_instance_count"), "Instance Count");
dbg_var_game_seed = random_get_seed();
dbg_watch(ref_create(self, "dbg_var_game_seed"), "Game Seed");
dbg_section("Steam");
dbg_watch(ref_create(global, "steam_connected"), "Steam Connected");
dbg_watch(ref_create(global, "steam_app_id"), "Steam App ID");
dbg_watch(ref_create(global, "steam_language"), "Steam Language");
dbg_watch(ref_create(global, "steam_id"), "Steam ID");
dbg_watch(ref_create(global, "steam_name"), "Steam Name");
dbg_section("Lobby");
dbg_watch(ref_create(global, "lobby_joined"), "Lobby Joined");
dbg_section("Network");
dbg_watch(ref_create(global, "is_server"), "Is Server");
#endregion

enum PacketType {
	ObjectSpawn,
	ObjectDestroy,
	RequestServerVariables,
	RetrieveServerVariables,
	PlayerInput,
	SetVariables,
	SetGlobalVariable,
	CallFunction,
}

network_buffer = buffer_create(16, buffer_grow, 1);

global.steam_ready = false;
global.steam_connected = false;
global.steam_app_id = -1;
global.steam_language = -1;
global.steam_id = -1;
global.steam_name = "";

//For Steam User Generated Content
global.steam_ugc_id = -1;
global.steam_ugc_name = "";

global.is_server = false;

global.is_game_restarting = false;

lobby_create_requested = false;
global.lobby_created = false;
global.lobby_joined = false;
global.lobby_list = ds_list_create();
global.lobby_list_ready = -1;
global.lobby_players_list = ds_list_create();

global.network_objects_map = {};//The net_id -> id mapped objects inside the room (resets at each room)

//Configs
global.lobby_type = steam_lobby_type_public;

function CheckSteamAPI(){
	show_debug_message("Checking Steam API...");
	if(steam_initialised() && (IS_RUN_FROM_IDE ? true : steam_stats_ready() && steam_is_overlay_enabled())){
		//Steam API is ready
		GetSteamUserVariables();
		return;
	}
	//If Steam API is not ready then check again
	alarm[0] = room_speed * 2;
}

function GetSteamUserVariables(){
	global.steam_app_id = steam_get_app_id();
	global.steam_language = steam_current_game_language();
	
	global.steam_id = steam_get_user_steam_id();
	global.steam_name = steam_get_persona_name();
	
	global.steam_ugc_id = steam_get_user_account_id();
	global.steam_ugc_name = steam_get_persona_name();
	
	global.steam_ready = true;
	
	show_debug_message("app id: " + string(global.steam_app_id));
	show_debug_message("language: " + string(global.steam_language));
	show_debug_message("id: " + string(global.steam_id) + " ... " + string(global.steam_ugc_id));
	show_debug_message("name: " + string(global.steam_name) + " ... " + string(global.steam_ugc_name));
}

function CheckSteamConnection(){
	global.steam_connected = steam_is_user_logged_on();
	if(global.steam_connected){
		alarm[1] = room_speed * STEAM_REFRESH_RATE;
	}else{
		alarm[1] = room_speed * 1.5;
	}
	
	show_debug_message(global.steam_connected ? "Steam connected" : "Steam NOT connected");
}

function RefreshLobbyPlayersList(){
	var _steam_current_lobby_members_list = ds_list_create();

	for(var i = 0; i < steam_lobby_get_member_count(); i ++){
		var _steam_id = steam_lobby_get_member_id(i);
		ds_list_add(_steam_current_lobby_members_list, _steam_id);
	}
	
	//Copy the temporary list to lobby_players_list
	ds_list_copy(global.lobby_players_list, _steam_current_lobby_members_list);
	
	//Destroy the temporary list
	ds_list_destroy(_steam_current_lobby_members_list);
}

CheckSteamAPI();
CheckSteamConnection();
alarm[3] = room_speed * 2;