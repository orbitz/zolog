open Async.Std

type t = Zolog_std_event_writer_backend.t

let create ~formatter =
  Zolog_std_event_writer_backend.create
    (Zolog_std_event_writer_backend.funnel formatter)
    Zolog_std_event_writer_backend.stderr_rotator

let handler = Zolog_std_event_writer_backend.handler

(*
 * We are always logging to stderr and we don't want
 * close that when destroyed, so do nothing
 *)
let destroy _ =
  Deferred.unit




