//Client side Input Send
if(has_input_authority){
	if(keyboard_check(vk_anykey) || mouse_check_button(mb_any)){
		network_outgoing_input_data.hmove = keyboard_check(vk_right) - keyboard_check(vk_left);
		network_outgoing_input_data.vmove = keyboard_check(vk_down) - keyboard_check(vk_up);
		network_outgoing_input_data.mbleft = mouse_check_button_pressed(mb_left);
		network_outgoing_input_data.mbright = mouse_check_button_pressed(mb_right);
	
		NetworkSendInput(net_id, network_outgoing_input_data);
	}
}

if(global.is_server){
	//Check Client Input And Process
	if(network_received_input_data != -1){
		x += network_received_input_data.hmove * spd;
		y += network_received_input_data.vmove * spd;
		
		network_received_input_data = -1;
	}
	
	NetworkSetVariable(net_id, -1, {
		x: x,
		y: y,
	}, -1);
}