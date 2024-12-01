type t

type time_series_data =
  | Nil
  | Tick of {datetime: Timedesc.t; price: float; volume: float}

val create : identifier:string -> action:(unit -> unit) -> t

val get_identifier : t -> string

val perform_action : t -> unit

val read_from_in_buffer : t -> time_series_data

val read_from_out_buffer : t -> time_series_data

val write_to_in_buffer : t -> time_series_data -> unit

val write_to_out_buffer : t -> time_series_data -> unit
