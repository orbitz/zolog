open Async.Std

type 'a t = 'a Regen_event.t

module Handler = Regen_event.Handler

let start             = Regen_event.start
let add_handler       = Regen_event.add_handler
let remove_handler    = Regen_event.remove_handler
let stop              = Regen_event.stop
let sync              = Regen_event.sync

let publish           = Regen_event.publish
let publish_block     = Regen_event.publish_block
let publish_non_block = Regen_event.publish_non_block

