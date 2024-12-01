let max_message_size = 128

(* Read one line from [client] and respond with "OK". *)
let handle_client flow addr =
  Eio.traceln "Accepted connection from %a" Eio.Net.Sockaddr.pp addr ;
  let rec loop () =
    let from_client =
      Eio.Buf_read.of_flow flow ~max_size:max_message_size |> Eio.Buf_read.line
    in
    let msg_tokens = String.split_on_char '|' (String.trim from_client) in
    match msg_tokens with
    | [time; price; volume] ->
        Eio.Flow.copy_string
          (Printf.sprintf "Message is {%s} {%s} {%s}\n" time price volume)
          flow ;
        loop ()
    | ["/quit"] ->
        Eio.Flow.copy_string "Quitting!\n" flow
    | _ ->
        Eio.Flow.copy_string
          (Printf.sprintf "Invalid message format: {%s}\n" from_client)
          flow ;
        loop ()
  in
  loop ()

let run socket =
  Eio.Net.run_server socket handle_client
    ~on_error:(Eio.traceln "Error handling connection: %a" Fmt.exn)
    ~max_connections:1000

let action ~net addr () =
  Eio.Switch.run ~name:"main"
  @@ fun sw ->
  let socket = Eio.Net.listen net ~sw ~reuse_addr:true ~backlog:5 addr in
  Eio.Fiber.fork ~sw (fun () -> run socket) ;
  ()

let create ~identifier ~port ~net =
  Eio.traceln " Creating node %s" identifier ;
  let addr = `Tcp (Eio.Net.Ipaddr.V4.loopback, port) in
  Node.create ~identifier ~action:(action ~net addr)
