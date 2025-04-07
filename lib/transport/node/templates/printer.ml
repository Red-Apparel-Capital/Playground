open Transport.Types

let action ~in_buffer ~out_buffer:_ =
  while true do
    (* Be aware that Eio.Stream.take is blocking *)
    let series = Eio.Stream.take in_buffer in
    match series with
    | Tick { id; datetime; price; volume } ->
        let info =
          Printf.sprintf "Datetime: %s, Price: %f, Volume: %f ID: %s"
            (Timedesc.to_string datetime)
            price volume id
        in
        Eio.traceln "%s" info
    | Minute { start_time; ohclv } ->
        let info =
          Printf.sprintf
            "Start time: %s, Open: %f, High: %f, Close: %f, Low: %f, Volume: %f"
            (Timedesc.to_string start_time)
            ohclv.open_price ohclv.high_price ohclv.close_price ohclv.low_price
            ohclv.volume
        in
        Eio.traceln "%s" info
    | Order direction ->
        Eio.traceln "Order: %s"
          (match direction with Buy -> "Buy" | Sell -> "Sell");
        Eio.Fiber.yield ()
  done

let create () = Node.create ~id:"printer" ~action
