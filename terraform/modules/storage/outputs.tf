output "assets_bucket_name" {
  description = "Name of the Bedrock assets S3 bucket"
  value       = aws_s3_bucket.assets.bucket
}

output "assets_bucket_arn" {
  description = "ARN of the Bedrock assets S3 bucket"
  value       = aws_s3_bucket.assets.arn
}

output "lambda_function_name" {
  description = "Name of the asset processor Lambda function"
  value       = aws_lambda_function.asset_processor.function_name
}
