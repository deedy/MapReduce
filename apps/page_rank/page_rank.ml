open Util

let map_reduce (app_name : string) (mapper : string) 
    (reducer : string) (kv_pairs: (string*string) list) (graph_array_m: string)=
  let app_dir = Printf.sprintf "apps/%s/" app_name in
  let mapped = Map_reduce.map kv_pairs graph_array_m (app_dir ^ mapper ^ ".ml") in
  let combined = Map_reduce.combine mapped in
  let reduced = Map_reduce.reduce combined  "" (app_dir ^ reducer ^ ".ml") in
  reduced

let marshal_pairs (kv_pairs: (int*float) list) : (string*string) list = 
  List.rev (List.fold_left (fun acc (id,rank) -> 
         (marshal id, marshal rank)::acc) [] kv_pairs)

let unmarshal_pairs (kvs_pairs: (string*string list) list) : (int*float) list = 
	  List.rev (List.fold_left (fun acc (id,rank_list) -> 
	  	     (unmarshal id, unmarshal (List.hd(rank_list)))::acc) [] kvs_pairs)

let main (args : string array) : unit = 
  if Array.length args <= 3 then
    Printf.printf "Usage: page_rank <filename> <num_iterations>"
  else
    let filename = args.(2) in 
    let iterations = int_of_string args.(3) in
        let _ = print_endline ("reached here") in

    let sites_list = load_websites filename in
    let max_id = List.fold_left (fun acc ele -> 
    	if ele.pageid > acc then ele.pageid else acc) (-1) sites_list in
    let graph_array = Array.make (max_id+1) [] in
    let _ = List.fold_left (fun acc site -> 
      Array.set graph_array site.pageid site.links; acc) 0 sites_list in
    let n = Array.length graph_array in
    let kv_pairs = List.rev (List.fold_left (fun acc ele ->
       (ele.pageid,(1.0/.(float_of_int n)) )::acc) [] sites_list) in
    let rec regenerate_ranks (kv_pairs: (int*float) list) (iterations: int) : (int*float) list =
       if (iterations=0) then kv_pairs else
       let kv_pairs_m = marshal_pairs kv_pairs in
       let results = map_reduce "page_rank" "mapper" "reducer" kv_pairs_m 
         (marshal graph_array) in
       let kvs_pairs = unmarshal_pairs results in
       regenerate_ranks kvs_pairs (iterations-1) in
    let results = regenerate_ranks kv_pairs iterations in
    print_page_ranks results





