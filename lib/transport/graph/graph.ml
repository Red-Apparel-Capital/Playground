type 'a t = { source : Node.t; edges : (Node.t, Node.t list) Hashtbl.t }

let max_edges = Transport.Config.(max_node_size * max_node_size)
let create ~source = { source; edges = Hashtbl.create max_edges }

let add_edge ~genesis ~exodus graph =
  let genesis_neighbours =
    Hashtbl.find_opt graph.edges genesis |> Option.value ~default:[]
  in
  Hashtbl.replace graph.edges genesis (exodus :: genesis_neighbours)

let write_from_out_to_in genesis neighbours =
  while true do
    let data = Node.read_from_out genesis in
    List.iter (fun exodus -> Node.write_to_in exodus data) neighbours
  done

let process graph =
  let genesis = graph.source in
  Eio.Switch.run @@ fun sw ->
  let rec aux genesis =
    Eio.Fiber.fork ~sw (fun () -> Node.perform_action genesis);
    let neighbours =
      Hashtbl.find_opt graph.edges genesis |> Option.value ~default:[]
    in
    Eio.Fiber.fork ~sw (fun () -> write_from_out_to_in genesis neighbours);
    List.iter (fun exodus -> aux exodus) neighbours
  in
  aux genesis
