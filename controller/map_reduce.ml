open Util
open Worker_manager

(* TODO implement these *)
let map kv_pairs shared_data map_filename : (string * string) list = 
  let q = initialize_mappers map_filename shared_data in
  let tp = Thread_pool.create 50 in
  let f () = failwith "" 

let combine kv_pairs : (string * string list) list = 
  let t = Hashtable.create (List.length kv_pairs) Hashtbl.hash in
  let helper t (k,v) = 
    if Hashtable.mem t k then Hashtable.add t k (v::(Hashtable.find t k))
    else Hashtable.add t k [v]; t in
  let new_t = List.fold_left helper t kv_pairs in
  let lst = ref [] in
  Hashtable.iter (fun k v -> lst := (k,v)::(!lst)) new_t; !lst

let reduce kvs_pairs shared_data reduce_filename : (string * string list) list =
  let q = initialize_reducers reduce_filename shared_data in
  let helper acc (k,vs) = match reduce (pop_worker q) k vs with
    | None -> failwith "Implement fault tolerance"
    | Some lst -> (k,lst)::acc in
  List.fold_left helper [] kvs_pairs

let map_reduce (app_name : string) (mapper : string) 
    (reducer : string) (filename : string) =
  let app_dir = Printf.sprintf "apps/%s/" app_name in
  let docs = load_documents filename in
  let titles = Hashtable.create 16 Hashtbl.hash in
  let add_document (d : document) : (string * string) =
    let id_s = string_of_int d.id in
    Hashtable.add titles id_s d.title; (id_s, d.body) in
  let kv_pairs = List.map add_document docs in
  let mapped = map kv_pairs "" (app_dir ^ mapper ^ ".ml") in
  let combined = combine mapped in
  let reduced = reduce combined  "" (app_dir ^ reducer ^ ".ml") in
  (titles, reduced)
