open Transport.Types

type t

val create :
  id:string ->
  action:
    (in_buffer:series Eio.Stream.t -> out_buffer:series Eio.Stream.t -> unit) ->
  t

val get_id : t -> string
val perform_action : t -> unit
val read_from_out : t -> series
val write_to_in : t -> series -> unit
