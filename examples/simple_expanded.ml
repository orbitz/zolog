(*
 * This expands out the setup portion to show what can be done
 *)
open Core.Std
open Async.Std

let main () =
  let open Deferred.Monad_infix in
  let logger = Zolog.start () in

  (* Create a default formatter *)
  let formatter =
    Zolog_std_event_writer_backend.default_formatter
  in

  (*
   * Create a backend and funnel all messages to Debug
   * and use the stderr rotator, which doesn't rotate
   * anything and it only createsa debug level writer
   *)
  Zolog_std_event_writer_backend.create
    (Zolog_std_event_writer_backend.funnel formatter)
    Zolog_std_event_writer_backend.stderr_rotator
  >>= fun backend ->

  let handler = Zolog_std_event_writer_backend.handler backend in
  Zolog.add_handler logger handler >>= fun id ->
  (* Log a debug statement *)
  Zolog_event.debug
    ~n:["example"; "name"]
    ~o:"simple"
    logger
    "debug message"
  >>= fun () ->
  (* Log a critical *)
  Zolog_event.critical
    ~n:["example"; "name"; "critical"]
    ~o:"simple"
    logger
    "critical message"
  >>= fun () ->
  (* Count something *)
  Zolog_event.counter
    ~n:["example"; "name"; "counter"]
    ~o:"simple"
    logger
    5
  >>= fun () ->
  (* Time something *)
  Zolog_event.time
    ~n:["example"; "name"; "timer"]
    ~o:"simple"
    logger
    (fun () -> after (sec 2.0))
  >>= fun () ->
  Zolog.sync logger
  >>= fun () ->
  Zolog.stop logger;
  (*
   * Don't call the destroy on this.  The writer destroyer will close
   * the writers and we don't want to close stderr.  The console backend
   * destroy handles this properly
   *)
  (* Zolog_std_event_writer_backend.destroy backend *)
  Deferred.return (shutdown 0)


let () =
  ignore (main ());
  never_returns (Scheduler.go ())
