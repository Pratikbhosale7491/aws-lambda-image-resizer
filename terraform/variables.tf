variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "source_bucket_name" {
  description = "Name of the source S3 bucket"
  type        = string
  default     = "my-source-images-bucket-12345"
}

variable "destination_bucket_name" {
  description = "Name of the destination S3 bucket"
  type        = string
  default     = "my-destination-images-bucket-12345"
}
