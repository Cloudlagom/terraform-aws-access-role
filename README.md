# Terraform AWS Cloudtrim Access Role Module

This Terraform module creates an IAM role in your AWS account that grants Cloudtrim read-only access for cloud cost optimization purposes. The module implements secure cross-account access using an external ID pattern for enhanced security.

## Security Features

- Uses AWS External ID pattern for secure cross-account access
- Implements principle of least privilege with read-only permissions
- Role assumption is restricted to Cloudtrim's AWS account
- All resources are tagged for better tracking
- Follows AWS security best practices

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create IAM roles and policies

## Quick Start

1. Create a new directory for your Terraform configuration:
```bash
mkdir cloudtrim-setup && cd cloudtrim-setup
```

2. Create a new Terraform configuration file (e.g., `main.tf`):
```hcl
module "cloudtrim_access" {
  source      = "git::https://github.com/cloudlagom/terraform-aws-access-role.git"
  external_id = "your-external-id-from-cloudtrim"  # Required: Get this from Cloudtrim
  
  # Optional configurations
  region     = "us-east-1"  # Default: us-east-1
}
```

3. Initialize Terraform:
```bash
terraform init
```

4. Review the planned changes:
```bash
terraform plan
```

5. Apply the configuration:
```bash
terraform apply
```

6. After successful application, you'll see the outputs needed for Cloudtrim setup.

## Important Security Notice

⚠️ **NEVER share your external ID with anyone other than through the secure Cloudtrim platform. The external ID is a crucial security component that helps prevent confused deputy problems.**

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| external_id | External ID provided by Cloudtrim | string | yes | - |
| region | AWS region | string | no | "us-east-1" |

## Outputs

After running `terraform apply`, you will see the following outputs:

| Name | Description | Usage |
|------|-------------|-------|
| cloudtrim_role_arn | ARN of the created IAM role | Copy this value to the Cloudtrim AWS connection form |
| aws_account_id | Your AWS Account ID | For reference and verification |
| cloudtrim_connection_info | Complete connection details | Contains all necessary information including role ARN, external ID, and account details |

Example output:
```hcl
Outputs:

cloudtrim_role_arn = "arn:aws:iam::123456789012:role/CloudtrimAccessRole"
aws_account_id = "123456789012"
cloudtrim_connection_info = {
  "role_arn"          = "arn:aws:iam::123456789012:role/CloudtrimAccessRole"
  "external_id"       = "your-external-id"
  "account_id"        = "123456789012"
  "role_name"         = "CloudtrimAccessRole"
  "cloudtrim_account" = "981515186395"
}
```

## Permissions Granted

The module grants read-only access to:
- AWS Cost Explorer
- EC2 (instances, volumes, snapshots)
- RDS
- Lambda
- S3
- CloudWatch
- IAM (limited to listing)
- Organizations
- Trusted Advisor
- DynamoDB
- Tags

## Troubleshooting

If you encounter any issues:

1. Ensure your AWS credentials are properly configured
2. Verify you have sufficient IAM permissions
3. Make sure you're using the correct external ID from Cloudtrim
4. Check that you're in the correct AWS region

## Support

For support:
- Open an issue in the GitHub repository
- Contact Cloudtrim support
- Check the AWS IAM console for role verification

## License

This module is licensed under the MIT License. See the LICENSE file for details.
