# glue-nifi-starter

Just a starter project to teach new developers AWS GLUE, Apache Nifi and AWS, IaC with Terraform - and industry best practices with local testing using localstack and pre-commit based linters.

```bash
.
├── README.md
├── docker-compose.yml
├── glue
│   ├── __init__.py
│   └── sample-event.py
└── terraform
    ├── kinesis.tf
    ├── main.tf
    └── vars.tf
```

- Terraform folder has sample code that can be used to bootstrap glue, AWS S3 and AWS Kinesis infra.
    - This code creates a Kinesis stream named "example-stream", an IAM policy that allows AWS Glue to write to the stream, and an IAM role for AWS Glue that can assume the policy. It also creates a Glue connection that uses the Kinesis stream as its source. You can modify the region variable to specify the AWS region where you want to create the resources. More on that later.
- glue folder has a script that can bootstrap AWS GLUE tasks.
    - This job uses the AWS Glue dynamic frame to read events from a Kinesis stream and writes them to an S3 bucket in JSON format. You can specify the stream name and S3 bucket as command-line arguments when you run the job.
- docker compose file with localstack integration for local testing
- pre-commit file for linting best practices. More on that later.
- gitignore for best practices - standard files for terraform and python.

## Getting started locally with docker compose
tl;dr: Export relevant env vars, and AWS creds before running the scripts to get started.

This Docker Compose file includes five services:

`localstack`: Runs LocalStack and exposes the Kinesis, S3, and Glue APIs on ports 4566, 4572, and 8080, respectively.

`terraform`: Builds a Docker image that runs Terraform and configures it to use LocalStack as the backend. You can mount your Terraform code to the /app directory in this container.

`glue-job`: Builds a Docker image that runs an AWS Glue job that reads data from Kinesis and writes it to S3. You can mount your Glue job script to the /app directory in this container.

`s3`: Uses the Amazon CLI to create an S3 bucket named "test-bucket".

`kinesis`: Uses the Amazon CLI to create a Kinesis stream named "test-stream" with one shard.

To use this Docker Compose file, create a directory with a subdirectory named terraform that contains your Terraform code and a subdirectory named glue-job that contains your Glue job script. 

Then run docker-compose up to start LocalStack and the other services. 

You can export the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_DEFAULT_REGION` environment variables to specify your AWS credentials and region.

Note: Make sure to use the IAM account and not the root account credentials!


## Note on linting

This precommit file sets up pre-commit hooks for Terraform and GLUE code.

`pre-commit-terraform`: Adds hooks for Terraform code formatting (terraform_fmt), validation (terraform_validate), documentation generation (terraform_docs), static analysis (terraform_tflint and terraform_tfsec), and policy enforcement (terraform_checkov).

`black`: Formats Python code according to PEP 8 style guide.

`mypy`: Performs static type checking for Python code.

`pre-commit-hooks`: Includes a variety of hooks that check for issues like trailing whitespace, end-of-file issues, YAML syntax errors, large files, merge conflicts, debug statements, and Python code quality (flake8, isort, and bandit).

To use this pre-commit configuration, you'll need to have [pre-commit](https://pre-commit.com/) installed. 

Once you have pre-commit installed, you can run pre-commit install in your repository to install the hooks defined in .pre-commit-config.yaml. 

After that, pre-commit will automatically run the configured hooks whenever you make a commit, helping to ensure that your code is consistently formatted and free of errors.
