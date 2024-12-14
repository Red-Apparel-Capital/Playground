type t
type series = Tick of { datetime : Timedesc.t; price : float; volume : float }

val create :
  identifier:string ->
  action:
    (in_buffer:series Eio.Stream.t -> out_buffer:series Eio.Stream.t -> unit) ->
  t

val get_identifier : t -> string
val perform_action : t -> unit
val read_from_out : t -> series
val write_to_in : t -> series -> unit
