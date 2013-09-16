open Core.Std
open Async.Std

type filename = (unit -> Time.t) -> Zolog_std_event.Log.level -> string Deferred.t

type t = Zolog_std_event_writer_backend.t

let levels = [ Zolog_std_event.Log.Debug
	     ; Zolog_std_event.Log.Info
	     ; Zolog_std_event.Log.Warning
	     ; Zolog_std_event.Log.Error
	     ; Zolog_std_event.Log.Critical
	     ]

let sec_in_hour = 3600.0

let to_filename_string t =
  Core.Std.Unix.strftime
    (Core.Time_internal.to_tm_utc
       (Time.now ()))
    "%Y-%m-%d_%H-%M-%S"

let next_rotate_time sec =
  let into_hour = Float.mod_float sec sec_in_hour in
  let left_of_hour = sec_in_hour -. into_hour in
  sec +. left_of_hour

let wrap_filename time filename =
  let open Deferred.Monad_infix in
  let now_sec = ref (Time.to_epoch (time ())) in
  let force_open () =
      Deferred.List.map
	~f:(fun level ->
	  filename time level >>= fun fname ->
	  Writer.open_file
	    ~append:true
	    fname
	  >>= fun writer->
	  Deferred.return (level, writer))
	levels
  in
  let maybe_open () =
    let sec = !now_sec in
    let now = Time.to_epoch (time ()) in
    if sec < now then begin
      now_sec := next_rotate_time now;
      force_open () >>= fun writers ->
      Deferred.return (Some writers)
    end
    else
      Deferred.return None
  in
  { Zolog_std_event_writer_backend.Rotator.force_open
  ;                                        maybe_open
  }


let create ?(time = Time.now) ~formatter filename =
  let rotator = wrap_filename time filename in
  Zolog_std_event_writer_backend.create
    ~formatter
    ~rotator

let handler = Zolog_std_event_writer_backend.handler

let destroy = Zolog_std_event_writer_backend.destroy


let default_filename ~dir time level =
  let level_str = Zolog_std_event.Log.string_of_level level in
  let fname = level_str ^ "." ^ (to_filename_string (time ())) in
  Deferred.return (String.concat ~sep:"/" [dir; fname])
