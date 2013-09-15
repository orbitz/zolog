open Core.Std
open Async.Std

module Formatter = struct
  type t = Zolog_std_event.t -> (Zolog_std_event.Log.level * string) option
end

module Rotator = struct
  type force_open = Zolog_std_event.Log.level -> Writer.t Deferred.t
  type maybe_open = Zolog_std_event.Log.level -> Writer.t option Deferred.t
  type t          = { force_open : force_open
  		    ; maybe_open : maybe_open
  		    }
end

type t = { mutable writers : (Zolog_std_event.Log.level * Writer.t) list
	 ; formatter       : Formatter.t
	 ; rotator         : Rotator.t
	 }

let make_writers opener =
  let open Deferred.Monad_infix in
  let levels = [ Zolog_std_event.Log.Debug
	       ; Zolog_std_event.Log.Info
	       ; Zolog_std_event.Log.Warning
	       ; Zolog_std_event.Log.Error
	       ; Zolog_std_event.Log.Critical
	       ]
  in
  Deferred.List.map
    ~f:(fun level ->
      opener level >>= fun writer ->
      Deferred.return (level, writer))
    levels

let maybe_remake_writers t =
  let open Deferred.Monad_infix in
  make_writers t.rotator.Rotator.maybe_open >>= fun writers ->
  let writers =
    List.fold_left
      ~f:(fun writers writer ->
	match writer with
	  | (_, None)       -> writers
	  | (level, Some w) -> (level, w)::writers)
      ~init:[]
      writers
  in
  let old_writers = List.map ~f:snd t.writers in
  Deferred.List.iter ~f:Writer.close old_writers >>= fun () ->
  t.writers <- writers;
  Deferred.unit

let write level str (wlevel, w) =
  if Zolog_std_event.Log.compare level wlevel <= 0 then
    Writer.write w str

let create ~formatter ~rotator =
  let open Deferred.Monad_infix in
  make_writers rotator.Rotator.force_open >>= fun writers ->
  Deferred.return { writers; formatter; rotator }

let handler t e =
  match t.formatter e with
    | Some (level, str) ->
      let open Deferred.Monad_infix in
      maybe_remake_writers t >>= fun () ->
      List.iter ~f:(write level str) t.writers;
      Deferred.unit
    | None ->
      Deferred.unit

let destroy t =
  Deferred.List.iter ~f:(fun (_, w) -> Writer.close w) t.writers


(* Formatter API *)
let log_formatter max_level = function
  | { Zolog_std_event.Log.level; short_msg }
      when Zolog_std_event.Log.compare level max_level <= 0 ->
    let msg =
      sprintf "[%s] %s"
	(Zolog_std_event.Log.string_of_level level)
	short_msg
    in
    Some (level, msg)
  | _ ->
    None

let metric_formatter = function
  | Zolog_std_event.Metric.Counter i ->
    sprintf "counter = %d" i
  | Zolog_std_event.Metric.Duration_sec d ->
    sprintf "duration = %f" d

let format_header ?(sep = ":") { Zolog_std_event.name; host; origin; time } =
  String.concat
    ~sep:" "
    [ Time.to_string_abs ~zone:Zone.utc time
    ; String.concat ~sep name
    ; host
    ; origin
    ]

let default_formatter ?(max_level = Zolog_std_event.Log.Critical) e =
  let formatted =
    match e.Zolog_std_event.event with
      | Zolog_std_event.Event.Log l    ->
	log_formatter max_level l
      | Zolog_std_event.Event.Metric m ->
	Some (Zolog_std_event.Log.Info, metric_formatter m)
  in
  match formatted with
    | Some (level, line) ->
      let header = format_header ~sep:":" e in
      Some (level, String.concat ~sep:" " [header; line])
    | None ->
      None

