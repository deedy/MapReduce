type ('a, 'b) t = (('a * 'b) list) array * ('a -> int) * int ref

exception Not_found

let create (capacity : int) (hash : 'a -> int) : ('a, 'b) t = 
  (Array.make capacity [], hash, ref 0)

let add ((arr,hash,len) : ('a, 'b) t) (key : 'a) (value : 'b) : unit =
  Array.set arr (hash key) ((key,value)::(Array.get arr (hash key)));
  len := !len + 1

let find ((arr,hash,len) : ('a, 'b) t) (key : 'a) : 'b = 
  match Array.get arr (hash key) with 
  | [] -> raise Not_found 
  | lst -> let helper a (k,v) = if k=key then Some v else a in
      let value = List.fold_left helper None lst in
      begin match value with
      | None -> raise Not_found
      | Some v -> v end

let mem ((arr,hash,len) : ('a, 'b) t) (key : 'a) : bool = 
  match Array.get arr (hash key) with 
  | [] -> false 
  | lst -> List.fold_left (fun a (k,v) -> k=key || a) false lst

let remove ((arr,hash,len) : ('a, 'b) t) (key : 'a) : unit =
  match Array.get arr (hash key) with
  | [] -> ()
  | lst -> let helper a (k,v) = if k=key then a else (k,v)::a in
      let new_lst = List.fold_left helper [] (List.rev lst) in
      Array.set arr (hash key) new_lst

let iter (f : 'a -> 'b -> unit) ((arr,hash,len) : ('a, 'b) t) : unit = 
  let helper x = match x with
    | [] -> ()
    | lst -> List.iter (fun (k,v) -> f k v) lst in
  Array.iter helper arr

let fold (f : 'a->'b->'c->'c) ((arr,h,l) : ('a, 'b) t) (init : 'c) : 'c =
  let helper acc x = match x with
    | [] -> acc
    | lst -> List.fold_left (fun c (k,v) -> f k v c) acc lst in
  Array.fold_left helper init arr

let length ((arr,hash,len) : ('a, 'b) t) : int = !len
