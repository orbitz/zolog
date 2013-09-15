open Core.Std
open Async.Std

let main () =
  let open Deferred.Monad_infix in
  let logger = Zolog.start () in
  let formatter =
    Zolog_std_event_writer_backend.default_formatter
      ~max_level:Zolog_std_event.Log.Critical
  in
  Zolog_std_event_writer_backend.create
    (Zolog_std_event_writer_backend.funnel formatter)
    Zolog_std_event_writer_backend.stderr_rotator
  >>= fun backend ->
  let handler = Zolog_std_event_writer_backend.handler backend in
  Zolog.add_handler logger handler >>= fun id ->
  Zolog_event.debug
    ~n:["example"; "name"]
    ~o:"simple"
    logger
    "debug message"
  >>= fun () ->
  Zolog_event.critical
    ~n:["example"; "name"; "critical"]
    ~o:"simple"
    logger
    "critical message"
  >>= fun () ->
  Zolog_event.counter
    ~n:["example"; "name"; "counter"]
    ~o:"simple"
    logger
    5
  >>= fun () ->
  Zolog_event.time
    ~n:["example"; "name"; "timer"]
    ~o:"simple"
    logger
    (fun () -> after (sec 2.0))
  >>= fun () ->
  Zolog.sync logger
  >>= fun () ->
  Zolog.stop logger;
  Deferred.return (shutdown 0)


let () =
  ignore (main ());
  never_returns (Scheduler.go ())
