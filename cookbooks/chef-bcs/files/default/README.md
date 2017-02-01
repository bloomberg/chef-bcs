## Misc Files
ISO file will get copied here during build but it will NOT upload iso to github. This is created just to create the required directory.

## Development Environment
There are several files in this folder that relate to development. One of these is `rustup.sh` which is a way of installing the Rust language in your development environment. May want to go to `https://rustup.rs` do as it says instead. Don't use in a production environment since it's only needed for development for Rust based apps.

May include a GO language installer later...

Ceph Admin Socket Commands:
There are 3 json files showing the Ceph Admin Socket Commands. You can use admin sockets from your code by sending a well formed json command to the socket after you have connected to it. For example,

JSON to send:
{"prefix": "<command>"}

Example: {"prefix": "perf dump"}
The example will send back a large JSON file of perf data for the cluster.

Of course, you can always do this with the CLI like, `ceph daemon mon.<hostname> perf dump`

###### Just FYI (should never need to do this but...)
All *.iso files are added to the chefignore but please keep in mind that IF an *.iso file is located in this directory and IF you want to later make modifications to this cookbook and then upload the cookbook it will fail. It will fail because the iso file will be too large so move the iso somewhere outside the cookbook and then upload the cookbook. After a successful upload you then mv the iso back into this directory so that Cobbler can use it.
