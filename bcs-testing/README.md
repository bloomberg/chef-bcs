### BCS-Testing
bcs-testing.go is a golang code base that does perf tests on BCS for HTTP GET and POST.
To compile and run bcs-testing got to http://golang.org and download the GO package and install it.
Next, setup your .profile or .bash_profile file by appending the path to where you want to compile the
source. DO NOT do it in this directory! Do something like $HOME/projects/golang.

You should now be able to compile it with go install github.com/bloomberg/chef-bcs/bcs-testing. This will install
the binary in the /bin directory of your $GOPATH. For example, if you setup your GOPATH like the example above at
$HOME/projects/golang then your bin directory will $HOME/projects/golang/bin.

Also, add the $GOPATH exported variable to your $PATH (plus the /bin directory) so that you can simply run any of the
compiled golang code. For example, append this to your .profile or .bash_profile: export PATH=$PATH:$GOPATH/bin

Dependencies:
1. go get -u github.com/aws/aws-sdk-go - This command will download the AWS S3 SDK for GO
