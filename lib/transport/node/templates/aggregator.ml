open Transport.Types

let change_datetime_minute datetime minute =
  match
    Timedesc.make ~year:(Timedesc.year datetime)
      ~month:(Timedesc.month datetime) ~day:(Timedesc.day datetime)
      ~hour:(Timedesc.hour datetime) ~minute ~second:0 ()
  with
  | Ok datetime -> datetime
  | Error _ -> failwith "Aggregator: Invalid datetime"

let get_n_minute_start_time (datetime : Timedesc.t) n : Timedesc.t =
  let minute = Timedesc.minute datetime / n * n in
  change_datetime_minute datetime minute

let add_new_buffer_entry start_time price volume =
  Ring_buffer.add Transport.Globals.timeseries
    ( start_time,
      {
        open_price = price;
        close_price = price;
        high_price = price;
        low_price = price;
        volume;
      } )

let aggregate_on_current ohclv price volume =
  ohclv.close_price <- price;
  ohclv.high_price <- max ohclv.high_price price;
  ohclv.low_price <- min ohclv.low_price price;
  ohclv.volume <- ohclv.volume +. volume

let action n ~in_buffer ~out_buffer =
  while true do
    let series = Eio.Stream.take in_buffer in
    match series with
    | Tick { datetime; price; volume; _ } ->
        let minute_start_time = get_n_minute_start_time datetime n in
        if Ring_buffer.is_empty Transport.Globals.timeseries then
          add_new_buffer_entry minute_start_time price volume
        else
          let start_time, ohclv =
            Ring_buffer.get Transport.Globals.timeseries 0
          in
          if start_time <> minute_start_time then (
            add_new_buffer_entry minute_start_time price volume;
            Eio.Stream.add out_buffer (Minute { start_time; ohclv }))
          else aggregate_on_current ohclv price volume
    | _ -> failwith "Aggregator: Unexpected series type, expecting Tick"
  done

let create ~id ~n = Node.create ~id ~action:(action n)
