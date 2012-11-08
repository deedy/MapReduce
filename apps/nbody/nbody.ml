open Util

let map_reduce (app_name : string) (mapper : string) 
    (reducer : string) (kv_pairs: (string*string) list) (shared_data: string)=
  let app_dir = Printf.sprintf "apps/%s/" app_name in
  let mapped = Map_reduce.map kv_pairs shared_data (app_dir ^ mapper ^ ".ml") in
  let combined = Map_reduce.combine mapped in
  let reduced = Map_reduce.reduce combined  "" (app_dir ^ reducer ^ ".ml") in
  reduced


let get_graph_array_from_bodies (bodies : (string*body) list) : body array = 
  let max_id = List.fold_left (fun acc (id,_) -> if ((int_of_string id) > acc) then 
    (int_of_string id) else acc) (-1) bodies in
  let bodies_array = Array.make (max_id+1) (0.,(0.,0.),(0.,0.)) in
  let _ = List.fold_left (fun acc (id,body) -> Array.set bodies_array 
         (int_of_string id) body; acc) 0 bodies in 
  bodies_array

let get_kv_pairs_from_bodies (bodies: (string*body) list ) : (string*string) list = 
  List.rev (List.fold_left (fun acc (id,_) -> (id,"")::acc) [] bodies)


let get_bodies_from_results (results: (string*string list) list) (bodies_array: body array) : (string*body) list =
    let foo acc (id,accel_list) = let iden = int_of_string id in 
      let (mass,(posx,posy),(velx,vely)) = Array.get bodies_array iden in
      let (accx,accy) = unmarshal (List.hd(accel_list)) in
(*       let _ = print_endline (id) in
      let _ = print_string ("Acceleration-X") in
      let _ = print_float (accx) in
      let _ = print_endline ("") in
      let _ = print_string ("Acceleration-Y") in
      let _ = print_float (accy) in
      let _ = print_endline ("") in
      let _ = print_string ("Pos-X") in
      let _ = print_float ((posx+.velx+.(accx/.2.))) in
      let _ = print_endline ("") in
      let _ = print_string ("Pos-Y") in
      let _ = print_float ((posy+.vely+.(accy/.2.))) in
      let _ = print_endline ("") in *)
      (id,(mass,((posx+.velx+.(accx/.2.)),(posy+.vely+.(accy/.2.))),(velx+.accx,vely+.accy)))::acc in

    List.rev (List.fold_left foo [] results)

let new_graph_array (bodies : (string*body) list) (bodies_array: body array) : body array = 
  let _ = List.fold_left (fun acc (id,bod) -> Array.set bodies_array 
         (int_of_string id) bod; acc) 0 bodies in 
  bodies_array

(* Create a transcript of body positions for `steps` time steps *)
let make_transcript (bodies : (string * body) list) (steps : int) : string = 
  let transcript = string_of_bodies bodies in
  let bodies_array = get_graph_array_from_bodies bodies in  
  let kv_pairs_m = get_kv_pairs_from_bodies bodies in 
  let rec regenerate_positions (bodies: (string*body) list) (steps: int) (transcript: string): string = 
    if (steps=0) then transcript else
    let results = map_reduce "nbody" "mapper" "reducer" kv_pairs_m (marshal bodies_array) in
    
    let bodies = get_bodies_from_results results bodies_array in
    let bodies_array = new_graph_array bodies bodies_array in
    let transcript = transcript^(string_of_bodies bodies) in
    let kv_pairs_m = get_kv_pairs_from_bodies bodies in 
    regenerate_positions bodies (steps-1) transcript in

  regenerate_positions bodies steps transcript




let simulation_of_string = function
  | "binary_star" -> Simulations.binary_star
  | "diamond" -> Simulations.diamond
  | "orbit" -> Simulations.orbit
  | "swarm" -> Simulations.swarm
  | "system" -> Simulations.system
  | "terrible_situation" -> Simulations.terrible_situation
  | "zardoz" -> Simulations.zardoz
  | _ -> failwith "Invalid simulation name. Check `shared/simulations.ml`"

let main (args : string array) : unit = 
  if Array.length args < 3 then 
    print_endline "Usage: nbody <simulation> [<outfile>]
  <simulation> is the name of a simulation from shared/simulations.ml
  Results will be written to [<outfile>] or stdout."
  else begin
    let (num_bodies_str, bodies) = simulation_of_string args.(2) in
    let transcript = make_transcript bodies 60 in
    let out_channel = 
      if Array.length args > 3 then open_out args.(3) else stdout in
    output_string out_channel (num_bodies_str ^ "\n" ^ transcript);
    close_out out_channel end
