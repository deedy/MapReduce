let (key, value) = Program.get_input() in
let lst = List.map String.lowercase (Util.split_words value) in
let output = List.fold_left (fun acc word -> (word,key)::acc) [] lst in
Program.set_output (output)
