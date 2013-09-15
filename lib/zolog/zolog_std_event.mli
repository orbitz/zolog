open Core.Std

module Metric : sig
  type t =
    | Counter      of int
    | Duration_sec of float
end

module Log : sig
  type level =
    | Debug
    | Info
    | Warning
    | Error
    | Critical

  type t = { short_msg : string
	   ; level     : level
	   }

  val compare         : level -> level -> int
  val int_of_level    : level -> int
  val string_of_level : level -> string
end

module Event : sig
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
    n:string list ->
    h:string ->
    o:string ->
    'a

val log    : (l:Log.level -> string -> t) event
val metric : (Metric.t -> t) event
