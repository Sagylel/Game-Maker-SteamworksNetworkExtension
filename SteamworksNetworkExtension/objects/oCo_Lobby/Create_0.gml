function LobbyStartGame(){
	room_goto(rmGame);
	
	if(global.is_server){
		steam_lobby_set_joinable(false);
	}
}