open Protocol

type worker_type = Map | Reduce

type worker = worker_id * Connection.connection
type mapper = worker
type reducer = worker

type 'a worker_manager = 'a Queue.t * Mutex.t * Condition.t * worker list ref

let address_filename = "addresses"

let retries = 10

let push_worker (queue, lock, condition, _) worker =
  Mutex.lock lock;
  Queue.push worker queue;
  Condition.signal condition;
  Mutex.unlock lock

(* initializes either a mapper or a reducer, depending on worker_type *)
let initialize worker_type source_filename shared_data =
  let (_,_,_,workers) as manager = 
    (Queue.create(), Mutex.create(), Condition.create(), ref []) in
  let addresses = List.rev_map (fun l ->
    match Str.split (Str.regexp ":") l with
    | x::y::[] -> 
        Unix.ADDR_INET (((Unix.gethostbyname x).Unix.h_addr_list.(0)), (int_of_string y))
    | _ -> failwith "Invalid address file")
    (Str.split (Str.regexp "\r?\n") (Util.read_whole_file address_filename)) in
  let connections = List.rev_map (fun a -> Connection.init a retries) addresses in
  let source = Str.split (Str.regexp "\r?\n") (Util.read_whole_file source_filename) in
  let worker_request_wrapper = 
    if worker_type = Map then InitMapper(source, shared_data) 
    else InitReducer(source) in
  let worker_response_wrapper (_, connection) =
    match (Connection.input connection, worker_type) with
    | (Some(Mapper(Some(id), _)), Map) | (Some(Reducer(Some(id), _)), Reduce) -> begin
        push_worker manager (id, connection);
        workers := (id, connection) :: !workers
        end
    | (Some(Mapper(_, error)), _) | (Some(Reducer(_, error)), _) -> 
      Printf.printf "Compilation error: %s\n" error
    | (None, _) -> 
      print_endline "Failed to connect to worker"
    | _ -> 
      print_endline "Worker returned incorrect message type"
  in
  List.iter (fun c ->
    match c with
    | Some(connection) -> 
      if Connection.output connection worker_request_wrapper
      then ignore (Thread.create worker_response_wrapper (-1, connection))
      else ()
    | None -> ()) connections;
  manager

let initialize_mappers = initialize Map 

let initialize_reducers = initialize Reduce

let pop_worker (queue, lock, condition, _) =
  Mutex.lock lock;
  while Queue.is_empty queue do
    Condition.wait condition lock
  done;
  let element = Queue.pop queue in
  Mutex.unlock lock;
  element

let send_request (id, connection) worker_type request =
  if Connection.output connection request then begin
    let result = ref None in
    begin match (Connection.input connection, worker_type) with
    | (Some(InvalidWorker(id)), _) -> 
      Printf.printf"Invalid worker: %d\n" id
    | (Some(RuntimeError(id, error)), _) -> 
      Printf.printf "Runtime error for worker %d: %s\n" id error
    | (Some(MapResults(id, l)), Map) -> 
      result := Some(MapResults(id, l))
    | (Some(ReduceResults(id, l)), Reduce) -> 
      result := Some(ReduceResults(id, l))
    | (None, _) -> begin
      Connection.close connection; 
      Printf.printf "Connection lost to worker: %d\n" id end
    | _ -> 
      Printf.printf "Worker %d returned incorrect message type\n" id end;
    !result end
  else begin
    Connection.close connection; 
    Printf.printf "Connection lost to worker: %d\n" id; 
    None end

let map (id, connection) key value =
  match send_request (id, connection) Map (MapRequest(id, key, value)) with
    None -> None
  | Some(MapResults(_, l)) -> Some(l)
  | _ -> failwith ("Worker manager failed.")

let reduce (id, connection) key values =
  match send_request (id, connection) Reduce (ReduceRequest(id, key, values)) with
    None -> None
  | Some(ReduceResults(_, l)) -> Some(l)
  | _ -> failwith ("Worker manager failed.")

let clean_up_workers (_, lock, _, workers) =
  Mutex.lock lock;
  List.iter (fun (_, connection) -> Connection.close connection) !workers
