open Protocol

let includes = "str.cma -I shared shared/hashtable.cma shared/util.cma"
let ocaml_lib_dir = "/usr/local/lib/ocaml"
let worker_dir = ref ""
let set_worker_dir dir = worker_dir := dir

let input_collection = Hashtbl.create 0
let output_collection = Hashtbl.create 0
let shared_data = Hashtbl.create 0
let thread_worker_map = Hashtbl.create 0

let input_lock = Mutex.create()
let output_lock = Mutex.create()
let run_lock = Mutex.create()
let shared_data_lock = Mutex.create()
let thread_worker_lock = Mutex.create()

let dynlink_init = ref false

let get_input () =
  Mutex.lock input_lock;
  let inp = Marshal.from_string (Hashtbl.find input_collection (Thread.self())) 0 in
    Mutex.unlock input_lock;
    inp

let set_input inp =
  Mutex.lock input_lock;
  Hashtbl.replace input_collection (Thread.self()) (Marshal.to_string inp []);
  Mutex.unlock input_lock

let get_output () =
  Mutex.lock output_lock;
  let out = Marshal.from_string (Hashtbl.find output_collection (Thread.self())) 0 in
    Mutex.unlock output_lock;
    out

let set_output out =
  Mutex.lock output_lock;
  Hashtbl.replace output_collection (Thread.self()) (Marshal.to_string out []);
  Mutex.unlock output_lock

let get_shared_data () =
  Mutex.lock thread_worker_lock;
  let worker_id = Hashtbl.find thread_worker_map (Thread.self()) in
    Mutex.unlock thread_worker_lock;
    Mutex.lock shared_data_lock;
    let data = Hashtbl.find shared_data worker_id in
      Mutex.unlock shared_data_lock;
      data

let set_thread_worker_mapping id =
  Mutex.lock thread_worker_lock;
  Hashtbl.replace thread_worker_map (Thread.self()) id;
  Mutex.unlock thread_worker_lock

(* Used to assign each compiled mapper/reducer a unique id *)
let counter = ref 0
let counter_lock = Mutex.create()
let next_id () =
  let _ = Mutex.lock counter_lock in
  let _ = counter := !counter + 1 in
  let id = !counter in
  let _ = Mutex.unlock counter_lock in id

let write_shared_data id data =
  Mutex.lock shared_data_lock;
  Hashtbl.replace shared_data id data;
  Mutex.unlock shared_data_lock

let build source =
  if Sys.os_type <> "Win32" then Sys.set_signal Sys.sigchld Sys.Signal_default else ();
  let id = next_id () in
  let prefix = !worker_dir ^ "/a" ^ (string_of_int id) in
  let out = open_out (prefix ^ ".ml") in
    List.iter (fun x -> output_string out (x ^ "\n")) source;
    flush out;
    close_out_noerr out;
    let compile_cmd = Printf.sprintf
      "ocamlc -thread -c -I worker_server worker_server/program.cmo unix.cma threads.cma %s %s.ml 2> %s_build_output"
      includes prefix prefix in
    match Unix.system compile_cmd with
      Unix.WEXITED code ->
        if code = 0 then (Some id, "")
        else let build_results = Util.read_whole_file (prefix ^ "_build_output") in
        (None, build_results)
    | _ -> (None, "Compilation failed due to system error")

let run id input_data =
  set_input input_data;
  set_thread_worker_mapping id;
  Mutex.lock run_lock;
  try
    if not !dynlink_init then
      begin
        let ocaml_lib =
          if Sys.os_type = "Win32" then Sys.getenv "OCAMLLIB"
          else if Sys.os_type = "Unix" then
            if Sys.is_directory "/usr/lib/ocaml/" then
              "/usr/lib/ocaml"
            else if Sys.is_directory "/usr/local/lib/ocaml/" then
              "/usr/local/lib/ocaml"
            else
              raise (Failure "OCaml lib path not found. Please find and change this file manually")
          else if Sys.os_type = "Cygwin" then
            Sys.getenv "OCAMLLIB" (* NOTE: IF this fails, change to /usr/lib/ocaml *)
          else
            raise (Failure "Error (program.ml/run): OS not supported. If you have this case, contact the TAs with your specific issue")
        in
        let extras = if Sys.os_type = "Win32" then Str.split (Str.regexp ";") (Sys.getenv "PATH") else [] in
        Dynlink.add_interfaces
          ["Pervasives"; "Util"; "Program"; "Thread"]
          ([ocaml_lib; "shared"; "worker_server"; ocaml_lib ^ "/threads"; Sys.getcwd()] @ extras);
        Dynlink.allow_unsafe_modules true;
        dynlink_init := true
      end
    else ();
    Dynlink.loadfile (!worker_dir ^ "/a" ^ (string_of_int id) ^ ".cmo");
    let result = get_output() in
    Mutex.unlock run_lock;
    Some result
  with
    Not_found -> (Mutex.unlock run_lock; None)
  | Dynlink.Error(e) -> (Mutex.unlock run_lock;
                         print_endline (Dynlink.error_message e);
                         raise (Dynlink.Error e))
  | e -> (Mutex.unlock run_lock; raise e)
