provider "aws" {
  region = var.aws_region
}

# S3 Buckets
resource "aws_s3_bucket" "source_bucket" {
  bucket = var.source_bucket_name
}

resource "aws_s3_bucket" "destination_bucket" {
  bucket = var.destination_bucket_name
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-s3-resizer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-s3-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "${aws_s3_bucket.source_bucket.arn}/*",
          "${aws_s3_bucket.destination_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "image_resizer" {
  function_name = "image-resizer"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = "${path.module}/../lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda.zip")

  environment {
    variables = {
      DEST_BUCKET = aws_s3_bucket.destination_bucket.bucket
    }
  }
}

# S3 Bucket Notification (Trigger Lambda on upload)
resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = aws_s3_bucket.source_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_resizer.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_function.image_resizer]
}
