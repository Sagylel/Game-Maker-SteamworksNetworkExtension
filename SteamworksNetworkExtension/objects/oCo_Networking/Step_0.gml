//Update Steamworks API
steam_update();

//Goto lobby if initialization completed
if(room == rmInit){
	if(global.steam_ready) room_goto(rmLobby);
}

//Request Lobby Create
if(room == rmLobby){
	if(!global.lobby_created && !lobby_create_requested){
		steam_lobby_create(global.lobby_type, 8);
		lobby_create_requested = true;
	}
}

while (steam_net_packet_receive())
{
    steam_net_packet_get_data(network_buffer);
    buffer_seek(network_buffer, buffer_seek_start, 0);
	var data = buffer_read(network_buffer,buffer_string);
	var data_map = json_parse(data);
	
	switch(data_map[$ "typ"]){	
		case PacketType.ObjectSpawn:
			//Spawn Network Object In Client
			var _obj = instance_create_depth(data_map[$ "x"], data_map[$ "y"], data_map[$ "depth"], data_map[$ "obj"],{
				net_id: data_map[$ "net_id"],
				has_input_authority: variable_struct_exists(data_map, "input_authority_steam_id") ? global.steam_id == data_map[$ "input_authority_steam_id"] : -1,
			});
			
			struct_set(global.network_objects_map, data_map[$ "net_id"], { object_id: _obj.id, asset_index: _obj.object_index, x: data_map[$ "x"], y: data_map[$ "y"], depth: data_map[$ "depth"], });
		break;
		
		case PacketType.ObjectDestroy:
			if(data_map[$ "net_id"] != -1){//With NET_ID
				var _net_id = data_map[$ "net_id"];
				var _obj = struct_get(global.network_objects_map, _net_id);
				
				if(_obj && instance_exists(_obj.object_id)){
					instance_destroy(_obj.object_id);
				}
			}else{//WITHOUT NET-ID
				//Non-Network Object function call
				if(data_map[$ "obj"] && instance_exists(data_map[$ "obj"])){
					instance_destroy(data_map[$ "obj"]);
				}
			}
		break;
		
		case PacketType.RequestServerVariables:
			var _steam_id = data_map[$ "steam_id"];
			NetworkSendServerVariables(_steam_id);
		break;
		
		case PacketType.RetrieveServerVariables:
			//Recieved Network Objects
			var _retrieved_network_objects_map = json_parse(data_map[$ "network_objects_map"]);
			global.network_objects_map = _retrieved_network_objects_map;
			//Here Refresh the objects in the current scene with the network_objects_map
			_temporary_network_objects_map_keys_index = 0;
			_temporary_network_objects_map_keys = struct_get_names(global.network_objects_map);
			
			for (_temporary_network_objects_map_keys_index = 0; _temporary_network_objects_map_keys_index < array_length(_temporary_network_objects_map_keys); _temporary_network_objects_map_keys_index ++) {
				_temporary_obj_with_net_id_exists = false;
				with(oNetworkObject){
					if(net_id == other._temporary_network_objects_map_keys[other._temporary_network_objects_map_keys_index]){
						struct_set(global.network_objects_map, net_id, { object_id: id, asset_index: object_index });
						other._temporary_obj_with_net_id_exists = true;
					}
				}
				
				if(!_temporary_obj_with_net_id_exists){
					//Create missing network objects from net_id
					var _network_object = struct_get(global.network_objects_map, _temporary_network_objects_map_keys[_temporary_network_objects_map_keys_index]);
					var _obj = instance_create_depth(_network_object.x, _network_object.y, _network_object.depth, _network_object.asset_index,{
						net_id: _temporary_network_objects_map_keys[_temporary_network_objects_map_keys_index],
						has_input_authority: 0,
					});
					struct_set(global.network_objects_map, _obj.net_id, { object_id: _obj.id, asset_index: _obj.object_index });
				}
			}
			
			//Set Game Seed
			var _game_seed = data_map[$ "server_game_seed"];
			random_set_seed(_game_seed);;
		break;
		
		case PacketType.PlayerInput:
			var _obj = struct_get(global.network_objects_map, data_map[$ "net_id"]);//ds_map_find_value(global.network_objects_map, data_map[$ "net_id"]);
			var _input_data = data_map[$ "input_data"];
			
			//Process Server side input
			if(_obj && instance_exists(_obj.object_id)){
				_obj.object_id.network_received_input_data = _input_data;
			}
		break;
		
		case PacketType.SetVariables:
			if(data_map[$ "net_id"] != -1){//With NET_ID
				var _net_id = data_map[$ "net_id"];
				var _obj = struct_get(global.network_objects_map, _net_id);//ds_map_find_value(global.network_objects_map, _net_id);
			
				if(_obj && instance_exists(_obj.object_id)){
					//Set Variable
					var _var_struct = data_map[$ "variable_struct"];
					var _names = variable_struct_get_names(_var_struct);
				
					for(var i = 0;i < array_length(_names);i ++){
						if(instance_exists(_obj.object_id) && variable_instance_exists(_obj.object_id, _names[i])){
							variable_instance_set(_obj.object_id, _names[i], _var_struct[$ _names[i]]);
						}
					}
				}
			}else{//WITHOUT NET-ID
				//Non-Network Object function call
				//Set Variable
				var _var_struct = data_map[$ "variable_struct"];
				var _names = variable_struct_get_names(_var_struct);
				
				if(data_map[$ "obj"] && instance_exists(data_map[$ "obj"])){ 
					for(var i = 0;i < array_length(_names);i ++){
						if(instance_exists(data_map[$ "obj"]) && variable_instance_exists(data_map[$ "obj"], _names[i])){
							variable_instance_set(data_map[$ "obj"], _names[i], _var_struct[$ _names[i]]);
						}
					}
				}
			}
		break;
		
		case PacketType.SetGlobalVariable:
			var _variable_name = data_map[$ "variable_name"];
			var _value = json_parse(data_map[$ "value"]);
			
			if(variable_global_exists(_variable_name)){
				variable_global_set(_variable_name, _value);
				show_debug_message("global." + string(_variable_name) + " is set to " + string(_value));
			}
		break;
		
		case PacketType.CallFunction:
			if(data_map[$ "net_id"] != -1){//With NET_ID
				var _net_id = data_map[$ "net_id"];
				var _obj = struct_get(global.network_objects_map, data_map[$ "net_id"]).object_id;//ds_map_find_value(global.network_objects_map, _net_id).object_id;
				
				if(_obj && instance_exists(_obj)){
					//Call Function
					if(instance_exists(_obj) && variable_instance_exists(_obj, data_map[$ "function_name"])){
						if(variable_struct_exists(data_map, "parameter_struct")){
							var _var_struct = data_map[$ "parameter_struct"];
							//Has parameters
							variable_instance_get(_obj, data_map[$ "function_name"])(_var_struct);
						}else{
							//No parameters just call function
							variable_instance_get(_obj, data_map[$ "function_name"])();
						}
					}
				}
			}else{//WITHOUT NET-ID
				//Non-Network Object function call
				//Call Function
				if(data_map[$ "obj"] && instance_exists(data_map[$ "obj"])){
					if(variable_instance_exists(data_map[$ "obj"], data_map[$ "function_name"])){
						if(variable_struct_exists(data_map, "parameter_struct")){
							var _var_struct = data_map[$ "parameter_struct"];
							//Has parameters
							variable_instance_get(data_map[$ "obj"], data_map[$ "function_name"])(_var_struct);
						}else{
							//No parameters just call function
							variable_instance_get(data_map[$ "obj"], data_map[$ "function_name"])();
						}
					}
				}
			}
		break;
	}
}