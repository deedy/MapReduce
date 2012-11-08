open Protocol

let mappers = Hashtable.create 100 Hashtbl.hash

let reducers = Hashtable.create 100 Hashtbl.hash

let lock = Mutex.create ()

let send_response client response =
  let success = Connection.output client response in
    (if not success then
      (Connection.close client;
       print_endline "Connection lost before response could be sent.")
    else ());
    success

let rec handle_request client =
  match Connection.input client with
    Some v ->
      begin
        match v with
        | InitMapper (source, shared_data) -> 
            begin match Program.build source with
            | (Some id, s) -> if send_response client (Mapper (Some id, s)) then
                (Mutex.lock lock; Hashtable.add mappers id s; Mutex.unlock lock;
                 Program.write_shared_data id shared_data;
                 handle_request client)
            | (None, s) -> if send_response client (Mapper (None, s)) then
                handle_request client end;
        | InitReducer source ->
            begin match Program.build source with
            | (Some id, s) -> if send_response client (Reducer (Some id, s)) then 
                (Mutex.lock lock;
                 Hashtable.add reducers id s; Mutex.unlock lock;
                 handle_request client)
            | (None, s) -> if send_response client (Reducer (None, s)) then
                handle_request client end;
        | MapRequest (id, k, v) -> 
            if Hashtable.mem mappers id then 
              begin match Program.run id (k,v) with
              | None -> if send_response client (RuntimeError (id,"no results")) then
                  handle_request client
              | Some lst -> if send_response client (MapResults (id,lst)) then
                  handle_request client end
            else if send_response client (InvalidWorker id) then handle_request client
        | ReduceRequest (id, k, v) -> 
            if Hashtable.mem reducers id then
              begin match Program.run id (k,v) with
              | None -> if send_response client (RuntimeError (id,"no results")) then
                  handle_request client
              | Some lst -> if send_response client (ReduceResults (id,lst)) then
                  handle_request client end
            else if send_response client (InvalidWorker id) then handle_request client
      end
  | None ->
      Connection.close client;
      print_endline "Connection lost while waiting for request."

