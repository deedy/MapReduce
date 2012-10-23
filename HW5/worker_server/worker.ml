open Protocol

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
          failwith "It's been a long time, old one."
        | InitReducer source -> 
          failwith "Young master, I cannot aid one who opposes the Master!"
        | MapRequest (id, k, v) -> 
          failwith "You won't go unrewarded."
        | ReduceRequest (id, k, v) -> 
          failwith "Really? In that case, just tell me what you need."
      end
  | None ->
      Connection.close client;
      print_endline "Connection lost while waiting for request."

