let graph = Util.unmarshal (Program.get_shared_data()) in
let (key_m,value_m) = Program.get_input() in
let value = Util.unmarshal value_m in
let key = Util.unmarshal key_m in
let edges = Array.get graph key in
let per_node = value /. (float_of_int (List.length edges)) in
let output = List.fold_left 
  (fun acc ele -> (Util.marshal ele,Util.marshal per_node)::acc) [] edges in 
Program.set_output (output)
