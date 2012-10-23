type connection

(**
 * `init addr retries` attempts to initalize a connection with addr, retrying at
 * most `retries` times. If initialization succeeds, all subsequent outputs
 * using this connection will be retried up to `retries` times.
 * Returns: `Some c` where `c` is the initialized connection to `addr`
 * and `None` if initialization failed 
 *)
val init : Unix.sockaddr -> int -> connection option

(**
 * `input conn` blocks until a value is present on `conn`, 
 * or the connection closes.
 *
 * Returns: `Some v` if the read on conn succeeded, 
 * where `v` is the value present on `conn`,
 * and `None` otherwise 
 *)
val input : connection -> 'a option

(**
 * `output conn value` sends `value` through `conn`, 
 * retrying up to `retries` times 
 *  (`retries` is defined in connection initialization).
 * Returns: whether the output succeeded. 
 *)
val output : connection -> 'a -> bool

(** `close conn` closes `conn` and all associated file descriptors *)
val close : connection -> unit

(**
 * Students: don't call this.
 *
 * Generates a connection object based on an already opened socket. 
 *)
val server : Unix.sockaddr -> Unix.file_descr -> connection
