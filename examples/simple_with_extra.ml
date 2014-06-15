open Core.Std
open Async.Std

let main () =
  Zolog.start ()
  >>= fun logger ->
  Zolog_std_event_console_backend.create
    Zolog_std_event_writer_backend.default_formatter
  >>= fun backend ->

  let handler = Zolog_std_event_console_backend.handler backend in
  Zolog.add_handler logger handler >>= fun id ->
  (* Log a debug statement *)
  Zolog_event.debug
    ~extra:[("foo", "bar"); ("baz", "zoom")]
    ~n:["example"; "name"]
    ~o:"simple"
    logger
    "debug message"
  >>=? fun () ->
  (* Log a critical *)
  Zolog_event.critical
    ~n:["example"; "name"; "critical"]
    ~o:"simple"
    logger
    "critical message"
  >>=? fun () ->
  (*
   * We don't expect these two metrics to print anything, see
     simple_with_metrics.ml for how to turn that on
   *)

  (* Count something *)
  Zolog_event.counter
    ~n:["example"; "name"; "counter"]
    ~o:"simple"
    logger
    5
  >>=? fun () ->
  (* Time something *)
  Zolog_event.time
    ~n:["example"; "name"; "timer"]
    ~o:"simple"
    logger
    (fun () -> after (sec 2.0))
  >>=? fun () ->
  Zolog.sync logger
  >>= fun () ->
  Zolog.stop logger
  >>=? fun () ->
  Zolog_std_event_console_backend.destroy backend
  >>= fun() ->
  Deferred.return (Ok (shutdown 0))


let () =
  ignore (main ());
  never_returns (Scheduler.go ())
