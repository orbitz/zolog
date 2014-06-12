open Core.Std
open Async.Std

type std_server = Zolog_std_event.t Zolog.t

type 'a no_level =
    (std_server -> string -> (unit, [> `Closed ] as 'a) Deferred.Result.t) Zolog_std_event.event

val debug    : 'a no_level
val info     : 'a no_level
val warning  : 'a no_level
val error    : 'a no_level
val critical : 'a no_level

val counter  : (std_server -> int -> (unit, [> `Closed ]) Deferred.Result.t) Zolog_std_event.event

val time     : (std_server -> (unit -> 'a Deferred.t) -> ('a, [> `Closed ]) Deferred.Result.t) Zolog_std_event.event

