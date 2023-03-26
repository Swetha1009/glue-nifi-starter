# glue-nifi-starter

Just a starter project to teach new developers AWS GLUE, nifi and AWS / IaC.

- Terraform folder has sample code that can be used to bootstrap glue, AWS S3 and AWS Kinesis infra.
    - This code creates a Kinesis stream named "example-stream", an IAM policy that allows AWS Glue to write to the stream, and an IAM role for AWS Glue that can assume the policy. It also creates a Glue connection that uses the Kinesis stream as its source. You can modify the region variable to specify the AWS region where you want to create the resources. More on that later.
- glue folder has a script that can bootstrap AWS GLUE tasks.
    - This job uses the AWS Glue dynamic frame to read events from a Kinesis stream and writes them to an S3 bucket in JSON format. You can specify the stream name and S3 bucket as command-line arguments when you run the job.
- docker compose file with localstack integration for local testing
- pre-commit file for linting best practices
- gitignore for best practices

## Getting started locally
tl;dr: Export relevant env vars, and AWS creds before running the scripts to get started.

This Docker Compose file includes five services:

localstack: Runs LocalStack and exposes the Kinesis, S3, and Glue APIs on ports 4566, 4572, and 8080, respectively.
terraform: Builds a Docker image that runs Terraform and configures it to use LocalStack as the backend. You can mount your Terraform code to the /app directory in this container.
glue-job: Builds a Docker image that runs an AWS Glue job that reads data from Kinesis and writes it to S3. You can mount your Glue job script to the /app directory in this container.
s3: Uses the Amazon CLI to create an S3 bucket named "test-bucket".
kinesis: Uses the Amazon CLI to create a Kinesis stream named "test-stream" with one shard.
To use this Docker Compose file, create a directory with a subdirectory named terraform that contains your Terraform code and a subdirectory named glue-job that contains your Glue job script. Then run docker-compose up to start LocalStack and the other services. You can modify the AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_DEFAULT_REGION environment variables to specify your AWS credentials and region.

