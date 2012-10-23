open Util

let main (args : string array) : unit = 
  if Array.length args < 3 then 
    Printf.printf "Usage: inverted_index <filename>"
  else
    failwith "What need for the shepherd when the wolves have all gone"
