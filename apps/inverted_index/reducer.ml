let (key, values) = Program.get_input() in
let sorted_output = List.sort 
  ( fun x y -> compare (int_of_string(x)) (int_of_string(y)) ) values in
let remove_dups acc el =
    match acc with
    | h::t -> if h = el then acc else el::acc
    | [] -> el::[] in
let output = List.fold_left remove_dups [] sorted_output in
Program.set_output (List.rev output)
