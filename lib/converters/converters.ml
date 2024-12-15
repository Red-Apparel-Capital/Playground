let parse_date (date : string) : int * int * int =
  match String.split_on_char '/' date with
  | [ day; month; year ] ->
      (int_of_string year, int_of_string month, int_of_string day)
  | _ -> failwith (Printf.sprintf "Invalid date format %s" date)

let parse_time (time : string) : int * int * int =
  match String.split_on_char ':' time with
  | [ hour; minute; second ] ->
      (int_of_string hour, int_of_string minute, int_of_string second)
  | _ -> failwith (Printf.sprintf "Invalid time format %s" time)

let convert_to_timedesc (datetime : string) : Timedesc.t =
  match String.split_on_char ' ' datetime with
  | [ date; time ] ->
      let year, month, day = parse_date date in
      let hour, minute, second = parse_time time in
      Timedesc.make_exn ~year ~month ~day ~hour ~minute ~second ()
  | _ -> failwith (Printf.sprintf "Invalid datetime format %s" datetime)
