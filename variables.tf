variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "terraform-lab"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnet"
  type        = string
  default     = "us-east-1a"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access (use your IP/32)"
  type        = string
  # Default to a placeholder - user should override with their IP
  default = "0.0.0.0/0"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance (Amazon Linux 2 in us-east-1)"
  type        = string
  # Amazon Linux 2 AMI - users should verify latest AMI for their region
  default = "ami-0c02fb55b7eb2c642"
}

variable "key_name" {
  description = "EC2 key pair name (optional - leave empty if not using SSH key)"
  type        = string
  default     = ""
}

# Backend configuration variables
variable "backend_s3_bucket" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = ""
}

variable "backend_dynamodb_table" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = ""
}
