(*
 * Initial bodies for nbody simulation. The first value of the tuple
 * is the number of bodies in the list, which the GUI depends upon. 
 * The list contains pairs of ("bodyId", body)
 *)
val binary_star : string * (string * Util.body) list
val diamond : string * (string * Util.body) list
val orbit : string * (string * Util.body) list
val swarm : string * (string * Util.body) list
val system : string * (string * Util.body) list
val terrible_situation : string * (string * Util.body) list
val zardoz : string * (string * Util.body) list
