open Core.Std
open Async.Std

let file_rotator_test () =
  let time = ref (Time.now ()) in
  let time_fun () = !time in
  let dir = Filename.temp_dir "zolog" "test" in
  Zolog_std_event_file_backend.create
    ~time:time_fun
    ~formatter:Zolog_std_event_writer_backend.default_formatter
    (Zolog_std_event_file_backend.default_filename ~dir)
  >>= fun backend ->
  let handler =
    Zolog_std_event_file_backend.handler backend
  in
  let log =
    Zolog_std_event.log
      ~extra:[]
      ~time:(Time.now ())
      ~n:["test"]
      ~h:"foo"
      ~o:"test"
      ~l:Zolog_std_event.Log.Info
      "foobar"
  in
  handler log >>= fun () ->
  Sys.readdir dir >>= fun c1 ->
  time := Time.add !time (Core.Span.of_hr 2.0);
  handler log >>= fun () ->
  Sys.readdir dir >>= fun c2 ->
  if Array.length c1 >= Array.length c2 then
    failwith "New files not created";
  Deferred.unit

let main () =
  file_rotator_test () >>= fun () ->
  Deferred.return (shutdown 0)

let () =
  ignore (main ());
  never_returns (Scheduler.go ())
