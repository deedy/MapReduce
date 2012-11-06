let (key, values) = Program.get_input() in
let sum = List.fold_left (fun acc v -> acc + (int_of_string v)) 0 values in
    Program.set_output [string_of_int sum]
