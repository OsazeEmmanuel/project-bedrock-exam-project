output "developer_username" {
  description = "Developer IAM username"
  value       = aws_iam_user.developer.name
}

output "developer_arn" {
  description = "Developer IAM user ARN"
  value       = aws_iam_user.developer.arn
}

output "cart_iam_role_arn" {
  description = "IAM role ARN used by the cart service"
  value       = aws_iam_role.cart.arn
}

