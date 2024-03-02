function GetRandomHash(count){
	var _hash = "";
	var _chars = "1234567890ABCDEFGHIJKLMNOPQRSTUVXYZ";
    repeat(count){
		_hash += string_char_at(_chars,irandom(string_length(_chars)));
	}
	return _hash;
}