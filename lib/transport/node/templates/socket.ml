(* Socket node template.
 * This file defines the template for a tcp socket node in the transport layer. *)
open Transport.Types

let max_size = 1024 (* Maximum size to which the message buffer might grow *)

let write_tick_data_to_buffer buffer id datetime price volume =
  let datetime = Converters.convert_to_timedesc datetime in
  let price = float_of_string price in
  let volume = float_of_string volume in
  Eio.Stream.add buffer (Tick { id; datetime; price; volume })

(* Handle tick trading data and write to out buffer *)
let handle_injest ~out_buf flow =
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
              write_tick_data_to_buffer out_buf id datetime price volume;
              `loop
          | [ "/quit" ] ->
              Eio.traceln "Client requested shutdown";
              Eio.Flow.close flow;
              `stop
          | [ "/flat" ] ->
              Eio.traceln "All positions closed";
              Transport.Globals.position := 0;
              `loop
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

(* Handle buy/sell orders *)
let handle_egest ~in_buf flow =
  let rec loop () =
    let series = Eio.Stream.take in_buf in
    match series with
    | Order direction -> (
        match direction with
        | Buy ->
            Eio.Flow.copy_string "Buy\n" flow;
            loop ()
        | Sell ->
            Eio.Flow.copy_string "Sell\n" flow;
            loop ())
    | _ -> failwith "Unexpected series type, expecting Order"
  in
  loop ()

let handle_client flow addr ~in_buf ~out_buf =
  Eio.traceln "Accepted connection from %a" Eio.Net.Sockaddr.pp addr;
  Eio.Fiber.both
    (fun () -> handle_injest ~out_buf flow)
    (fun () -> handle_egest ~in_buf flow)

let run ~in_buf ~out_buf socket =
  Eio.Net.run_server socket
    (handle_client ~in_buf ~out_buf)
    ~on_error:(Eio.traceln "Error handling connection: %a" Fmt.exn)
    ~max_connections:1

let action ~net addr ~in_buffer ~out_buffer =
  Eio.Switch.run ~name:"Socket" @@ fun sw ->
  let socket = Eio.Net.listen net ~sw ~reuse_addr:true ~backlog:5 addr in
  Eio.Fiber.fork ~sw (fun () ->
      run ~in_buf:in_buffer ~out_buf:out_buffer socket);
  ()

let create ~id ~port ~net =
  Eio.traceln " Creating node %s" id;
  let addr = `Tcp (Eio.Net.Ipaddr.V4.loopback, port) in
  Node.create ~id ~action:(action ~net addr)
