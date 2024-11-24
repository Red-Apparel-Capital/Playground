type 'a t = {source: Node.t; edges: (Node.t, Node.t list) Hashtbl.t}

let max_edges = Transport.Config.(max_node_size * max_node_size)

let create ~source = {source; edges= Hashtbl.create max_edges}

let add_edge ~genesis ~exodus graph =
  let genesis_neighbours =
    Hashtbl.find_opt graph.edges genesis |> Option.value ~default:[]
  in
  Hashtbl.replace graph.edges genesis (exodus :: genesis_neighbours)

let traverse graph (action : node:Node.t -> unit) =
  let genesis = graph.source in
  let rec aux genesis =
    action ~node:genesis ;
    let neighbours =
      Hashtbl.find_opt graph.edges genesis |> Option.value ~default:[]
    in
    List.iter (fun exodus -> aux exodus) neighbours
  in
  aux genesis

let print graph =
  let action ~node = Eio.traceln " [%s] " (Node.get_identifier node) in
  traverse graph action

let process graph =
  let action ~node = Node.perform_action node in
  traverse graph action
