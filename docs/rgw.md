## RADOS Gateway (RGW) APIs (Hammer)

Red Hat documentation link (link may require access):
https://access.redhat.com/documentation/en/red-hat-ceph-storage/1.3/paged/object-gateway-guide-for-red-hat-enterprise-linux/chapter-7-object-gateway-s3-api

Ceph documentation link:
http://docs.ceph.com/docs/master/radosgw/s3

Ceph's documenting is really lacking. So, we went through and tested each Python Boto3 API (see sample code link below).

Ceph Object Gateway supports a RESTful API that is compatible with the basic data access model of the Amazon S3 API. Certain features of AWS are not available for RGW (see below).

#### Thrid party APIs
Python Boto3 (official AWS):
http://boto3.readthedocs.io/en/latest/reference/services/s3.html

sudo -E -H pip install boto3

(note: if installing on Mac OSX you may run into an issue with the 'six' package. If this occurs then add '--ignore-installed six' after boto3 above)

###### Sample Python boto3 code:
https://github.com/bloomberg/chef-bcs/blob/master/cookbooks/chef-bcs/files/default/s3-example-boto3.py

This example code show all of the available features of RGW's implementation of AWS S3 interface. See the code comments for details.

#### Third party utilities:
S3CMD:
http://s3tools.org/s3cmd

This utility is a simple CLI to do all of the basic S3 commands available to RGW. It's not a performance driven tool and the current version does not use the official AWS Python Boto3 library. It implements it's own which is fine.

MC:
https://www.minio.io

This utility also has an SDK for GO that can be used to write go-lang applications to access RGW.

#### Feature Support
The following table describes the support status for current Amazon S3 functional features (this comes directly from Red Hat's documentation):

Feature	| Status | Remarks
---|---|---
List Buckets | Supported |
Create Bucket | Supported | Different set of canned ACLs
Get Bucket | Supported |
Get Bucket Location | Supported |
Delete Bucket | Supported |
Bucket ACLs (Get, Put) | Supported | Different set of canned ACLs
Bucket Object Versions | Supported | See example Python code
Get Bucket Info (HEAD) | Supported |
List Bucket Multipart Uploads | Supported |
Bucket Lifecycle | Not Supported |
Policy (Buckets, Objects) | Not Supported | ACLs are supported
Bucket Website | Not Supported |
Bucket Notification | Not Supported |
Bucket Request Payment | Not Supported | Supported in Jewel
Put Object | Supported |
Delete Object | Supported |
Get Object | Supported |
Object ACLs (Get, Put) | Supported |
Get Object Info (HEAD) | Supported |
Copy Object | Supported |
Initiate Multipart Upload | Supported |
Initiate Multipart Upload Part| Supported |
List Multipart Upload Parts | Supported |
Complete Multipart Upload | Supported |
Abort Multipart Upload | Supported |
Multipart Uploads | Supported | (missing Copy Part)

#### Unsupported Header Fields
The following common request header fields are not supported:

Name | Type
---|---
x-amz-security-token | Request
Server | Response
x-amz-delete-marker | Response
x-amz-id-2 | Response
x-amz-request-id | Response
x-amz-version-id | Response

##### Common Request Headers

Request Header | Description
---|---
CONTENT_LENGTH | Length of the request body.
DATE | Request time and date (in UTC).
HOST | The name of the host server.
AUTHORIZATION | Authorization token.

##### Common Response Status

HTTP Status | Response Code
---|---
100 | Continue
200 | Success
201 | Created
202 | Accepted
204 | NoContent
206 | Partial content
304 | NotModified
400 | InvalidArgument
400 | InvalidDigest
400 | BadDigest
400 | InvalidBucketName
400 | InvalidObjectName
400 | UnresolvableGrantByEmailAddress
400 | InvalidPart
400 | InvalidPartOrder
400 | RequestTimeout
400 | EntityTooLarge
403 | AccessDenied
403 | UserSuspended
403 | RequestTimeTooSkewed
404 | NoSuchKey
404 | NoSuchBucket
404 | NoSuchUpload
405 | MethodNotAllowed
408 | RequestTimeout
409 | BucketAlreadyExists
409 | BucketNotEmpty
411 | MissingContentLength
412 | PreconditionFailed
416 | InvalidRange
422 | UnprocessableEntity
500 | InternalError
