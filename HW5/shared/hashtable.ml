type ('a, 'b) t' = Empty | Cell of 'a * 'b
  and ('a, 'b) t = (('a, 'b) t') array * ('a -> int)

exception Not_found

let create (capacity : int) (hash : 'a -> int) : ('a, 'b) t = 
  Array.make capacity Empty, hash

let add ((table, hash) : ('a, 'b) t) (key : 'a) (value : 'b) : unit =
  Array.set table (hash key) (Cell (key,value))

let find ((table, hash) : ('a, 'b) t) (key : 'a) : 'b = 
  match Array.get table (hash key) with 
  | Empty -> raise Not_found 
  | Cell (k,v) -> v

let mem ((table, hash) : ('a, 'b) t) (key : 'a) : bool = 
  match Array.get table (hash key) with Empty -> false | _ -> true

let remove ((table, hash) : ('a, 'b) t) (key : 'a) : unit =
  Array.set table (hash key) Empty

let iter (f : 'a -> 'b -> unit) ((table, hash) : ('a, 'b) t) : unit = 
  Array.iter (fun x -> match x with Empty -> () | Cell (k,v) -> f k v) table

let fold (f : 'a -> 'b -> 'c -> 'c) ((table, hash) : ('a, 'b) t) (init : 'c) : 'c =
  Array.fold_left 
    (fun x c -> match x with Empty -> c | Cell (k,v) -> f k v c) init table

let length ((table, hash) : ('a, 'b) t) : int = Array.length table
