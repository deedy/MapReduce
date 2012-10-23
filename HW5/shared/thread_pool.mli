(*
 * THREAD POOL - on creation, a set of worker threads are started.
 * Work to be done is added to the thread pool, and an available worker
 * thread gets to that work when it can. There are no guarantees about
 * when the work will be done or in what order. 
 *)

type pool

(*
 * `No_workers` exception is thrown if `add_work` is called when the
 * threadpool is being shut down. The work is not added. 
 *)
exception No_workers

(**
 * `create n` initializes a thread pool with `n` worker threads 
 *)
val create : int -> pool

(**
 * `add_work job pool` puts `job` on the work queue for `pool`.
 *)
val add_work : (unit -> unit) -> pool -> unit

(**
 * `destroy pool` stops all threads in `pool`. 
 * Waits for working threads to finish.
 *)
val destroy : pool -> unit
