type ohclv = {
  mutable open_price : float;
  mutable high_price : float;
  mutable close_price : float;
  mutable low_price : float;
  mutable volume : float;
}

type series =
  | Tick of {
      id : string;
      datetime : Timedesc.t;
      price : float;
      volume : float;
    }
  | Minute of { start_time : Timedesc.t; ohclv : ohclv }

type timestamped_ohclv = Timedesc.t * ohclv
