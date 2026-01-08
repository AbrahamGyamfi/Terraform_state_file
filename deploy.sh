#!/bin/bash

# Automated Terraform Deployment Script
# This script automates the entire deployment process

set -e  # Exit on error

echo "======================================"
echo "Terraform AWS Infrastructure Deployment"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform first."
    exit 1
fi

print_status "Terraform version: $(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)"

# Check if AWS CLI is configured
if ! command -v aws &> /dev/null; then
    print_warning "AWS CLI is not installed. Please configure AWS credentials manually."
else
    print_status "AWS CLI is configured"
fi

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_warning "terraform.tfvars not found. Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    print_status "terraform.tfvars created successfully."
fi

# Automatically deploy backend first
echo ""
print_status "Step 1: Backend Infrastructure Setup"
print_status "Deploying backend infrastructure automatically..."

deploy_backend="y"

if [ "$deploy_backend" = "y" ]; then
    print_status "Deploying backend infrastructure..."
    
    cd modules/backend
    
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "Backend terraform.tfvars not found. Creating from example..."
        cp terraform.tfvars.example terraform.tfvars
        print_status "Backend terraform.tfvars created successfully."
    fi
    
    terraform init
    terraform plan -out=backend.tfplan
    
    print_status "Applying backend infrastructure automatically..."
    terraform apply -auto-approve backend.tfplan
    
    print_status "Backend created successfully!"
    echo ""
    
    # Capture backend values
    BUCKET_NAME=$(terraform output -raw s3_bucket_name)
    DYNAMODB_TABLE=$(terraform output -raw dynamodb_table_name)
    AWS_REGION="eu-west-1"
    
    cd ../..
    
    # Automatically configure backend.tf
    print_status "Configuring backend.tf with S3 remote state..."
    if [ "$DYNAMODB_TABLE" = "none" ]; then
        print_warning "DynamoDB table not created (permission issue)"
        print_warning "Backend will use S3 only (no state locking)"
        cat > backend.tf <<EOF
# Backend configuration for S3 remote state
# Auto-configured by deploy.sh
# Note: No DynamoDB locking due to permission constraints

terraform {
  backend "s3" {
    bucket  = "${BUCKET_NAME}"
    key     = "terraform.tfstate"
    region  = "${AWS_REGION}"
    encrypt = true
  }
}
EOF
    else
        cat > backend.tf <<EOF
# Backend configuration for S3 with DynamoDB locking
# Auto-configured by deploy.sh

terraform {
  backend "s3" {
    bucket         = "${BUCKET_NAME}"
    key            = "terraform.tfstate"
    region         = "${AWS_REGION}"
    dynamodb_table = "${DYNAMODB_TABLE}"
    encrypt        = true
  }
}
EOF
    fi
    
    print_status "Backend configuration updated successfully!"
fi

# Initialize main Terraform configuration
echo ""
print_status "Step 2: Initialize Main Terraform Configuration"

if [ "$deploy_backend" = "y" ]; then
    print_status "Migrating state to remote backend..."
    terraform init -migrate-state -input=false
else
    terraform init
fi

# Plan
echo ""
print_status "Step 3: Generate Terraform Plan"
terraform plan -out=tfplan

# Apply automatically without confirmation
echo ""
print_status "Step 4: Applying Terraform Configuration automatically..."
terraform apply -auto-approve tfplan
    
    echo ""
    print_status "Deployment completed successfully!"
    echo ""
    echo "======================================"
    echo "Deployment Summary"
    echo "======================================"
    terraform output
    
    echo ""
    print_status "Access your web server:"
    PUBLIC_IP=$(terraform output -raw ec2_public_ip 2>/dev/null || echo "N/A")
    if [ "$PUBLIC_IP" != "N/A" ]; then
        echo "  HTTP: http://$PUBLIC_IP"
        echo "  Test: curl http://$PUBLIC_IP"
    fi
    
    echo ""
    print_status "Next steps:"
    echo "  1. Take screenshots of AWS Console (EC2, VPC, S3, DynamoDB)"
    echo "  2. Test the web server and SSH access"
    echo "  3. When finished, run: ./destroy.sh"

# Cleanup plan file
rm -f tfplan modules/backend/backend.tfplan 2>/dev/null || true

echo ""
print_status "Script completed successfully!"
