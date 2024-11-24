(* Read one line from [client] and respond with "OK". *)
let handle_client flow addr =
  Eio.traceln "Accepted connection from %a" Eio.Net.Sockaddr.pp addr ;
  let from_client = Eio.Buf_read.of_flow flow ~max_size:100 in
  Eio.traceln "Received: %S" (Eio.Buf_read.line from_client) ;
  Eio.Flow.copy_string "OK" flow

let run socket =
  Eio.Net.run_server socket handle_client
    ~on_error:(Eio.traceln "Error handling connection: %a" Fmt.exn)
    ~max_connections:1000

let action addr env () =
  let net = Eio.Stdenv.net env in
  Eio.Switch.run ~name:"main"
  @@ fun sw ->
  let socket = Eio.Net.listen net ~sw ~reuse_addr:true ~backlog:5 addr in
  Eio.Fiber.fork_daemon ~sw (fun () -> run socket) ;
  ()

let create ~identifier ~port ~env =
  let addr = `Tcp (Eio.Net.Ipaddr.V4.loopback, port) in
  Node.create ~identifier ~action:(action addr env)
