try
let (key,values) = Program.get_input() in 
let output = List.fold_left (fun acc ele -> 
	let (accel:(float*float)) = Util.unmarshal ele in 
	((fst(accel)+.fst(accel)),(snd(accel)+.(snd(accel)))) )
  (0.,0.) values in
 Program.set_output ([Util.marshal output])
with exn -> raise exn
