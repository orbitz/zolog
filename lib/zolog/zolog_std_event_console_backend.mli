open Async.Std

type t

val create  :
  formatter:Zolog_std_event_writer_backend.Formatter.t ->
  t Deferred.t
val handler : t -> Zolog_std_event.t Zolog.Handler.t
val destroy : t -> unit Deferred.t



