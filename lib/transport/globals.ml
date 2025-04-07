open Types

let initial_ohclv =
  {
    open_price = 0.0;
    close_price = 0.0;
    high_price = 0.0;
    low_price = 0.0;
    volume = 0.0;
  }

let initial_start_time =
  match
    Timedesc.make ~year:1900 ~month:1 ~day:1 ~hour:0 ~minute:0 ~second:0 ()
  with
  | Ok start_time -> start_time
  | Error _ -> failwith "Globals: Invalid start time"

let timeseries : timestamped_ohclv Ring_buffer.t =
  Ring_buffer.create Config.lookback_period (initial_start_time, initial_ohclv)

let position = ref 0
