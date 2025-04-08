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

# Define trust relationship using policy document
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.cloudtrim_account_id}:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}

# Create IAM role with trust policy
resource "aws_iam_role" "cloudtrim_role" {
  name               = var.role_name
  description        = "IAM role for Cloudtrim cloud cost optimization service"
  assume_role_policy = data.aws_iam_policy_document.trust.json
  
  # Force detach policies on deletion to ensure clean removal
  force_detach_policies = true

  # Maximum session duration of 12 hours
  max_session_duration = 43200

  tags = local.merged_tags
}

# Define permissions policy document
data "aws_iam_policy_document" "permissions" {
  statement {
    sid    = "CloudtrimReadOnlyCostExplorer"
    effect = "Allow"
    actions = [
      "ce:Get*",
      "ce:Describe*",
      "ce:List*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudtrimReadOnlyCompute"
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "lambda:List*",
      "lambda:Get*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudtrimReadOnlyStorage"
    effect = "Allow"
    actions = [
      "s3:List*",
      "s3:Get*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudtrimReadOnlyDatabase"
    effect = "Allow"
    actions = [
      "rds:Describe*",
      "rds:List*",
      "dynamodb:List*",
      "dynamodb:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudtrimReadOnlyMonitoring"
    effect = "Allow"
    actions = [
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "cloudwatch:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudtrimReadOnlyMetadata"
    effect = "Allow"
    actions = [
      "tag:Get*",
      "trustedadvisor:Describe*",
      "iam:ListAccountAliases",
      "iam:GetAccountSummary",
      "organizations:Describe*",
      "organizations:List*"
    ]
    resources = ["*"]
  }
}

# Create IAM policy using the policy document
resource "aws_iam_policy" "cloudtrim_policy" {
  name        = "CloudtrimAccessPolicy-${data.aws_caller_identity.current.account_id}"
  description = "Policy granting Cloudtrim read-only access for cloud cost optimization"
  policy      = data.aws_iam_policy_document.permissions.json
  tags        = local.merged_tags
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "cloudtrim_attach_policy" {
  role       = aws_iam_role.cloudtrim_role.name
  policy_arn = aws_iam_policy.cloudtrim_policy.arn
}

module "cloudtrim_access" {
  source      = "git::https://github.com/cloudlagom/terraform-aws-access-role.git"
  external_id = "your-external-id-from-cloudtrim"  # They'll get this from Cloudtrim
  
  # Optional configurations
  region     = "us-east-1"  # Optional, defaults to us-east-1
}
