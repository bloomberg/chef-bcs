## Certs

#### Important if using behind firewall or proxy

This directory is where you place any CA certs that your firm may require for proxies. If your firm does not use proxies then there should be nothing except this readme in the directory.

Once you place the cert(s) in this directory then you *must* update /bootstrap/vms/environment_config.yaml to modify the following:

**ssl_ca_file_path:**

**ssl_ca_intermediate_file_path:**

Also, you may need to update the proxy items in the same file to represent your proxy settings if you use proxies.

The *.pem file(s) need to be copied into this directory. The .gitignore will not push the certs which is a good thing (please do not attempt to push any *.pem or *.crt files upstream)!
