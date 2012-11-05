open Protocol

let mappers = Hashtable.create 100 Hashtbl.hash

let reducers = Hashtable.create 100 Hashtbl.hash

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
            let result = Program.build source in
            begin match result with
            | (Some id, s) -> Hashtable.add mappers id s
            | _ -> () end;
            if send_response client result then handle_request client 
            else failwith "Connection closed"
        | InitReducer source ->
            print_endline "initreducer1"; 
            let result = Program.build source in
            print_endline "initreducer";
            begin match result with
            | (Some id, s) -> Hashtable.add reducers id s
            | _ -> () end;
            print_endline "initreducer2";
            if send_response client result then (print_endline "initreducer3"; 
              handle_request client) 
            else failwith "Connection closed" 
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

