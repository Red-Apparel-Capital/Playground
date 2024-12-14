let max_message_size = 512

let write_tick_data_to_buffer buffer datetime price volume =
  let datetime = Converters.convert_to_timedesc datetime in
  let price = float_of_string price in
  let volume = float_of_string volume in
  Eio.Stream.add buffer (Node.Tick { datetime; price; volume })

let handle_client flow addr ~out =
  Eio.traceln "Accepted connection from %a" Eio.Net.Sockaddr.pp addr;
  let rec loop () =
    let from_client =
      Eio.Buf_read.of_flow flow ~max_size:max_message_size |> Eio.Buf_read.line
    in
    let msg_tokens = String.split_on_char '|' (String.trim from_client) in
    match msg_tokens with
    | [ datetime; price; volume ] ->
        write_tick_data_to_buffer out datetime price volume;
        loop ()
    | [ "/quit" ] -> Eio.Flow.copy_string "Quitting!\n" flow
    | _ ->
        Eio.Flow.copy_string
          (Printf.sprintf "Invalid message format: {%s}\n" from_client)
          flow;
        loop ()
  in
  loop ()

let run ~out socket =
  Eio.Net.run_server socket (handle_client ~out)
    ~on_error:(Eio.traceln "Error handling connection: %a" Fmt.exn)
    ~max_connections:1000

let action ~net addr ~in_buffer:_ ~out_buffer =
  Eio.Switch.run ~name:"Socket" @@ fun sw ->
  let socket = Eio.Net.listen net ~sw ~reuse_addr:true ~backlog:50 addr in
  Eio.Fiber.fork ~sw (fun () -> run ~out:out_buffer socket);
  ()

let create ~identifier ~port ~net =
  Eio.traceln " Creating node %s" identifier;
  let addr = `Tcp (Eio.Net.Ipaddr.V4.loopback, port) in
  Node.create ~identifier ~action:(action ~net addr)
