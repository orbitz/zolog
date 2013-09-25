open Core.Std
open Async.Std

let file_rotator_test () =
  let time = ref (Time.now ()) in
  let time_fun () = !time in
  let dir = Filename.temp_dir "zolog" "test" in
  let backend =
    Zolog_std_event_file_backend.create
      ~time:time_fun
      ~formatter:Zolog_std_event_writer_backend.default_formattor
      (Zolog_std_event_file_backend.default_filename ~dir)
  in
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
  let c1 = Sys.readdir dir in
  time <- time.add !time (Span.of_hr 2.0);
  handler log >>= fun () ->
  let c2 = Sys.readdir dir in
  if c1 >= c2 then
    failwith "New files not created";
  Deferred.unit

let main () =
  file_rotator_test () >>= fun () ->
  Deferred.return (shutdown 0)

let () =
  ignore (main ());
  never_returns (Scheduler.go ())
