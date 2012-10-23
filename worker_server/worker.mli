(* Responsible for handling client requests, performing the requested action, 
 * and sending results back to the client 
 *)

(**
 * `handle_request client` handles the worker_request that can be read from the
 * `client` connection.
 *
 * If it is an initialization request, then the mapper/reducer is built using
 * `Program.build`, and the result of the build is sent to the client using
 * `send_response`. Additionally, the new mapper/reducer id must be added to the
 * appropriate collection to track active mapper/reducers
 *
 * If it is a map/reduce request, then the id of the worker is verified as
 * being valid and of the right type. If the id is valid, then request is
 * executed using `Program.run`, and the results of this execution are sent
 * back to the requesting client using `send_response`. If the returned value is
 * `None`, then the response is a `RuntimeError`, otherwise the result is wrapped
 * in the correct response type. If the id is invalid, then the client is
 * notified using `send_response`.
 *
 * In all cases, this function calls itself repeatedly until `send_response`
 * fails.
 *
 * Thread-safe 
 *)
val handle_request : Connection.connection -> unit

(**
 * `send_response client response` attempts to send the `worker_response` to the
 * `client` connection. If the response fails, then the connection is closed.
 *
 * Returns: whether the response was sent successfully
 *
 * Thread-safe
 *)
val send_response : Connection.connection -> Protocol.worker_response -> bool
