(* Responsible for building and running mappers and reducers *)

(**
 * Students: don't call this
 *
 * Used to track the directory where the workers are stored *)
val set_worker_dir : string -> unit

(**
 *
 * `get_input ()` returns input for the calling worker thread that
 * is started using `Program.run`
 *
 * Thread-safe
 *)
val get_input : unit -> 'a

(**
 * `set_output out` sets the input of the calling worker thread to `out` 
 * so that it can be retrieved by `Program.run` when the worker terminates
 *
 * Thread-safe 
 *)
val set_output : 'b list -> unit

(**
 * `get_shared_data ()` returns shared data accessible to calling worker
 *
 * Thread-safe
 *)
val get_shared_data : unit -> string

(**
 * `write_shared_data id shared_data` writes shared_data accessible to 
 * worker `id`
 *)
val write_shared_data : Protocol.worker_id -> string -> unit

(** 
 *
 *`build source` builds the provided source, returning
 *  `(Some(id), "")` if compilation succeeds, where `id` = compiled program id,
 *  and `(None, error_message)` otherwise 
 *
 * Thread-safe
 *)
val build : string list -> Protocol.worker_id option * string

(**
 * `run id input` runs the program identified by `id`, 
 *  providing `input` as input.
 * Returns `Some(result)` if the program returns a result
 *  and `None` otherwise 
 *
 * This function blocks until the program terminates. Exceptions raised by the
 * program won't be caught.
 *
 * Thread-safe
 *)
val run : Protocol.worker_id -> 'a -> 'b list option
