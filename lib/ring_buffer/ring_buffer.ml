type 'a t = {
  buffer : 'a array;
  mutable start : int; (* Index of the oldest element *)
  mutable size : int; (* Number of elements in the buffer *)
  capacity : int;
}

let create capacity init_value =
  { buffer = Array.make capacity init_value; start = 0; size = 0; capacity }

let size rb = rb.size
let is_empty rb = rb.size = 0
let is_full rb = rb.size = rb.capacity

let add rb value =
  if is_full rb then (
    (* Overwrite the oldest value *)
    let idx = (rb.start + rb.size) mod rb.capacity in
    rb.buffer.(idx) <- value;
    rb.start <- (rb.start + 1) mod rb.capacity)
  else
    let idx = (rb.start + rb.size) mod rb.capacity in
    rb.buffer.(idx) <- value;
    rb.size <- rb.size + 1

let get rb index =
  if index < 0 || index >= rb.size then
    failwith "Ring_buffer: Index out of bounds when getting";
  let actual_index = (rb.start + rb.size - 1 - index) mod rb.capacity in
  rb.buffer.(actual_index)
