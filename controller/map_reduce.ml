open Util
open Worker_manager

let map kv_pairs shared_data map_filename : (string * string) list = 
  let num_pairs = List.length kv_pairs in
  let manager = initialize_mappers map_filename shared_data in 
  let t = Hashtable.create (List.length kv_pairs) Hashtbl.hash in
  let i = ref 0 in
  let helper t (k,v) = Hashtable.add t !i (k, v, ref 0); i := !i + 1; t in
  let table = List.fold_left helper t kv_pairs in
  let pool = Thread_pool.create 100 in
  let resultLst = ref [] in 
  let marker = ref 0 in
  let tableLock = Mutex.create () in
  let resultLock = Mutex.create () in
  let rec f i () = 
    Mutex.lock tableLock;
    if Hashtable.mem table i then begin
      let (k,v,c) = Hashtable.find table i in 
      Mutex.unlock tableLock;
      if !c > 5 then failwith "A job has failed" else
      let worker = pop_worker manager in
      match map worker k v with
      | None -> c := !c + 1
      | Some lst -> begin
          Mutex.lock tableLock;
          if Hashtable.mem table i then begin
            Hashtable.remove table i; 
            Mutex.unlock tableLock;
            Mutex.lock resultLock; 
            resultLst := lst::(!resultLst);
            Mutex.unlock resultLock end
          else Mutex.unlock tableLock; 
          Mutex.lock tableLock;
          if Hashtable.length table > 0 then begin
            while Hashtable.mem table !marker = false do
              marker := (!marker + 1) mod num_pairs done;
            Thread_pool.add_work (f !marker) pool; 
            marker := (!marker + 1) mod num_pairs end;
          Mutex.unlock tableLock end;
      push_worker manager worker end
    else Mutex.unlock tableLock in
  Hashtable.iter (fun k v -> Thread_pool.add_work (f k) pool) table;
  while List.length !resultLst < num_pairs do Thread.delay 0.1 done;
  Thread_pool.destroy pool;
  clean_up_workers manager;
  let flatten acc x = List.fold_left (fun a b -> b::a) acc (List.rev x) in
  List.fold_left flatten [] (List.rev !resultLst)

let combine kv_pairs : (string * string list) list = 
  let t = Hashtable.create (List.length kv_pairs) Hashtbl.hash in
  let helper t (k,v) = 
    if Hashtable.mem t k then Hashtable.add t k (v::(Hashtable.find t k))
    else Hashtable.add t k [v]; t in
  let new_t = List.fold_left helper t kv_pairs in
  let lst = ref [] in
  Hashtable.iter (fun k vs -> lst := (k,vs)::(!lst)) new_t; !lst

let reduce kvs_pairs shared_data reduce_filename : (string * string list) list =
  let num_pairs = List.length kvs_pairs in
  let manager = initialize_reducers reduce_filename shared_data in 
  let t = Hashtable.create (List.length kvs_pairs) Hashtbl.hash in
  let i = ref 0 in
  let helper t (k,vs) = Hashtable.add t !i (k, vs, ref 0); i := !i + 1; t in
  let table = List.fold_left helper t kvs_pairs in
  let pool = Thread_pool.create 100 in
  let resultLst = ref [] in 
  let marker = ref 0 in
  let tableLock = Mutex.create () in
  let resultLock = Mutex.create () in
  let rec f i () = 
    Mutex.lock tableLock;
    if Hashtable.mem table i then begin
      let (k,vs,c) = Hashtable.find table i in 
      Mutex.unlock tableLock;
      if !c > 5 then failwith "A job has failed" else
      let worker = pop_worker manager in
      match reduce worker k vs with
      | None -> c := !c + 1
      | Some lst -> begin
          Mutex.lock tableLock; 
          if Hashtable.mem table i then begin
            Hashtable.remove table i; 
            Mutex.unlock tableLock;
            Mutex.lock resultLock; 
            resultLst := (k,lst)::(!resultLst); 
            Mutex.unlock resultLock end
          else Mutex.unlock tableLock; 
          Mutex.lock tableLock;
          if Hashtable.length table > 0 then begin
            while Hashtable.mem table !marker = false do
              marker := (!marker + 1) mod num_pairs done;
            Thread_pool.add_work (f !marker) pool; 
            marker := (!marker + 1) mod num_pairs end;
          Mutex.unlock tableLock end;
      push_worker manager worker end
    else Mutex.unlock tableLock in
  Hashtable.iter (fun k v -> Thread_pool.add_work (f k) pool) table;
  while List.length !resultLst < num_pairs do Thread.delay 0.1 done;
  Thread_pool.destroy pool;
  clean_up_workers manager; 
  !resultLst

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
