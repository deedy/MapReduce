
open Protocol

(* I was going to make a type of Mappers of int list ref or something like that,
 * but updating it inside of the handle_request function became very hard to 
 * make thread safe... so I'm just making it a reference to a list. *)
let mappers : worker_id list ref = ref []
let reducers : worker_id list ref = ref []
let mlock = Mutex.create()
let rlock = Mutex.create()

let send_response client response =
  let success = Connection.output client response in
    (if not success then
      (Connection.close client;
       print_endline "Connection lost before response could be sent.")
    else ());
    success

(* This is just simple case handling. Not much to say here. *)
let rec handle_request client =
  match Connection.input client with
    Some v ->
      begin
        match v with
          InitMapper (source, shared_data) ->
            (match Program.build source with
                 (None, error) -> 
                    if send_response client (Mapper (None, error)) then
                      handle_request client
                    else ()
               | (Some(id), str) ->
                    Program.write_shared_data id shared_data;
                    Mutex.lock mlock;
                    mappers := id::(!mappers);
                    Mutex.unlock mlock;
                    if send_response client (Mapper (Some(id),str)) then
                      handle_request client
                    else ()
            )
        | InitReducer source ->
           (match Program.build source with
                (None, error) ->
                   if send_response client (Reducer (None, error)) then
                     handle_request client
                   else ()
              | (Some(id),str) ->
                  Mutex.lock rlock;
                  reducers := id::(!reducers);
                  Mutex.unlock rlock;
                  if send_response client (Reducer (Some(id),str)) then
                    handle_request client
                  else ()
           )
        | MapRequest (id, k, v) ->
            let find_id ele = (ele = id) in
            Mutex.lock mlock;
            if List.exists find_id (!mappers)
            then(Mutex.unlock mlock;
              try
                match Program.run id (k,v) with 
                     None -> if send_response client 
                       (RuntimeError(id,"Mapper returned no result"))
                       then handle_request client
                       else ()
                   | Some(lst) -> if send_response client 
                       (MapResults(id,(lst)))
                       then handle_request client
                       else ()
              with _ as e -> if send_response client 
                (RuntimeError(id,(Printexc.to_string e)))
                then handle_request client
                else ()
            )
            else(
              Mutex.unlock mlock;
              if send_response client (InvalidWorker(id)) 
              then handle_request client
              else ()
            )
        | ReduceRequest (id, k, v) -> 
            let find_id ele = (ele = id) in
            Mutex.lock rlock;
            if List.exists find_id (!reducers)
            then(Mutex.unlock rlock;
              try
                match Program.run id (k,v) with 
                     None -> if send_response client 
                       (RuntimeError(id,"Reducer returned no result"))
                       then handle_request client
                       else ()
                   | Some(lst) -> if send_response client 
                       (ReduceResults(id,(lst)))
                       then handle_request client
                       else ()
              with _ as e -> if send_response client 
                (RuntimeError(id,(Printexc.to_string e)))
                then handle_request client
                else ()
            )
            else(
              Mutex.unlock rlock;
              if send_response client (InvalidWorker(id)) 
              then handle_request client
              else ()
            )
      end
  | None ->
      Connection.close client;
      print_endline "Connection lost while waiting for request."
