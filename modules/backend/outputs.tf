output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = var.enable_dynamodb ? aws_dynamodb_table.terraform_lock[0].name : "none"
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = var.enable_dynamodb ? aws_dynamodb_table.terraform_lock[0].arn : "none"
}

output "backend_config" {
  description = "Backend configuration to use in your main Terraform code"
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.id}"
        key            = "terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${var.enable_dynamodb ? aws_dynamodb_table.terraform_lock[0].name : "none"}"
        encrypt        = true
      }
    }
  EOT
}
