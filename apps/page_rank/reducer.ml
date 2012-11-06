
	let (key,values) = Program.get_input() in 
let output = List.fold_left (fun acc ele -> acc+. (Util.unmarshal ele)) 
  0. values in
 Program.set_output ([Util.marshal output])
