(** A table that associates keys of type 'a with values of type 'b *)
type ('a, 'b) t

(**
 * `create n hash` uses `hash` to associate a positive integer with
 *  each key of type 'a.
 * Running time: O(n)
 * Returns: an empty hashtable of size `n` 
 *)
val create : int -> ('a -> int) -> ('a, 'b) t

(** 
 * `add table key value` adds an association between 
 * `key` and `value` in `table`. 
 * Any old value association with key is replaced.
 * Running time: O(1) 
 *)
val add : ('a, 'b) t -> 'a -> 'b -> unit

(**
 * `find table key` returns the most recent value associated with `key`
 * Raises: Not_found if key has no associated value
 * Running time: O(1) 
 *)
val find : ('a, 'b) t -> 'a -> 'b

(**
 * `mem table key` returns `true` if and only if `key` is present in `table`.
 * Running time: O(1) 
 *)
val mem : ('a, 'b) t -> 'a -> bool

(**
 * `remove table key` removes the value associated with `key` in `table`
 * If `key` has no associated value, this function does nothing.
 * Running time: O(1) 
 *)
val remove : ('a, 'b) t -> 'a -> unit

(** 
 * `iter f table` applies `f` to all the associations stored in `table`. 
 * `f` receives the key as the first argument and the value as
 * the second argument.
 * Running time: O(n * runtime of `f`) 
 *)
val iter : ('a -> 'b -> unit) -> ('a, 'b) t -> unit

(**
 * `fold f table init` folds over table using `f` with initial value `init`
 * Must be tail-recursive.
 * Running time: O(n * runtime of f) 
 *)
val fold : ('a -> 'b -> 'c -> 'c) -> ('a, 'b) t -> 'c -> 'c

(**
 * `length table` returns the number of associations stored in `table`. 
 * Running time: O(1). 
 *)
val length : ('a, 'b) t -> int
