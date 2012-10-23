type worker_id = int
type includes = string
type code = string list
type shared_data = string
type worker_request =
  | InitMapper of code * shared_data
  | InitReducer of code
  | MapRequest of worker_id * string * string
  | ReduceRequest of worker_id * string * string list
type worker_response =
  | Mapper of worker_id option * string
  | Reducer of worker_id option * string
  | InvalidWorker of worker_id
  | RuntimeError of worker_id * string
  | MapResults of worker_id * (string * string) list
  | ReduceResults of worker_id * string list
