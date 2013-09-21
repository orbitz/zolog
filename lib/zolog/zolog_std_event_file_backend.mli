open Core.Std
open Async.Std

type filename = (unit -> Time.t) -> Zolog_std_event.Log.level -> string Deferred.t

type t

val create  :
  ?time:(unit -> Time.t) ->
  formatter:Zolog_std_event_writer_backend.Formatter.t ->
  filename ->
  t Deferred.t
val handler : t -> Zolog_std_event.t Zolog.Handler.t
val destroy : t -> unit Deferred.t

val default_filename : dir:string -> filename
