let server = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0
let thread_pool = Thread_pool.create 100

(* create a directory corresponding to the port number *)
let make_dir port =
  let dir = "worker_" ^ (string_of_int port) in
    Program.set_worker_dir dir;
    try Unix.mkdir dir 0o755 with _ -> ()

(* Initialize server socket *)
let init_socket() =
  let port =
    try int_of_string Sys.argv.(1)
    with Invalid_argument _ ->
      failwith "Must provide port number to listen on as first command-line argument" in
    make_dir port;
    Unix.setsockopt server Unix.SO_REUSEADDR true;
    Unix.setsockopt server Unix.SO_KEEPALIVE false;
    Unix.bind server (Unix.ADDR_INET (Unix.inet_addr_any, port));
    Unix.listen server 100

(* Main loop: spawns thread to handle requests *)
let _ =
  init_socket();
  while true do
    try
      let (client, addr) = Unix.accept server in
      Thread_pool.add_work
        (fun _ -> Worker.handle_request (Connection.server addr client))
        thread_pool
    with e -> Printf.printf "Handling request resulted in exception: %s\n" (Printexc.to_string e)
  done
