open Core.Std

module Metric = struct
  type t =
    | Counter      of int
    | Duration_sec of float
end

module Log = struct
  type level =
    | Debug
    | Info
    | Warning
    | Error
    | Critical

  type t = { short_msg : string
	   ; level     : level
	   }

  let int_of_level = function
    | Debug    -> 0
    | Info     -> 1
    | Warning  -> 2
    | Error    -> 3
    | Critical -> 4

  let compare l r =
    Int.compare (int_of_level l) (int_of_level r)

  let string_of_level = function
    | Debug    -> "debug"
    | Info     -> "info"
    | Warning  -> "warning"
    | Error    -> "error"
    | Critical -> "critical"
end

module Event = struct
  type t =
    | Metric of Metric.t
    | Log    of Log.t
end

type t = { name   : string list
	 ; host   : string
	 ; origin : string
	 ; time   : Time.t
	 ; event  : Event.t
	 ; extra  : (string * string) list
	 }

type 'a event =
    ?extra:(string * string) list ->
    ?time:Time.t ->
    ?h:string ->
    n:string list ->
    o:string ->
    'a

let log ?(extra = []) ?(time = Time.now ()) ?(h = "nohostname") ~n ~o ~l msg =
  { extra
  ; time
  ; name   = n
  ; host   = h
  ; origin = o
  ; event  = Event.Log { Log.level = l; short_msg = msg }
  }

let metric ?(extra = []) ?(time = Time.now ()) ?(h = "nohostname") ~n ~o m =
  { extra
  ; time
  ; name   = n
  ; host   = h
  ; origin = o
  ; event  = Event.Metric m
  }

