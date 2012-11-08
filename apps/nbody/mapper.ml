let (bodies_array : Util.body array ) = 
  Util.unmarshal (Program.get_shared_data()) in
let (key_m, value_m) = Program.get_input() in
let key = int_of_string key_m in
let (_,pos_this,_) = Array.get bodies_array key in 
let foo acc (mass,pos,(velx,vely)) =
  if (mass = 0.) then acc else 
  let distance = Plane.distance pos_this pos in 
  let accel_mag = if (compare distance 0.0) = 0 then
              0.0 else ( Util.cBIG_G *. mass )/.(distance**2.)  in
  if (accel_mag = 0.0) then (key_m,Util.marshal (0.0,0.0))::acc else
  let unit_vec = Plane.unit_vector pos_this pos in
  let accel = Plane.scale_point accel_mag unit_vec in
  (key_m,Util.marshal accel)::acc in
let output = Array.fold_left foo [] bodies_array in 
Program.set_output (output) 
