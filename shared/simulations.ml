(* Starters for nbody simulation *)

let origin = (0.,0.)
let mass = 90000000000.
let _ = Random.init 9001

(* jbr99 tiw5 *)
let binary_star = 
  let pos = function
    | 0 -> (50.,0.) 
    | _ -> (-50.,0.) in
  let vel = function
    | 0 -> (0.,2.) 
    | _ -> (0.,-2.) in
  let mas = mass *. 150. in
  ("2", ("0", (mas, pos 0, vel 0))::("1", (mas, pos 1, vel 1))::[])

(* 8 bodies in diamond formation, initial velocity = 0 *)
let diamond = 
  let m = mass in 
  let v = origin in 
  let pos = function
   | 0 -> ((0.),(50.))
   | 1 -> ((25.),(-25.))
   | 2 -> ((0.),(-50.))
   | 3 -> ((-25.),(-25.))
   | 4 -> ((-50.),(0.))
   | 5 -> ((-25.),(25.))
   | 6 -> ((50.),(0.))
   | _ -> ((25.),(25.)) in
  let rec bodies n acc = 
    if n < 0 then acc
    else bodies (n-1) ((string_of_int n, (m,pos n,v)) :: acc) in
  "8", bodies 7 []

(* Four small bodies around one large one *)
let orbit = 
  let bigM = mass *. 500. in
  let lilM = mass /. 10. in   
  let pM = 2.6 in
  let (xI, yI) = origin in
  let v = origin in 
  (* maps integers 0-3 in sideways square *)
  let pos = function
   | 0 -> (50., 0.)
   | 1 -> (0.,50.)
   | 2 -> ((-50.),0.)
   | _ -> (0., (-50.)) in 
  (* map velocities *)
  let nM = (-1.)*.pM in  
  let speed = function
   | 0 -> ((0.), (nM))
   | 1 -> (pM,0.)
   | 2 -> ((0.),pM)
   | _ -> ((nM), (0.)) in 
  let rec bodies n acc = 
    if n < 0 then acc
    else
      bodies (n-1) ((string_of_int n, (lilM, pos n, speed n))::acc) in
  ("5", ("5", (bigM,(xI,yI),v))::bodies 3 [])

(*Random positions, random velocities.*)
let swarm = 
  (*Random float (magnitude) for velocity*)
  let r_vel() = Random.float 9. in
  (*Return 1. or -1.; used as sign*)
  let r_sign() = (if ((Random.float 10.) < 5.) then 1.0 else (-1.0)) in
  (*Random float for position*)
  let r_mag() = Random.float 250. in
  let pos m = 
  (*Equal chance of landing in all 4 quadrants*)
    let xDir = r_sign() in
    let yDir = r_sign() in
    let xMag = r_mag() in
    let yMag = r_mag() in
    (m, (xDir *. xMag , yDir *. yMag)) in
  (*Return body with given velocity in deterministic
   * direction. By quadrant, I = South; IV = West; III = North; II = East*)
  let b_cw (m,(x,y)) v = 
    match (x>0., y>0.) with
    | (true, true)   -> (m,(x,y),(0., (-1.)*.(v)))
    | (true, false)  -> (m,(x,y),((-1.)*.(v), 0.))
    | (false, false) -> (m,(x,y),(0.,v))
    | (false, true)  -> (m,(x,y),(v,0.)) in
  let rec bodies n acc = 
    if n = 0 then acc
    else bodies (n-1) ((string_of_int n, (b_cw(pos mass)(r_vel())))::acc) in
  ("300",  bodies 300 [])

(*Arthur Sams (aas258) and Charles Weill (cew225) *)
let system = 
  let bigM = mass *. 25. in
  let medM = mass in 
  let lilM = mass /. 15000. in   
  let pM = 2.6 in
  let (xI, yI) = origin in
  let v = origin in 
  (* Absolute coordinates for moons. *)
  let pos = function
   | 0 -> (75.,75.)
   | 1 -> (125.,125.)
   | 2 -> (75., 125.)
   | 3 -> (125.,75.) 
   | 4 -> ((-75.), (-75.))
   | 5 -> ((-125.),(-125.))
   | 6 -> ((-75.), (-125.))
   | 7 -> ((-125.),(-75.))  
   | 8 -> (75.,(-75.))
   | 9 -> (125.,(-125.))
   | 10 -> (75., (-125.))
   | 11 -> (125.,(-75.)) 
   | 12 -> ((-75.),75.)
   | 13 -> ((-125.),125.)
   | 14 -> ((-75.), 125.)
   | _ -> ((-125.),75.) in 
  (* Absolute velocities. Moons move clockwise around minor suns *)
  let nM = (-1.)*.pM in  
  let speed = function
   | 0 -> ((0.), (pM))
   | 1 -> (0.,nM)
   | 2 -> (pM,0.)
   | 3 -> (nM,0.)
   | 4 -> ((0.),nM)
   | 5 -> (0.0,pM) 
   | 6 -> ( nM, 0.0) 
   | 7 -> ( pM, 0.0 )
   | 8 -> (pM,0.0)
   | 9 -> (nM,0.0)
   | 10 -> (0.0,pM)
   | 11 -> (0.0,nM)   
    | 12 -> (nM,0.0)
   | 13 -> (pM,0.0)
   | 14 -> (0.,nM)
   | _ -> (0.0,pM)in 
  let rec bodies n acc = 
    if n < 0 then acc
    else bodies (n-1) ((string_of_int n, (lilM, pos n, speed n))::acc) in
  (*Minor Suns and Major Suns*)
  ("21",
    ("20", (medM,(-100.,100.),(pM/.10.0,0.0))) :: 
    ("19", (bigM,(xI,yI),v)) ::
    ("18", (medM,(100.,-100.),(nM/.10.,0.0))) :: 
    ("17", (medM,(100.,100.), (0.0,nM/.10.))) ::
    ("16", (medM,((-100.),(-100.)), (0.0,pM/.10.0))) ::
  bodies 15 [])

(* atn34 jlf248 *)
let terrible_situation =
  let bigM = mass *. 500. in
  let earthM = mass in
  let moonM = mass /. 500. in
  let mass = function
  | 0 -> bigM
  | 1 -> earthM
  | _ -> moonM in
  let pos = function
  | 0 -> (0.,0.)
  | 1 -> (200.,0.)
  | _ -> (212.,0.) in
  let speed = function
  | 0 -> (0.,0.)
  | 1 -> (0.,3.8)
  | _ -> (0.,4.45) in
  let rec bodies n acc = 
    if n < 0 then acc
    else bodies (n-1) ((string_of_int n, (mass n, pos n, speed n))::acc) in
  ("3", bodies 2 [])

(* Solar System Gone Berzerk *)
let zardoz = 
  let bigM = mass *. 2. in
  let earthM = mass in
  let pi = 4.0 *. atan 1.0 in 
  let noobj = 20 in
  let mass = function
  | _ -> earthM in
  let pos = function
  | x -> ((50.*.(cos (2.*.pi*.(float_of_int x)/.(float_of_int noobj)))),
    (50.*.(sin (2.*.pi*.(float_of_int x)/.(float_of_int noobj))))) 
  | _ -> (0.,0.) in
  let speed = function
  | x -> ((0.*.(cos (2.*.pi*.(float_of_int x)/.(float_of_int noobj)))),
    (0.*.(sin (2.*.pi*.(float_of_int x)/.(float_of_int noobj)))))
  | _ -> (0.,0.) in
  let rec bodies n acc = 
    if n < 0 then acc
    else bodies (n-1) ((string_of_int n, (mass n, pos n, speed n))::acc) in
  ((string_of_int (noobj)), bodies (noobj-1) [])

(* (* Acceleration without Collision *)
let zardoz = 
  let bigM = mass *. 2. in
  let earthM = mass in
  let mass = function
  | 0 -> bigM
  | _ -> earthM in
  let pos = function
  | 0 -> (0.,0.)
  | x -> (10.*.(float_of_int x),0.) in
  let speed = function
  | 0 -> (0.,0.)
  | x -> (0.,sqrt((6.67 *. (10.**(-11.)) *. bigM)/.(10.*.(float_of_int x)))) in
  let rec bodies n acc = 
    if n < 0 then acc
    else bodies (n-1) ((string_of_int n, (mass n, pos n, speed n))::acc) in
  ("15", bodies 14 []) *)

(* (* Solar System Gone Berzerk *)
let zardoz = 
  let bigM = mass *. 500. in
  let earthM = mass in
  let mass = function
  | 0 -> bigM
  | _ -> earthM in
  let pos = function
  | 0 -> (0.,0.)
  | x -> (10.*.(float_of_int x),0.) in
  let speed = function
  | 0 -> (0.,0.)
  | x -> (0.,sqrt((6.67 *. (10.**(-11.)) *. bigM)/.(10.*.(float_of_int x)))) in
  let rec bodies n acc = 
    if n < 0 then acc
    else bodies (n-1) ((string_of_int n, (mass n, pos n, speed n))::acc) in
  ("15", bodies 14 []) *)

(*   (* pseudo solar system *)
let zardoz = 
  let bigM = mass *. 500. in
  let earthM = mass in
  let mass = function
  | 0 -> bigM
  | _ -> earthM in
  let pos = function
  | 0 -> (0.,0.)
  | x -> (50.*.(float_of_int x),0.) in
  let speed = function
  | 0 -> (0.,0.)
  | x -> (0.,sqrt((6.67 *. (10.**(-11.)) *. bigM)/.(50.*.(float_of_int x)))) in
  let rec bodies n acc = 
    if n < 0 then acc
    else bodies (n-1) ((string_of_int n, (mass n, pos n, speed n))::acc) in
  ("5", bodies 4 []) *)