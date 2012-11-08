type document = {id : int; title : string; body : string}
type matrix = int array array
type website = {pageid : int; pagetitle : string; links : int list}
type mass = Plane.scalar
type location = Plane.point
type velocity = Plane.vector
type body = mass * location * velocity

val cBIG_G : Plane.scalar

val load_documents : string -> document list
val load_matrix : string -> matrix
val load_websites : string -> website list

val marshal : 'a -> string
val next_level : int -> int

val print_kvs : (string * string list) list -> unit
val print_map_results : (string * string) list -> unit
val print_combine_results : (string * string list) list -> unit
val print_reduce_results : (string * string list) list -> unit
val read_whole_file : string -> string
val split_words : string -> string list
val string_of_bodies : (string * body) list -> string
val resize_matrix : matrix -> int -> int -> matrix

val unmarshal : string -> 'a
