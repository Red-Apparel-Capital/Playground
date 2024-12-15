let action ~in_buffer ~out_buffer:_ =
  while true do
    (* Be aware that Eio.Stream.take is blocking *)
    let series : Node.series = Eio.Stream.take in_buffer in
    match series with
    | Tick { id; datetime; price; volume } ->
        let info =
          Printf.sprintf "Datetime: %s, Price: %f, Volume: %f ID: %s"
            (Timedesc.to_string datetime)
            price volume id
        in
        Eio.traceln "%s" info
  done

let create () = Node.create ~id:"printer" ~action
