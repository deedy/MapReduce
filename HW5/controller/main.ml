let _ = 
  if Array.length Sys.argv < 2 then
    Printf.printf
      "Usage: `controller.exe <app_name> <args>`
  <args> are specific to the application <app_name>
  Options for <app_name> are:
    %s\n    %s\n    %s\n    %s\n"
      "word_count"
      "inverted_index"
      "page_rank"
      "nbody"
  else 
    match Sys.argv.(1) with
      | "word_count" -> Word_count.main Sys.argv
      | "inverted_index" -> Inverted_index.main Sys.argv
      | "page_rank" -> Page_rank.main Sys.argv
      | "nbody" -> Nbody.main Sys.argv
      | _ -> failwith "Invalid application name"
