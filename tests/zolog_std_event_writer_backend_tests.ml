open Core.Std
open Async.Std

let default_formatter_log_test () =
  let formatter =
    Zolog_std_event_writer_backend.default_formatter
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
  match formatter log with
    | Some _ ->
      Deferred.unit
    | None ->
      failwith "Log message didn't make it through"

let default_formatter_no_metric_test () =
  let formatter =
    Zolog_std_event_writer_backend.default_formatter
  in
  let metric =
    Zolog_std_event.metric
      ~extra:[]
      ~time:(Time.now ())
      ~n:["test"]
      ~h:"foo"
      ~o:"test"
      (Zolog_std_event.Metric.Counter 1)
  in
  match formatter metric with
    | Some _ ->
      failwith "Metric made it through"
    | None ->
      Deferred.unit

let default_formatter_with_metrics_test () =
  let formatter =
    Zolog_std_event_writer_backend.default_with_metrics_formatter
  in
  let metric =
    Zolog_std_event.metric
      ~extra:[]
      ~time:(Time.now ())
      ~n:["test"]
      ~h:"foo"
      ~o:"test"
      (Zolog_std_event.Metric.Counter 1)
  in
  match formatter metric with
    | Some _ ->
      Deferred.unit
    | None ->
      failwith "Metric didn't make it through"

let default_formatter_min_range_test () =
  let formatter =
    Zolog_std_event_writer_backend.default_formatter
      ~min_level:Zolog_std_event.Log.Info
  in
  let log =
    Zolog_std_event.log
      ~extra:[]
      ~time:(Time.now ())
      ~n:["test"]
      ~h:"foo"
      ~o:"test"
      ~l:Zolog_std_event.Log.Debug
      "foobar"
  in
  match formatter log with
    | Some _ ->
      failwith "Log message made it throught that shouldn't"
    | None ->
      Deferred.unit

let default_formatter_max_range_test () =
  let formatter =
    Zolog_std_event_writer_backend.default_formatter
      ~max_level:Zolog_std_event.Log.Info
  in
  let log =
    Zolog_std_event.log
      ~extra:[]
      ~time:(Time.now ())
      ~n:["test"]
      ~h:"foo"
      ~o:"test"
      ~l:Zolog_std_event.Log.Critical
      "foobar"
  in
  match formatter log with
    | Some _ ->
      failwith "Log message made it throught that shouldn't"
    | None ->
      Deferred.unit


let stderr_rotator_no_rotate_test () =
  let module W = Zolog_std_event_writer_backend in
  let rotator = W.stderr_rotator in
  rotator.W.Rotator.force_open () >>= function
    | [_] -> begin
      rotator.W.Rotator.maybe_open () >>= function
	| None -> Deferred.unit
	| _    -> failwith "Tried to open again"
    end
    | _ ->
      failwith "Returned too large a result"

let main () =
  default_formatter_log_test ()          >>= fun () ->
  default_formatter_no_metric_test ()    >>= fun () ->
  default_formatter_with_metrics_test () >>= fun () ->
  default_formatter_min_range_test ()    >>= fun () ->
  default_formatter_max_range_test ()    >>= fun () ->
  stderr_rotator_no_rotate_test ()       >>= fun () ->
  Deferred.return (shutdown 0)

let () =
  ignore (main ());
  never_returns (Scheduler.go ())
