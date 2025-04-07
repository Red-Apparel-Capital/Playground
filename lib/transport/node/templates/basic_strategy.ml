open Transport.Types

let action_aux ~out_buffer =
  let eps = 1.0 in
  let data2 = Ring_buffer.get Transport.Globals.timeseries 2 in
  let data1 = Ring_buffer.get Transport.Globals.timeseries 1 in
  let data0 = Ring_buffer.get Transport.Globals.timeseries 0 in
  let cond1 =
    let _, ohclv = data2 in
    ohclv.open_price < ohclv.close_price
  in
  let cond2 =
    let _, ohclv = data1 in
    ohclv.open_price < ohclv.close_price
  in
  let cond3 =
    let _, ohclv = data0 in
    let open_price0 = ohclv.open_price in
    let close_price0 = ohclv.close_price in

    let _, ohclv = data1 in
    let open_price1 = ohclv.open_price in
    let close_price1 = ohclv.close_price in

    open_price0 < close_price0
    && abs_float ((close_price0 -. open_price0) *. 2.)
       -. (close_price1 -. open_price1)
       <= eps
  in
  if cond1 && cond2 && cond3 && !Transport.Globals.position = 0 then (
    Eio.Stream.add out_buffer (Order Buy);
    Transport.Globals.position := 1)
  else ()

let action ~in_buffer:_ ~out_buffer =
  while true do
    if Ring_buffer.size Transport.Globals.timeseries >= 3 then
      action_aux ~out_buffer;
    Eio.Fiber.yield ()
  done

let create ~id = Node.create ~id ~action
