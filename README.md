Zolog is a logging dispatcher.  It provides an interface for publishing log
events, where a log event can be any type, as well as an interface for adding
backends, as long as they can handle the logging type. Zolog will route
publishes to backends.

One can use any event type as long as all backends support it.  Zolog comes with
an event type that supports representing most things the author feels users will
want.  It also comes with some basic backends.

Zolog requires Jane St Async and only works inside Async programs.
