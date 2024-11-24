let main _env =
  let genesis =
    Node.create ~identifier:"genesis" ~action:(fun _env -> failwith "")
  in
  let graph = Graph.create ~source:genesis in
  Graph.print_graph graph ; ()

let () = Eio_main.run @@ fun env -> main env
