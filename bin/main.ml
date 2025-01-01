let main ~net =
  (* Create nodes *)
  let socket_node = Node_templates.Socket.create ~id:"socket" ~port:1717 ~net in
  let aggregator_node =
    Node_templates.Aggregator.create ~id:"aggregator" ~n:5
  in
  let printer_node = Node_templates.Printer.create () in

  (* Create graph *)
  let graph = Graph.create ~source:socket_node in

  (* Add edges *)
  Graph.add_edge ~genesis:socket_node ~exodus:aggregator_node graph;

  Graph.add_edge ~genesis:socket_node ~exodus:printer_node graph;

  Graph.add_edge ~genesis:aggregator_node ~exodus:printer_node graph;

  (* Process graph *)
  Graph.process graph;
  ()

let () = Eio_main.run @@ fun env -> main ~net:(Eio.Stdenv.net env)
