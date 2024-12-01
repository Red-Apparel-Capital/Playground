type time_series_data =
  | Nil
  | Tick of {datetime: Timedesc.t; price: float; volume: float}

type t =
  { identifier: string
  ; action: unit -> unit
  ; in_buffer: time_series_data Eio.Stream.t
  ; out_buffer: time_series_data Eio.Stream.t }

let max_queue_size = 256

let used_identities : (string, unit) Hashtbl.t =
  Hashtbl.create Transport.Config.max_node_size

let create ~(identifier : string) ~(action : unit -> unit) : t =
  match Hashtbl.mem used_identities identifier with
  | true ->
      failwith "Duplicate node name"
  | false ->
      let in_buffer = Eio.Stream.create max_queue_size in
      let out_buffer = Eio.Stream.create max_queue_size in
      {identifier; action; in_buffer; out_buffer}

let get_identifier node = node.identifier

let perform_action node = node.action ()

let read_from_in_buffer node = Eio.Stream.take node.in_buffer

let read_from_out_buffer node = Eio.Stream.take node.out_buffer

let write_to_in_buffer node data = Eio.Stream.add node.in_buffer data

let write_to_out_buffer node data = Eio.Stream.add node.out_buffer data
