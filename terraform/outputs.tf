output "source_bucket" {
  description = "Source S3 bucket name"
  value       = aws_s3_bucket.source_bucket.bucket
}

output "destination_bucket" {
  description = "Destination S3 bucket name"
  value       = aws_s3_bucket.destination_bucket.bucket
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.image_resizer.function_name
}
