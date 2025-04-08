terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  cloudtrim_account_id = "981515186395"  # Cloudtrim's AWS account ID
  default_tags = {
    ManagedBy   = "Terraform"
    Environment = terraform.workspace
    Service     = "Cloudtrim"
    CreatedAt   = timestamp()
  }
  merged_tags = merge(local.default_tags, var.tags)
}

# Data source to get AWS account ID for resource naming
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "cloudtrim_role" {
  name        = var.role_name
  description = "IAM role for Cloudtrim cloud cost optimization service"
  
  # Force detach policies on deletion to ensure clean removal
  force_detach_policies = true

  # Assume role policy with external ID condition
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${local.cloudtrim_account_id}:root"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "sts:ExternalId" = var.external_id
        }
      }
    }]
  })

  # Maximum session duration of 12 hours
  max_session_duration = 43200

  tags = local.merged_tags
}

resource "aws_iam_policy" "cloudtrim_policy" {
  name        = "CloudtrimAccessPolicy-${data.aws_caller_identity.current.account_id}"
  description = "Policy granting Cloudtrim read-only access for cloud cost optimization"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudtrimReadOnlyCostExplorer"
        Effect = "Allow"
        Action = [
          "ce:Get*",
          "ce:Describe*",
          "ce:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudtrimReadOnlyCompute"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "lambda:List*",
          "lambda:Get*"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudtrimReadOnlyStorage"
        Effect = "Allow"
        Action = [
          "s3:List*",
          "s3:Get*"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudtrimReadOnlyDatabase"
        Effect = "Allow"
        Action = [
          "rds:Describe*",
          "rds:List*",
          "dynamodb:List*",
          "dynamodb:Describe*"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudtrimReadOnlyMonitoring"
        Effect = "Allow"
        Action = [
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "cloudwatch:Describe*"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudtrimReadOnlyMetadata"
        Effect = "Allow"
        Action = [
          "tag:Get*",
          "trustedadvisor:Describe*",
          "iam:ListAccountAliases",
          "iam:GetAccountSummary",
          "organizations:Describe*",
          "organizations:List*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.merged_tags
}

resource "aws_iam_role_policy_attachment" "cloudtrim_attach_policy" {
  role       = aws_iam_role.cloudtrim_role.name
  policy_arn = aws_iam_policy.cloudtrim_policy.arn
}
