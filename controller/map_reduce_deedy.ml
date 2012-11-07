open Util
open Worker_manager

(* TODO implement these *)
let map kv_pairs shared_data map_filename : (string * string) list = 
  let manager = Worker_manager.initialize_mappers map_filename shared_data in
  let thread_pool = Thread_pool.create 100 in
  let work_map = Hashtable.create (List.length kv_pairs) Hashtbl.hash in
  let _ = List.fold_left (fun acc ele -> Hashtable.add work_map acc ele;
    (acc+1)) 0 kv_pairs in
  let results_list = Hashtable.create (List.length kv_pairs) Hashtbl.hash in
  let results_lock = Mutex.create() in
  let work_lock = Mutex.create() in
  let map_function (id,(key,value)) () =
    let worker = Worker_manager.pop_worker manager in
      match (Worker_manager.map worker key value) with
      | Some (res) ->
          let _ = Mutex.lock work_lock in
          if (Hashtable.mem work_map id) then 
            let _ = Hashtable.remove work_map id in
            let _ = Mutex.unlock work_lock in
            let _ = Mutex.lock results_lock in
            let _ = Hashtable.add results_list id res in
            let _ = Mutex.unlock results_lock in
            Worker_manager.push_worker manager worker
          else 
            let _ = Mutex.unlock work_lock in
            Worker_manager.push_worker manager worker
      | None -> () (* Failed workers not pushed back onto queue *) 
    in
  let rec continualAdder work_map : (string * string) list = 
    if Hashtable.length work_map = 0 then
      let _ = Thread_pool.destroy thread_pool in
      let _ = Worker_manager.clean_up_workers manager in
      let _  = Mutex.lock results_lock in
      let results = (Hashtable.fold (fun id value acc -> List.fold_left
          (fun acc elm -> elm :: acc) acc value) results_list []) in
      let _ = Mutex.unlock results_lock in
 (*     let _ = print_map_results results in*)
      results
    else
      let _ = print_int  (Hashtable.length work_map) in
      let _ = print_endline ("") in
      let _ = Mutex.lock work_lock in
      let _ = Hashtable.iter (fun id kv -> Thread_pool.add_work (map_function (id,kv)) thread_pool) work_map in
      let _ = Mutex.unlock work_lock in 
	    let _  = Thread.delay 0.1 in 
      continualAdder work_map in

    continualAdder work_map
  
let combine kv_pairs : (string * string list) list = 
  let t = Hashtable.create (List.length kv_pairs) Hashtbl.hash in
  let helper t (k,v) = 
    if Hashtable.mem t k then Hashtable.add t k (v::(Hashtable.find t k))
    else Hashtable.add t k [v]; t in
  let new_t = List.fold_left helper t kv_pairs in
  let lst = ref [] in
  Hashtable.iter (fun k v -> lst := (k,v)::(!lst)) new_t; 
  let combined = !lst in
  combined 



let reduce kvs_pairs shared_data reduce_filename : (string * string list) list =
  let manager = Worker_manager.initialize_reducers reduce_filename shared_data in
  let thread_pool = Thread_pool.create 100 in
  let work_map = Hashtable.create (List.length kvs_pairs) Hashtbl.hash in
  let _ = List.fold_left (fun acc ele -> Hashtable.add work_map acc ele;
    (acc+1)) 0 kvs_pairs in
  let results_list = Hashtable.create (List.length kvs_pairs) Hashtbl.hash in
  let results_lock = Mutex.create() in
  let work_lock = Mutex.create() in
  let reduce_function (id,(key,value)) () =
    let worker = Worker_manager.pop_worker manager in
      match (Worker_manager.reduce worker key value) with
      | Some (res) ->
          let _ = Mutex.lock work_lock in
          if (Hashtable.mem work_map id) then 
            let _ = Hashtable.remove work_map id in
            let _ = Mutex.unlock work_lock in
            let _ = Mutex.lock results_lock in
            let _ = Hashtable.add results_list id (key,res) in
            let _ = Mutex.unlock results_lock in
            Worker_manager.push_worker manager worker
          else 
            let _ = Mutex.unlock work_lock in
            Worker_manager.push_worker manager worker
      | None -> () (* Failed workers not pushed back onto queue *) 
    in
  let rec continualAdder work_map : (string * string list) list = 
    if Hashtable.length work_map = 0 then
      let _ = Thread_pool.destroy thread_pool in
      let _ = Worker_manager.clean_up_workers manager in
      let _  = Mutex.lock results_lock in
      let results = Hashtable.fold (fun id value acc -> value :: acc) 
          results_list [] in
      let _ = Mutex.unlock results_lock in
      let _ = print_reduce_results results in
      results
    else
      let _ = Mutex.lock work_lock in
      let _ = Hashtable.iter (fun id kv -> Thread_pool.add_work (reduce_function (id,kv)) thread_pool) work_map in
      let _ = Mutex.unlock work_lock in 
      let _  = Thread.delay 0.1 in 
      continualAdder work_map in
  continualAdder work_map


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
