# This file is intentionally empty.
# All outputs are defined in main.tf to avoid duplicate definitions.
# See main.tf for the following outputs:
# - cloudtrim_role_arn: The ARN to use in Cloudtrim AWS connection
# - aws_account_id: Your AWS account ID
# - cloudtrim_connection_info: Complete connection details

# Role information
output "cloudtrim_role_arn" {
  description = "ARN of the IAM role created for Cloudtrim (Use this in the Cloudtrim connection form)"
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

output "cloudtrim_role_unique_id" {
  description = "Unique ID of the IAM role created for Cloudtrim"
  value       = aws_iam_role.cloudtrim_role.unique_id
  sensitive   = false
}

# AWS Account Information
output "aws_account_id" {
  description = "AWS Account ID where the role is created"
  value       = data.aws_caller_identity.current.account_id
  sensitive   = false
}

# Get AWS Account Alias if it exists
data "aws_iam_account_alias" "current" {
  count = 0  # Changed to 0 to avoid errors when no alias exists
}

locals {
  account_alias = length(data.aws_iam_account_alias.current) > 0 ? data.aws_iam_account_alias.current[0].account_alias : null
}

output "aws_account_alias" {
  description = "AWS Account Alias (if set)"
  value       = local.account_alias != null ? local.account_alias : data.aws_caller_identity.current.account_id
  sensitive   = false
}

# Connection Information Block
output "cloudtrim_connection_info" {
  description = "Complete information needed for Cloudtrim AWS account connection"
  value = {
    role_arn          = aws_iam_role.cloudtrim_role.arn
    external_id       = var.external_id
    account_id        = data.aws_caller_identity.current.account_id
    account_alias     = local.account_alias != null ? local.account_alias : data.aws_caller_identity.current.account_id
    role_name         = aws_iam_role.cloudtrim_role.name
    role_unique_id    = aws_iam_role.cloudtrim_role.unique_id
    cloudtrim_account = local.cloudtrim_account_id
  }
  sensitive = false
} 