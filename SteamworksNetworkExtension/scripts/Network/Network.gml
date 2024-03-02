function send_packet(data, user_id = 0, packet_type = steam_net_packet_type_unreliable){
	var encoded_map = json_stringify(data);
	var b = buffer_create(string_byte_length(encoded_map)+1, buffer_fixed, 1);
	
	buffer_write(b, buffer_string, encoded_map);
	steam_net_packet_send(user_id, b,-1,packet_type);
	buffer_delete(b);
}

function send_packet_all(data, include_self = true, packet_type = steam_net_packet_type_unreliable){
	for(var a = 0 ; a < steam_lobby_get_member_count() ; a++){
		var player = steam_lobby_get_member_id(a);
	
		if(steam_get_user_steam_id() == player && !include_self)
			continue;
		
		send_packet(data, player, packet_type);
	}
}

function NetworkRequestSteamLobbies(){
	global.lobby_list_ready = -1;
	steam_lobby_list_add_distance_filter(steam_lobby_list_distance_filter_far);
	steam_lobby_list_add_string_filter("game", "treasure_royale", steam_lobby_list_filter_eq)
	steam_lobby_list_request();
}

function NetworkRequestServerVariables(){
	if(global.is_server) return; //Only request in a clent
	var _network_packet = {
		typ: PacketType.RequestServerVariables,
		steam_id: global.steam_id,
	};
	
	send_packet(_network_packet, steam_lobby_get_owner_id(), steam_net_packet_type_reliable);
}

function NetworkSendServerVariables(_steam_id){	
	var _network_packet = {
		typ: PacketType.RetrieveServerVariables,
		network_objects_map: json_stringify(global.network_objects_map),
		server_game_seed: random_get_seed(),
	};
	
	send_packet(_network_packet, _steam_id, steam_net_packet_type_reliable);
}

function NetworkSetGlobalVariable(_steam_id, _variable_name, _value){
	var _network_packet = {
		typ: PacketType.SetGlobalVariable,
		variable_name: _variable_name,
		value: _value,
	};
	
	send_packet(_network_packet, _steam_id, steam_net_packet_type_reliable);
}

function NetworkPlayerSpawn(_x, _y, _depth, _input_authority_steam_id){
	var _net_id = -1;
	while(_net_id == -1 || struct_exists(global.network_objects_map, _net_id)){
		_net_id = GetRandomHash(16);
	}
	
	var _network_packet = {
		typ: PacketType.ObjectSpawn,
		x: _x,
		y: _y,
		depth: _depth,
		obj: global.player_object_asset,
		net_id: _net_id,
		input_authority_steam_id: _input_authority_steam_id,
	};
	
	send_packet_all(_network_packet, true, steam_net_packet_type_reliable);
}

function NetworkObjectCreate(_x, _y, _depth, _obj, _has_input_authority = -1){
	var _network_packet = {
		typ: PacketType.ObjectSpawn,
		x: _x,
		y: _y,
		depth: _depth,
		obj: _obj,
		net_id: GetRandomHash(16),
	};
	
	send_packet_all(_network_packet, true, steam_net_packet_type_reliable);
}

function NetworkObjectDestroy(_net_id = -1, _obj = -1){
	var _network_packet = {
		 typ: PacketType.ObjectDestroy,
		 net_id: _net_id,
		 obj: _obj,
	};
	
	send_packet_all(_network_packet, true, steam_net_packet_type_reliable);
}

//Network Input Struct
function NetworkInput() constructor{
	hmove = 0;
	vmove = 0;
	mbleft = 0;
	mbright = 0;
}

function NetworkSendInput(_net_id, _input_data){
	var _network_packet = {
		 typ: PacketType.PlayerInput,
		 net_id: _net_id,
		 input_data: _input_data,
	};
	send_packet(_network_packet, steam_lobby_get_owner_id(), steam_net_packet_type_reliable);
}

function NetworkCallFunction(_net_id = -1, _obj = -1, _function_name, _parameter_struct = {}){
	var _network_packet = {
		 typ: PacketType.CallFunction,
		 net_id: _net_id,
		 obj: _obj,
		 function_name: _function_name,
		 parameter_struct: _parameter_struct,
	};
	
	send_packet_all(_network_packet, true, steam_net_packet_type_reliable);
}

function NetworkSetVariable(_net_id = -1, _obj = -1, _variable_struct, is_reliable = 1){
	var _network_packet = {
		 typ: PacketType.SetVariables,
		 net_id: _net_id,
		 obj: _obj,
		 variable_struct: _variable_struct,
	};
	
	send_packet_all(_network_packet, true, is_reliable ? steam_net_packet_type_reliable : steam_net_packet_type_unreliable);
}