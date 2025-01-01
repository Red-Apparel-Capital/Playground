open Transport.Types

let max_queue_size = 256

type t = {
  id : string;
  in_buffer : series Eio.Stream.t;
  out_buffer : series Eio.Stream.t;
  action :
    in_buffer:series Eio.Stream.t -> out_buffer:series Eio.Stream.t -> unit;
}

let used_identities : (string, unit) Hashtbl.t =
  Hashtbl.create Transport.Config.max_node_size

let create ~id ~action =
  match Hashtbl.mem used_identities id with
  | true -> failwith "Duplicate node name"
  | false ->
      let in_buffer = Eio.Stream.create max_queue_size in
      let out_buffer = Eio.Stream.create max_queue_size in
      { id; action; in_buffer; out_buffer }

let get_id node = node.id

let perform_action node =
  node.action ~in_buffer:node.in_buffer ~out_buffer:node.out_buffer

let read_from_out node = Eio.Stream.take node.out_buffer
let write_to_in node series = Eio.Stream.add node.in_buffer series
