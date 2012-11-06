let (key, value) = Program.get_input() in
Program.set_output (List.fold_left (fun acc k -> (k, "1")::acc) []
                   (List.map String.lowercase (Util.split_words value)))
