(** 
 * `map kv_pairs shared_data map_filename` initializes mappers and uses them to
 *   compute the mapping of `kv_pairs` using the code stored in `map_filename`,
 *   and additionally provides `shared_data` accessible to all mappers.
 * Returns: list of (key, value) from mapping `kv_pairs`
 *)
val map : (string * string) list -> string -> string -> (string * string) list

(**
 * `combine kv_pairs` combines the list of (key, value) pairs into a list of
 *   (key, value list) pairs, such that each key in `kv_pairs` occurs once
 *   in the returned list, and for every key in the returned list, its list of
 *   values contains every single value that it mapped to in `kv_pairs`.
 * Returns: list of (key, value list) pairs 
 *)
val combine : (string * string) list -> (string * string list) list

(**
 * `reduce kvs_pairs shared_data reduce_filename` initializes reducers and
 *   uses them to compute the reduction of `kvs_pairs` using the code stored
 *   in `reduce_filename`, and additionally provides `shared_data`
 *   accessible to all reducers.
 * Returns: list of (key, value list) pairs from reducing `kvs_pairs` 
 *)
val reduce : (string * string list) list -> string -> string -> (string * string list) list

(**
 * `map_reduce app_name mapper reduce filename` performs the map reduce 
 *   operations specified by the key `app_name` on the contents of the file.
 * Returns: a two-tuple containing a hashtable of id (string), title pairs
 *   from the input and the MapReduce output.
 *)
val map_reduce : string -> string -> string -> string -> (string, string) Hashtable.t * (string * string list) list
