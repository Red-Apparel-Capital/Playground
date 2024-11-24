type t

val create : identifier:string -> action:(unit -> unit) -> t

val get_identifier : t -> string

val perform_action : t -> unit
