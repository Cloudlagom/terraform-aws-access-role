output "cloudtrim_role_arn" {
  description = "ARN of the IAM role created for Cloudtrim"
  value       = aws_iam_role.cloudtrim_role.arn
  sensitive   = false
}

output "cloudtrim_role_name" {
  description = "Name of the IAM role created for Cloudtrim"
  value       = aws_iam_role.cloudtrim_role.name
  sensitive   = false
}

output "cloudtrim_policy_arn" {
  description = "ARN of the IAM policy created for Cloudtrim"
  value       = aws_iam_policy.cloudtrim_policy.arn
  sensitive   = false
} 