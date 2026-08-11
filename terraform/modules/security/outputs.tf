output "developer_username" {
  description = "Developer IAM username"
  value       = aws_iam_user.developer.name
}

output "developer_arn" {
  description = "Developer IAM user ARN"
  value       = aws_iam_user.developer.arn
}
