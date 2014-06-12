open Async.Std

type 'a t

module Handler : sig
  type 'a t = 'a -> unit Deferred.t
  type id
end

val start             : unit -> 'a t Deferred.t
val add_handler       : 'a t -> 'a Handler.t -> (Handler.id, [> `Closed ]) Deferred.Result.t
val remove_handler    : 'a t -> Handler.id -> unit
val stop              : 'a t -> (unit, [> `Closed ]) Deferred.Result.t
val sync              : 'a t -> unit Deferred.t
val publish           : 'a t -> 'a -> (unit, [> `Closed ]) Deferred.Result.t
