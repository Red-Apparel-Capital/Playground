type ohclv = {
  mutable open_price : float;
  mutable high_price : float;
  mutable close_price : float;
  mutable low_price : float;
  mutable volume : float;
}

type order_direction = Buy | Sell

type series =
  | Tick of {
      id : string;
      datetime : Timedesc.t;
      price : float;
      volume : float;
    }
  | Minute of { start_time : Timedesc.t; ohclv : ohclv }
  | Order of order_direction

type timestamped_ohclv = Timedesc.t * ohclv
