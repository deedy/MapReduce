open Util
open Worker_manager

(* TODO implement these *)
let map kv_pairs shared_data map_filename : (string * string) list = 
  failwith "Go back whence you came! Trouble the soul of my Mother no more!"
let combine kv_pairs : (string * string list) list = 
  failwith "You have been doomed ever since you lost the ability to love."
let reduce kvs_pairs shared_data reduce_filename : (string * string list) list =
  failwith "The only thing necessary for evil to triumph is for good men to do nothing"

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
