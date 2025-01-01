type 'a t

val create : int -> 'a -> 'a t
val add : 'a t -> 'a -> unit
val get : 'a t -> int -> 'a
val size : 'a t -> int
val is_empty : 'a t -> bool
val is_full : 'a t -> bool
