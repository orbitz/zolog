open Core.Std
open Async.Std

type std_server = Zolog_std_event.t Zolog.t

type no_level =
    (std_server -> string -> unit Deferred.t) Zolog_std_event.event

val debug    : no_level
val info     : no_level
val warning  : no_level
val error    : no_level
val critical : no_level

val counter  : (std_server -> int -> unit Deferred.t) Zolog_std_event.event

val time     : (std_server -> (unit -> 'a Deferred.t) -> 'a Deferred.t) Zolog_std_event.event

