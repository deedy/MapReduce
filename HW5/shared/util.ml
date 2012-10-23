type document = {id : int; title : string; body : string}

type matrix = int array array

type website = {pageid : int; pagetitle : string; links : int list}

type mass = Plane.scalar

type location  = Plane.point

type velocity  = Plane.vector

type body = mass * location * velocity

let cBIG_G : Plane.scalar = 6.67 *. (10.**(-11.))

(**
 * Computes word vectors for a set of documents. The given file should
 * contain a list of documents: one per line. Each document is of the
 * format: "id @ title @ body" such that '@' does not appear in the title
 * or body.
 *)
let load_documents (filename : string) : document list =
  let f = open_in filename in
  let rec next accum =
    match (try Some (input_line f) with End_of_file -> None) with
    | None -> accum
    | Some line ->
      (match Str.split (Str.regexp "@\\|$") line with
        | [id; title; body] ->
          next ({id = int_of_string id; title = title; body = body} :: accum)
        | _ -> failwith "malformed input") in
  let docs = next [] in
  close_in f;
  docs

(** `load_matrix fname` creates a matrix from the file at `fname` *)
let load_matrix (filename : string) : matrix =
  let file = open_in filename in
  let intlist_of_line line = 
    let rec to_int xs k = 
      match xs with
      | [] -> k []
      | h::t -> to_int t (fun x -> k (int_of_string h :: x)) in
    let space_separated = Str.split (Str.regexp "[ \t]+") line in
    to_int space_separated (fun x -> x) in
  let rec parse k = 
    try 
      let line = input_line file in
      parse (fun x -> k (Array.of_list (intlist_of_line line) :: x))
    with
      End_of_file -> k [] in
  Array.of_list (parse (fun x -> x))

let load_websites (filename : string) : website list =
  let f = open_in filename in
  let rec next accum =
    match (try Some(input_line f) with End_of_file -> None) with
      None -> accum
     |Some line -> (match Str.split (Str.regexp "@\\|$") line with
                      [id; title; links] ->
                        next ({pageid = int_of_string id; pagetitle = title;
                        links = List.map (fun x -> int_of_string x)
                          (Str.split (Str.regexp ",") links)}::accum)
                     |[id;title] -> next ({pageid = int_of_string id;
                                          pagetitle = title; links = []}::accum)
                     |_ -> failwith "malformed input") in
  let sites = next [] in
    close_in f;
    sites

(** 
 * `next_level n` returns the smallest number 2^i, such that 2^i >= n 
 * a.k.a. takes `n` TO THE NEXT LEVEL @mcl83
 *)
let next_level (n : int) : int = 
  if n = 0 then 1 else
  let n = n - 1 in
  let n = n lor (n lsr 1) in
  let n = n lor (n lsr 2) in
  let n = n lor (n lsr 4) in
  let n = n lor (n lsr 8) in
  let n = n lor (n lsr 16) in
  n + 1

let print_kvs (kvs_list : (string * string list) list) : unit =
  List.iter
    (fun (k, vs) ->
      let s = match vs with
        | [] -> ""
        | _ -> Printf.sprintf "'%s'" (String.concat "', '" vs) in
      Printf.printf "Key: {'%s'} Values: {%s}\n" k s)
    (List.sort (fun (k1, _) (k2, _) -> compare k1 k2) kvs_list)

let print_combine_results (kvs_list : (string * string list) list) : unit =
  print_endline "Combine Results";
  print_kvs kvs_list

let print_map_results (kv_list : (string * string) list) : unit =
  print_endline "Map Results";
  List.iter
    (fun (k, v) -> Printf.printf "Key: {'%s'} Value: {'%s'}\n" k v)
    (List.sort (fun (k1, _) (k2, _) -> compare k1 k2) kv_list)

let print_page_ranks (pageranks : (int * float) list) : unit =
  List.iter (fun (k, v) -> Printf.printf ("Page: {'%d'} PageRank: {%f}\n") k v)
     (List.sort (fun (k1, _) (k2, _) -> compare k1 k2) pageranks)

let print_reduce_results (kvs_list : (string * string list) list) : unit =
  print_endline "Reduce Results";
  print_kvs kvs_list

(* Returns the entire contents of the provided filename *)
let read_whole_file filename =
  let file = open_in_bin filename in
  let size = in_channel_length file in
  let contents = String.create size in
    really_input file contents 0 size;
    close_in_noerr file;
    contents

(**
 * `resize_matrix m n` creates an `r`-by-`c` matrix using 
 * entries from `m` or zeroes if an entry does not exist.
 *)
let resize_matrix (m : matrix) (r : int) (c : int) : matrix = 
  let rows, cols = Array.length m, Array.length m.(0) in
  Array.init r (fun row -> 
    Array.init c (fun col -> 
      if row < rows && col < cols then m.(row).(col) else 0))

(* Splits a string into words *)
let split_words = Str.split (Str.regexp "[^a-zA-Z0-9]+")

(* Print the x and y position of each body, in order of ascending id *)
let string_of_bodies (reduce_results : (string * body) list) : string = 
  List.fold_left (fun acc (_,(_,(x,y),_)) -> 
    (Printf.sprintf "%f %f %d\n" x y 0) ^ acc)
    "" (List.sort (fun (x,_) (y,_) -> compare x y) reduce_results)

(* marshaling *)
let marshal x = Marshal.to_string x []
let unmarshal x = Marshal.from_string x 0
