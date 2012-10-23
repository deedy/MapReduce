type scalar = float 
type point = scalar * scalar
type vector = scalar * scalar

let s_plus = (+.)
let s_minus = (-.)
let s_times = ( *. )
let s_divide = (/.)
let s_dist (x1,y1) (x2,y2) = 
  sqrt(s_plus((s_minus x1 x2)**2.)((s_minus y1 y2)**2.))
let s_compare = compare
let s_to_string = string_of_float

let v_plus (a,b)(c,d) = ((s_plus a c), (s_plus b d))
let distance = s_dist
let midpoint (a,b) (c,d) = (s_divide (s_plus a c) 2., s_divide (s_plus b d) 2.)
let head (a,b) = (sqrt (s_times a a) , sqrt (s_times b b))
let sum f s = List.fold_left v_plus (0.,0.) s
let scale_point s (x,y) = (s_times s x, s_times s y)
let unit_vector (a,b) (c,d) = 
  let dist = distance (a,b) (c,d) in
  (s_divide(s_minus c a) dist , s_divide(s_minus d b)dist)
