let main ~net =
  let socket_node =
    Node_templates.Socket.create ~identifier:"socket" ~port:1717 ~net
  in
  let graph = Graph.create ~source:socket_node in
  Graph.process graph ; ()

let () = Eio_main.run @@ fun env -> main ~net:(Eio.Stdenv.net env)
