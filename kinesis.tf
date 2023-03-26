resource "aws_kinesis_stream" "example_stream" {
  name             = "example-stream"
  shard_count      = 1
  retention_period = 48
}

resource "aws_iam_policy" "kinesis_policy" {
  name        = "glue-kinesis-policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ]
        Effect   = "Allow"
        Resource = aws_kinesis_stream.example_stream.arn
      }
    ]
  })
}

resource "aws_iam_role" "glue_role" {
  name = "glue-kinesis-role"
  
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

resource "aws_iam_role_policy_attachment" "glue_kinesis_policy_attachment" {
  policy_arn = aws_iam_policy.kinesis_policy.arn
  role       = aws_iam_role.glue_role.name
}

resource "aws_glue_connection" "kinesis_connection" {
  name          = "kinesis-connection"
  connection_type = "KINESIS"
  connection_properties = jsonencode({
    "streamName" = aws_kinesis_stream.example_stream.name
    "region"     = var.region
  })
}
