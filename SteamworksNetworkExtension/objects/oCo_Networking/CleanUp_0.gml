ds_list_destroy(global.lobby_list);
ds_list_destroy(global.lobby_players_list);
delete global.network_objects_map;//ds_map_destroy(global.network_objects_map);
buffer_delete(network_buffer);