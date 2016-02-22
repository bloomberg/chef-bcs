# Files
ISO file will get copied here during build but it will NOT upload iso to github. This is created just to create the required directory.

###### Just FYI (should never need to do this but...)
All *.iso files are added to the chefignore but please keep in mind that IF an *.iso file is located in this directory and IF you want to later make modifications to this cookbook and then upload the cookbook it will fail. It will fail because the iso file will be too large so move the iso somewhere outside the cookbook and then upload the cookbook. After a successful upload you then mv the iso back into this directory so that Cobbler can use it.
