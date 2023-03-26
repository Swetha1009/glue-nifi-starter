import sys
import boto3
from awsglue.utils import getResolvedOptions
from awsglue.dynamicframe import DynamicFrame

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'STREAM_NAME', 'S3_BUCKET'])

stream_name = args['STREAM_NAME']
s3_bucket = args['S3_BUCKET']

# Create a Kinesis client
kinesis_client = boto3.client('kinesis')

# Read events from the Kinesis stream
kinesis_stream = kinesis_client.describe_stream(StreamName=stream_name)
shard_iterator = kinesis_client.get_shard_iterator(StreamName=stream_name, ShardId=kinesis_stream['StreamDescription']['Shards'][0]['ShardId'], ShardIteratorType='TRIM_HORIZON')['ShardIterator']
records = kinesis_client.get_records(ShardIterator=shard_iterator, Limit=1000)['Records']

# Convert the records to a DynamicFrame
dynamic_frame = DynamicFrame.from_options(frame=records, connection_type='kinesis')

# Write the records to S3
s3_path = 's3://{}/events/'.format(s3_bucket)
glue_context.write_dynamic_frame.from_options(frame=dynamic_frame, connection_type='s3', connection_options={'path': s3_path}, format='json')
