## FAQ
This is a living document that provides answers to the most commonly asked questions. Please feel free to contribute by issuing a PR for your changes. Any changes/additions will be reviewed and if possible, merged.

RGW (S3)
Q1. If I have an account created on RGW and I have a valid access key and secret key, would I have to give out the secret key to others on my team if I wish for them to upload/download to buckets I create?
A1. Depends. If you are good with everyone (not just your team) then all you need to do is change the ACLs on the bucket to ```public-readwrite```. However, if you only want your team to be able to upload/download then you have two options.
Option 1: Give your team your secret key (you access key is public anyway so no big deal) but keep it protected.
Option 2: Allocate new access keys and secret keys for each member of the team under your account. These keys can be allocated and removed at any time.
Q2. Is there a self-maintainer model available for RGW? Meaning, is there a website where I can create accounts, add/remove keys, etc?
A2. No, not that ships with Ceph RGW. There are ways to easily provide this but you will need to speak to your Cloud Storage Team (maybe).
Q3. Our teams use Python, Java, C/C++, GO and Rust. Are there SDKs for each of those platforms?
A3. Yes. All of those mentioned, except Rust, can be found at AWS. There is a Rust SDK called aws-sdk-rust that can be installed via Rust's cargo found at crate.io.
Q4. I don't want to have to code everything, are there utilities that I can use to access S3?
A4. Yes. For windows there are several S3 utilities, cyberduck and S3browser are two. OSX and Linux: s3lsio, s3cmd. S3lsio is Rust based utility that has no dependencies and it's very fast. S3cmd is python based and has a number of dependencies. There is also a feature limited utility called minio.io that is GO based. It tries to be more a directory sync tool.
Q5. Some tools ask about an API Signature. What does that mean?
A5. AWS S3 authentication uses an API Signature to verify the request is valid. By default, AWS S3 now supports V4 as well as the older V2. Products like Ceph's RGW (Hammer and below) use V2 Signature while the Jewel and higher release supports the newer V4 Signature. This is important! Make sure you know which version of Ceph you are using.

Ceph (Librados)
Q1. What is Librados?
A1. Librados is the basis of what most of Ceph is built off of. For example, RGW uses Librados to read/write it's stripes to the Ceph cluster. You can use Librados to make programmatic changes to Ceph as well as use it for monitoring and even your own Ceph client like a modified RGW etc.
Q2. What programming languages are supported by Librados?
A2. C/C++, Python, GO (this maybe limited feature set) and Rust. The C/C++ and Python versions are bundled with Ceph. GO and Rust versions are other reposes in the github.com/ceph repo.

Ceph Automation
Q1. Are there any automation tools for installing Ceph?
A1. Yes. Ceph-deploy is bundled with Ceph and works for small and simple installs. Ceph-Ansible is a set of Ansible playbooks that gives you more flexibility using an agentless (more push) tool. Ceph-Chef is a Chef Cookbook that fully automates all aspects of Ceph installs. Ceph-Chef is the core cookbook used by Bloomberg's Chef-repo, https://github.com/bloomberg/chef-bcs. Chef-bcs is a full blown automated platform that dynamically builds Bloomberg's large Ceph clusters. Ceph is the core for all of Bloomberg's Software Defined Storage (SDS).
 
