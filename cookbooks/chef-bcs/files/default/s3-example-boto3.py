#!/usr/bin/env python
#
# Author: Chris Jones <cjones303@bloomberg.net>
# Copyright 2017, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# NOTE: To test on Mac OSX:
# sudo -E -H pip install boto3
# If an error occurs with 'six' package then add '--ignore-installed six' to end of line above:
# sudo -E -H pip install boto3 --ignore-installed six
# This is override any issues with the six package and install boto3. Boto3 has a number of enhancements over boto
# as far as helper functions etc. However, it is easier initially to just use boto.

import boto3
import datetime
#from botocore.utils import fix_s3_host

access_key = '<whatever key>'
secret_key = '<whatever key>'
endpoint_url = '<whatever s3 endpoint>'

# NOTE: IMPORTANT: If your environment requires a proxy then you must set http_proxy or https_proxy environment variable(s)
# before calling this or use Python to set it with os['http_proxy']=<whatever> here

# NOTE: The Red Hat documentation for RGW:
# https://access.redhat.com/documentation/en/red-hat-ceph-storage/1.3/paged/object-gateway-guide-for-red-hat-enterprise-linux/chapter-7-object-gateway-s3-api

#resource.meta.client.meta.events.unregister('before-sign.s3', fix_s3_host)
connection_type = None

# NOTE: There are two ways to use boto3 with RGW, client or resource. Each has it's pros/cons. Examples below show
# both ways. The client connection offers more feaures but the resource connection is an easy API.

# NOTE: Below are ways to set object expiration. CHANGE those dates!

conn = boto3.client(service_name='s3',
    aws_access_key_id=access_key,
    aws_secret_access_key=secret_key,
    endpoint_url=endpoint_url)
connection_type = 'client'
# OR
#conn = boto3.resource(service_name='s3',
#    aws_access_key_id=access_key,
#    aws_secret_access_key=secret_key,
#    endpoint_url=endpoint_url)
#connection_type = 'resource'

# client version has helper functions that are useful
if conn:
    print '============================================================================='
    if connection_type == 'resource':
        # For resource connection...
        # http://boto3.readthedocs.io/en/latest/reference/services/s3.html#service-resource
        for bucket in conn.buckets.all():
                print(bucket.name)

        print '---create_bucket-------------------------------------------------------------'
        print
        print conn.create_bucket(Bucket='mybucket')
        print
        print '---ObjectSummary.Version()---------------------------------------------------'
        # NOTE: The bucket must be enabled to for versioning first!
        # NOTE: If the VersionId is NULL then the object was created before the bucket was enabled for versioning.
        print
        version = conn.BucketVersioning('mybucket').enable()
        print version
        print conn.BucketVersioning('mybucket').status
        print
        print '---Object.put----------------------------------------------------------------'
        print
        print conn.Object('mybucket', 's3-example-boto3.py').put(Body=open('s3-example-boto3.py', 'rb'))
        print
        print '---Object.download_file------------------------------------------------------'
        print
        print conn.Object('mybucket', 's3-example-boto3.py').download_file('new_s3-example-boto3.py')
        print
        print '---ObjectSummary-------------------------------------------------------------'
        print
        object_summary = conn.ObjectSummary('mybucket', 's3-example-boto3.py')
        print object_summary
        print
        print '---ObjectSummary.get()-------------------------------------------------------'
        print
        print object_summary.get()
        print
        print '---ObjectSummary.Version()---------------------------------------------------'
        # NOTE: The bucket must be enabled to for versioning first!
        print
        version = conn.ObjectVersion('mybucket', 's3-example-boto3.py', '1')
        print version
        print
        print '---buckets.all()-------------------------------------------------------------'
        print
        for bucket in conn.buckets.all():
            for key in bucket.objects.all():
                print(key.key)
        print
    else:
        # For client connection...
        # http://boto3.readthedocs.io/en/latest/reference/services/s3.html#client
        print '---create_bucket-------------------------------------------------------------'
        resp = conn.create_bucket(Bucket='mybucket', ACL='private')
        print resp
        # NOTE: This bucket will be deleted later...
        resp = conn.create_bucket(Bucket='mybucket2', ACL='private')
        print resp
        print
        # NOTE: Boto3 client responds back with ResponseMetadata so look for HTTPStatusCode 200 for success
        if resp['ResponseMetadata']['HTTPStatusCode'] == 200:
            print 'Success'
        else:
            print 'Failed'
        print
        # NOTE: Boto3 PUT/DELETE operations often sets HTTPStatusCode to 204 which means it's successful and no
        # additional information was added. Some of the operations below do this.

        print '---put_bucket_versioning-----------------------------------------------------'
        # NOTE: Must enable the bucket for versioning before RGW will start assigning an unique id to each object.
        # NOTE: If the VersionId is NULL then the object was created before the bucket was enabled for versioning.
        print
        print conn.put_bucket_versioning(Bucket='mybucket', VersioningConfiguration={'Status': 'Enabled'})
        print
        # print '---get_bucket_lifecycle_configuration----------------------------------------'
        # NOTE: Not supported in Hammer
        # print
        # print conn.get_bucket_lifecycle_configuration(Bucket='mybucket')
        # print
        # print '---get_bucket_notification_configuration-------------------------------------'
        # NOTE: Not supported in Hammer
        # print
        # print conn.get_bucket_notification_configuration(Bucket='mybucket')
        # print
        # print '---get_bucket_replication----------------------------------------------------'
        # NOTE: Not supported in Hammer
        # print
        # print conn.get_bucket_replication(Bucket='mybucket')
        # print
        # print '---get_bucket_request_payment------------------------------------------------'
        # NOTE: Not supported in Hammer
        # print
        # print conn.get_bucket_request_payment(Bucket='mybucket')
        # print
        # print '---get_bucket_tagging--------------------------------------------------------'
        # NOTE: Not supported in Hammer
        # print
        # print conn.get_bucket_tagging(Bucket='mybucket')
        # print
        # print '---get_bucket_website--------------------------------------------------------'
        # NOTE: Not supported in Hammer
        # print
        # print conn.get_bucket_website(Bucket='mybucket')
        # print
        # print '---get_bucket_cors-----------------------------------------------------------'
        # NOTE: Not supported in Hammer
        # print
        # print conn.get_bucket_cors(Bucket='mybucket')
        # print
        print '---get_bucket_logging--------------------------------------------------------'
        # NOTE: Returns only response metadata for Hammer
        print
        print conn.get_bucket_logging(Bucket='mybucket')
        print
        print '---get_bucket_policy---------------------------------------------------------'
        print
        print conn.get_bucket_policy(Bucket='mybucket')
        print
        print '---get_bucket_location-------------------------------------------------------'
        print
        print conn.get_bucket_location(Bucket='mybucket')
        print
        print '---get_bucket_acl------------------------------------------------------------'
        print
        print conn.get_bucket_acl(Bucket='mybucket')
        print
        print '---head_bucket---------------------------------------------------------------'
        print
        print conn.head_bucket(Bucket='mybucket')
        print
        print '---get_bucket_versioning-----------------------------------------------------'
        print
        print conn.get_bucket_versioning(Bucket='mybucket')
        print
        print '---list_buckets--------------------------------------------------------------'
        print
        print conn.list_buckets()
        print
        buckets = conn.list_buckets()
        for bucket in buckets['Buckets']:
            print bucket
        print
        print '---delete_bucket-------------------------------------------------------------'
        print
        # NOTE: A bucket can only be deleted if there are no objects in it. You must delete the objects first.
        print conn.delete_bucket(Bucket='mybucket2')
        print
        print '---put_object----------------------------------------------------------------'
        print
        print conn.put_object(Bucket='mybucket', Body='Just a long string piece of data', Key='mytext', Expires=datetime.datetime(2016, 8, 3), Metadata={'Mymeta1': '1', 'Mymeta2': '2'})
        print
        print '---put_object_acl------------------------------------------------------------'
        print
        print conn.put_object_acl(Bucket='mybucket', Key='mytext', ACL='private')
        print
        print '---copy_object---------------------------------------------------------------'
        print
        print conn.copy_object(Bucket='mybucket', CopySource={'Bucket': 'mybucket', 'Key': 'mytext'}, Key='mytext2')
        print
        print '---upload_file---------------------------------------------------------------'
        # NOTE: Returns None so you can check afterwards to see if it's there
        print
        print conn.upload_file('myfile.txt', 'mybucket', 'myfile')
        print
        print '---download_file-------------------------------------------------------------'
        # NOTE: Returns None so you can check afterwards to see if it's gone
        print
        print conn.download_file('mybucket', 'myfile', 'new_myfile.txt')
        print
        print '---put_object (for deleting)-------------------------------------------------'
        print
        print conn.put_object(Bucket='mybucket', Body='Just a long string piece of data', Key='mytext5', Expires=datetime.datetime(2016, 8, 3), Metadata={'Mymeta1': '1', 'Mymeta2': '2'})
        print conn.put_object(Bucket='mybucket', Body='Just a long string piece of data', Key='mytext6', Expires=datetime.datetime(2016, 8, 3), Metadata={'Mymeta1': '1', 'Mymeta2': '2'})
        print conn.put_object(Bucket='mybucket', Body='Just a long string piece of data', Key='mytext7', Expires=datetime.datetime(2016, 8, 3), Metadata={'Mymeta1': '1', 'Mymeta2': '2'})
        print conn.put_object(Bucket='mybucket', Body='Just a long string piece of data', Key='mytext8', Expires=datetime.datetime(2016, 8, 3), Metadata={'Mymeta1': '1', 'Mymeta2': '2'})
        print
        print '---delete_object-------------------------------------------------------------'
        print
        print conn.delete_object(Bucket='mybucket', Key='mytext5')
        print
        print '---delete_objects------------------------------------------------------------'
        print
        print conn.delete_objects(Bucket='mybucket', Delete={'Objects': [{'Key': 'mytext6'}, {'Key': 'mytext7'}, {'Key': 'mytext8'}]})
        print
        print '---get_object----------------------------------------------------------------'
        print
        print conn.get_object(Bucket='mybucket', Key='myfile')
        print
        print '---get_object_acl------------------------------------------------------------'
        print
        print conn.get_object_acl(Bucket='mybucket', Key='myfile')
        print
        print '---get_object----------------------------------------------------------------'
        print
        print conn.get_object(Bucket='mybucket', Key='mytext')
        print
        print '---head_object---------------------------------------------------------------'
        print
        print conn.head_object(Bucket='mybucket', Key='mytext')
        print
        print '---list_objects--------------------------------------------------------------'
        print
        print conn.list_objects(Bucket='mybucket')
        print
        print '---list_objects_v2-----------------------------------------------------------'
        print
        print conn.list_objects_v2(Bucket='mybucket')
        print
        print '---list_object_versions------------------------------------------------------'
        # NOTE: VersionId is null which indicates versioning was not enabled when the given object was originally
        # created. Once the bucket has been enabled for versioning then objects will have a unique VersionId generated.
        print
        print conn.list_object_versions(Bucket='mybucket')
        print
    print '============================================================================='

# NOTE: You can find more examples and reference to boto3: http://boto3.readthedocs.io/en/latest/reference/services/s3.html#examples
