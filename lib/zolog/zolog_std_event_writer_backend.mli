open Async.Std

type t

module Formatter : sig
  type t = Zolog_std_event.t -> (Zolog_std_event.Log.level * string) option
end

module Rotator : sig
  type force_open = Zolog_std_event.Log.level -> Writer.t Deferred.t
  type maybe_open = Zolog_std_event.Log.level -> Writer.t option Deferred.t
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

val default_formatter : ?max_level:Zolog_std_event.Log.level -> Formatter.t
