open Core.Std
open Async.Std

let hostname = Async_unix.Unix_syscalls.gethostname ()

type std_server = Zolog_std_event.t Zolog.t

type 'a no_level =
    (std_server -> string -> (unit, [> `Closed ] as 'a) Deferred.Result.t) Zolog_std_event.event

let debug ?(extra = []) ?(time = Time.now ()) ?(h = hostname) ~n ~o server msg =
  let event =
    Zolog_std_event.log
      ~extra
      ~time
      ~n
      ~h
      ~o
      ~l:Zolog_std_event.Log.Debug
      msg
  in
  Zolog.publish server event

let info ?(extra = []) ?(time = Time.now ())  ?(h = hostname) ~n ~o server msg =
  let event =
    Zolog_std_event.log
      ~extra
      ~time
      ~n
      ~h
      ~o
      ~l:Zolog_std_event.Log.Info
      msg
  in
  Zolog.publish server event

let warning ?(extra = []) ?(time = Time.now ())  ?(h = hostname) ~n ~o server msg =
  let event =
    Zolog_std_event.log
      ~extra
      ~time
      ~n
      ~h
      ~o
      ~l:Zolog_std_event.Log.Warning
      msg
  in
  Zolog.publish server event

let error ?(extra = []) ?(time = Time.now ())  ?(h = hostname) ~n ~o server msg =
  let event =
    Zolog_std_event.log
      ~extra
      ~time
      ~n
      ~h
      ~o
      ~l:Zolog_std_event.Log.Error
      msg
  in
  Zolog.publish server event

let critical ?(extra = []) ?(time = Time.now ())  ?(h = hostname) ~n ~o server msg =
  let event =
    Zolog_std_event.log
      ~extra
      ~time
      ~n
      ~h
      ~o
      ~l:Zolog_std_event.Log.Critical
      msg
  in
  Zolog.publish server event

let counter ?(extra = []) ?(time = Time.now ())  ?(h = hostname) ~n ~o server c =
  let event =
    Zolog_std_event.metric
      ~extra
      ~time
      ~n
      ~h
      ~o
      (Zolog_std_event.Metric.Counter c)
  in
  Zolog.publish server event

let time ?(extra = []) ?(time = Time.now ())  ?(h = hostname) ~n ~o server f =
  let open Deferred.Monad_infix in
  let start = Time.now () in
  f () >>= fun r ->
  let stop = Time.now () in
  let sec = Core.Span.to_sec (Time.diff stop start) in
  let event =
    Zolog_std_event.metric
      ~extra
      ~time
      ~n
      ~h
      ~o
      (Zolog_std_event.Metric.Duration_sec sec)
  in
  Zolog.publish server event >>=? fun () ->
  Deferred.return (Ok r)
