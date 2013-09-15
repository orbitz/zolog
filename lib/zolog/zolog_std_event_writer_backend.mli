open Async.Std

type t

module Formatter : sig
  type t = Zolog_std_event.t -> (Zolog_std_event.Log.level * string) option
end

module Rotator : sig
  type level      = Zolog_std_event.Log.level
  type force_open = unit -> (level * Writer.t) list Deferred.t
  type maybe_open = unit -> (level * Writer.t) list option Deferred.t
  type t          = { force_open : force_open
  		    ; maybe_open : maybe_open
  		    }
end

val create  :
  formatter:Formatter.t ->
  rotator:Rotator.t ->
  t Deferred.t
val handler : t -> Zolog_std_event.t Zolog.Handler.t
val destroy : t -> unit Deferred.t

(* Formatter *)
val default_formatter :
  ?min_level:Zolog_std_event.Log.level ->
  ?max_level:Zolog_std_event.Log.level ->
  Formatter.t

(* Rotator *)
val stderr_rotator    : Rotator.t
val writer_rotator    : Writer.t -> Rotator.t

(* Helpful transformers *)
(*
 * Takes output of a formatter and changes the log level to
 * Debug so it will be printed on all output
 *)
val funnel            : Formatter.t -> Formatter.t

