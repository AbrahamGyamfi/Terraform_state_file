# Terraform Backend Setup Module

This module creates the necessary AWS resources for a Terraform remote backend with state locking:
- S3 bucket for storing Terraform state
- DynamoDB table for state locking

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Update the values, especially the S3 bucket name (must be globally unique)
3. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

4. Copy the backend configuration from the output and add it to your main Terraform code's `backend.tf`
5. Run `terraform init -migrate-state` in your main project to migrate state to the remote backend

## Note

This module must be deployed BEFORE configuring the remote backend in your main Terraform code.
