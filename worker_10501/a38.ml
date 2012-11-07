(* let _ = print_endline ("ADSDAS") in
let (bodies_array : Util.body array ) = Util.unmarshal (Program.get_shared_data()) in
let (key_m,value_m) = Program.get_input() in
let key = int_of_string key_m in
let (_,pos_this,_) = Array.get bodies_array key in 
let foo acc (mass,pos,(velx,vely)) =
  if (mass=(-1.)) then acc else 
  let accel_mag = ( Util.cBIG_G *. mass )/.(Plane.distance pos pos_this) in
  let unit_vec = ((fst(pos) -. fst(pos_this)),(snd(pos) -. snd(pos_this))) in
  let accel = ((fst(unit_vec) *. accel_mag),(snd(unit_vec) *. accel_mag)) in
  (Util.marshal key,Util.marshal accel)::acc in
let output = Array.fold_left foo [] bodies_array in 
Program.set_output (output) *)

let (bodies_array : Util.body array ) = Util.unmarshal (Program.get_shared_data()) in
let (key_m, value_m ) = Program.get_input() in
let key = int_of_string key_m in
let (_,pos_this,_) = Array.get bodies_array key in 
let foo acc (mass,pos,(velx,vely)) =
  if (mass=(-1.)) then acc else acc in
Program.set_output (List.fold_left (fun acc k -> (key_m, "1")::acc) []
                   (List.map String.lowercase (Util.split_words value_m)))
