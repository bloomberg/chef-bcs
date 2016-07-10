#!/usr/bin/env python
#
# Author: Chris Jones <cjones303@bloomberg.net>
# Copyright 2016, Bloomberg Finance L.P.
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

import boto3
#from botocore.utils import fix_s3_host

access_key = '<your access key>'
secret_key = '<your secret key>'

#resource.meta.client.meta.events.unregister('before-sign.s3', fix_s3_host)

conn = boto3.client(service_name='s3',
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key,
        endpoint_url='<FULL URL with PORT>')
# OR
conn = boto3.resource(service_name='s3',
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key,
        endpoint_url='<FULL URL with PORT>')

# client version has helper functions that are useful 
if conn:
        for bucket in conn.buckets.all():
                print(bucket.name)
        conn.create_bucket(Bucket='mybucket')
        conn.Object('mybucket', 's3-example-boto3.py').put(Body=open('s3-example-boto3.py', 'rb'))
        conn.Object('mybucket', 's3-example-boto3.py').download_file('/home/vagrant/new_s3-example-boto3.py')
        for bucket in conn.buckets.all():
                for key in bucket.objects.all():
                        print(key.key)

# NOTE: You can find more examples and reference to boto3: http://boto3.readthedocs.io/en/latest/reference/services/s3.html#examples
