type 'a t = {source: Node.t; edges: (Node.t, Node.t list) Hashtbl.t}

let max_edges = Transport.Config.(max_node_size * max_node_size)

let create ~source = {source; edges= Hashtbl.create max_edges}

let add_edge ~genesis ~exodus graph =
  let genesis_neighbours =
    Hashtbl.find_opt graph.edges genesis |> Option.value ~default:[]
  in
  Hashtbl.replace graph.edges genesis (exodus :: genesis_neighbours)

let print_graph graph =
  let genesis = graph.source in
  let rec aux genesis =
    Eio.traceln " [%s] " (Node.get_identifier genesis) ;
    let neighbours =
      Hashtbl.find_opt graph.edges genesis |> Option.value ~default:[]
    in
    List.iter (fun exodus -> aux exodus) neighbours
  in
  aux genesis

let process ~env _graph = ignore env ; failwith ""
