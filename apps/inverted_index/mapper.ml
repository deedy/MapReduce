let (key, value) = Program.get_input() in
let output = List.fold_left 
  (fun acc word -> (word,key)::acc) [] 
  (List.map String.lowercase (Util.split_words value)) 
in Program.set_output (output)
