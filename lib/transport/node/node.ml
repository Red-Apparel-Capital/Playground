type t = {identifier: string; action: unit -> unit}

let used_identities : (string, unit) Hashtbl.t =
  Hashtbl.create Transport.Config.max_node_size

let create ~(identifier : string) ~(action : unit -> unit) : t =
  match Hashtbl.mem used_identities identifier with
  | true ->
      failwith "Duplicate node name"
  | false ->
      Hashtbl.add used_identities identifier () ;
      {identifier; action}

let get_identifier node = node.identifier

let perform_action node = node.action ()
