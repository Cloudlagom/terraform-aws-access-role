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

## Usage

1. Create a new Terraform configuration file (e.g., `main.tf`):

```hcl
module "cloudtrim_access" {
  source      = "git::https://github.com/cloudlagom/terraform-aws-access-role.git"
  external_id = "your-external-id-from-cloudtrim"  # Required: Get this from Cloudtrim
  
  # Optional configurations
  region     = "us-east-1"  # Default: us-east-1
}
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the planned changes:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

5. After successful application, copy the role ARN from the outputs and provide it to Cloudtrim.

## Important Security Notice

⚠️ **NEVER share your external ID with anyone other than through the secure Cloudtrim platform. The external ID is a crucial security component that helps prevent confused deputy problems.**

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| external_id | External ID provided by Cloudtrim | string | yes | - |
| region | AWS region | string | no | "us-east-1" |

## Outputs

| Name | Description |
|------|-------------|
| cloudtrim_role_arn | ARN of the created IAM role |

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

## Support

For support, please contact Cloudtrim support or open an issue in the GitHub repository.

## License

This module is licensed under the MIT License. See the LICENSE file for details.
