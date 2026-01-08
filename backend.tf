# Backend configuration for S3 with DynamoDB locking
# Auto-configured by deploy.sh

terraform {
  backend "s3" {
    bucket         = "terraform-state-abraham-gyamfi-2026"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
