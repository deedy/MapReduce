type scalar = float
type point = float * float
type vector = float * float

(* Add scalar values *)
val s_plus : scalar -> scalar -> scalar

(* Subtract scalar values. Subtract the second argument from the first *)
val s_minus : scalar -> scalar -> scalar

(* Multiply scalar values *)
val s_times : scalar -> scalar -> scalar

(* Divide scalar values. The first argument is the numerator. *)
val s_divide : scalar -> scalar -> scalar

(* Distance between two pairs of scalars *)
val s_dist : scalar * scalar -> scalar * scalar -> scalar

(* s_compare a b return 1 if a>b, 0 if a=b, and -1 if a<b *)
val s_compare : scalar -> scalar -> int

(*Convert scalar to string*)
val s_to_string : scalar -> string

(* Sum of two vectors *)
val v_plus : vector -> vector -> vector

(* Distance between two points*)
val distance : point -> point -> scalar

(* Point midway between two points*)
val midpoint : point -> point -> point

(* outputs displacement of vector from origin *)
val head : vector -> point

(* sum of sequence vectors from mapping function across a sequence *)
val sum : 'a -> (float * float) list -> float * float

(* Multiply point by scalar value *)
val scale_point : scalar -> point -> point

(* Unit vectors have a magnitude of 1. *)
val unit_vector : point -> point -> vector
