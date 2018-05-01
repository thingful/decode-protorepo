# decode-protorepo

Experimenting with capturing a set of protobuf definitions for DECODE within
a single repository.

The services defined here are the three core services we have currently
specced out as being required for the IoT scale model and pilot:

* device registration service
* stream encoder
* encrypted datastore

The interfaces defined represent the first evolution of the system (Evolution
1), which attempts to lay out the basic building blocks that we will expand
on in later iterations.

## Usage

I propose generating client/server stubs from this repo, and publishing them
to their own repos for each langauge we decide to support, e.g.
https://github.com/thingful/decode-datastore-go or
https://github.com/thingful/decode-datastore-node. An automated process for
this will be set up, but for now I am just creating these repos manually.
