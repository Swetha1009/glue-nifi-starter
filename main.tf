# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Configure the Kubernetes provider
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Create the Apache NiFi deployment and service
resource "kubernetes_deployment" "nifi" {
  metadata {
    name = "nifi"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nifi"
      }
    }

    template {
      metadata {
        labels = {
          app = "nifi"
        }
      }

      spec {
        container {
          name  = "nifi"
          image = "apache/nifi:latest"
          ports {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nifi" {
  metadata {
    name = "nifi"
  }

  spec {
    selector = {
      app = "nifi"
    }

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
  }
}

# Create the AWS Glue job
resource "aws_glue_job" "export_to_s3" {
  name        = "export-to-s3"
  role_arn    = aws_iam_role.glue_job.arn
  command {
    name        = "glueetl"
    python_version = "3"
    script_location = "s3://my-bucket/glue-script.py"
  }
  default_arguments = {
    "--source"   = "event-stream"
    "--destination" = "s3://my-bucket/exported-data"
  }
  connections   = ["my-connection"]
}

# Create the IAM role for the AWS Glue job
resource "aws_iam_role" "glue_job" {
  name = "glue-job-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# Create an IAM policy to allow the AWS Glue job to read from the event stream and write to S3
resource "aws_iam_policy" "glue_policy" {
  name        = "glue-policy"
  description = "Policy for the Glue job to read from the event stream and write to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = ["kinesis:GetShardIterator", "kinesis:GetRecords"]
        Resource  = aws_kinesis_stream.event_stream.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "arn:aws:s3:::my-bucket/exported-data/*"
      }
    ]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "glue_job_policy_attachment" {
  policy_arn = aws_iam_policy.glue_policy.arn
  role       = aws_iam_role.glue_job.name
}

# Create an AWS Glue connection to the event stream
resource "aws_glue_connection" "event_stream
