open Util

let main (args : string array) : unit = 
  if Array.length args < 3 then
    Printf.printf "Usage: page_rank <num_iterations> <filename>"
  else
    failwith "You're not my mother. What kind of demon are you?"
