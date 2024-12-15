(* Socket node template.
 * This file defines the template for a tcp socket node in the transport layer. *)

let max_size = 1024 (* Maximum size to which the message buffer might grow *)

let write_tick_data_to_buffer buffer id datetime price volume =
  let datetime = Converters.convert_to_timedesc datetime in
  let price = float_of_string price in
  let volume = float_of_string volume in
  Eio.Stream.add buffer (Node.Tick { id; datetime; price; volume })

let handle_client flow addr ~out =
  Eio.traceln "Accepted connection from %a" Eio.Net.Sockaddr.pp addr;
  let rec loop () =
    let lines_from_client =
      Eio.Buf_read.of_flow flow ~max_size |> Eio.Buf_read.lines
    in
    let line_tokens line = String.trim line |> String.split_on_char '|' in

    let process_lines =
      Seq.map
        (fun line ->
          match line_tokens line with
          | [ datetime; price; volume; id ] ->
              write_tick_data_to_buffer out id datetime price volume;
              `loop
          | [ "/quit" ] ->
              Eio.traceln "Client requested shutdown";
              Eio.Flow.close flow;
              `stop
          | _ ->
              Eio.traceln "Invalid message: %s" line;
              `loop)
        lines_from_client
    in
    match Seq.exists (fun x -> x = `stop) process_lines with
    | true -> ()
    | false -> loop ()
  in
  loop ()

let run ~out socket =
  Eio.Net.run_server socket (handle_client ~out)
    ~on_error:(Eio.traceln "Error handling connection: %a" Fmt.exn)
    ~max_connections:1

let action ~net addr ~in_buffer:_ ~out_buffer =
  Eio.Switch.run ~name:"Socket" @@ fun sw ->
  let socket = Eio.Net.listen net ~sw ~reuse_addr:true ~backlog:5 addr in
  Eio.Fiber.fork ~sw (fun () -> run ~out:out_buffer socket);
  ()

let create ~id ~port ~net =
  Eio.traceln " Creating node %s" id;
  let addr = `Tcp (Eio.Net.Ipaddr.V4.loopback, port) in
  Node.create ~id ~action:(action ~net addr)
