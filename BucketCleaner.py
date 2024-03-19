#!/usr/bin/env python

import boto3
#This will use the credentials in your ~/.aws/credentials file found in your AWS profile...
#change to match your profile name or to 'default' for default profile:
session = boto3.session.Session(profile_name='default')

BUCKET = 'NAME_OF_BUCKET_GOES_HERE'  #Set this to the name of the bucket you want to COMPLETELY EMPTY...even versions, and then delete

s3 = session.resource('s3')
bucket = s3.Bucket(BUCKET)
bucket.object_versions.delete()

#If you dont want to delete the bucket and only want to remove everything IN it comment out the following line
bucket.delete()
