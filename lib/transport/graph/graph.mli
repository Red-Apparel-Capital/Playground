type 'a t

(* Returns a rooted graph https://en.wikipedia.org/wiki/Rooted_graph *)
val create : source:Node.t -> 'a t

(* Add edge between two nodes [directed] *)
val add_edge : genesis:Node.t -> exodus:Node.t -> 'a t -> unit

(* Print entire graph *)
val print : 'a t -> unit

(* Process the entire graph asynchronously *)
val process : 'a t -> unit
