//Debug Overlay Variable Update
if(!DEBUG_ENABLED || global.debugging) return;

dbg_var_instance_count = instance_count;
dbg_var_game_seed = random_get_seed();