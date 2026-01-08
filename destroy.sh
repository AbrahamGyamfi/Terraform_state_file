#!/bin/bash

# Automated Terraform Destroy Script
# This script safely destroys all infrastructure

set -e

echo "======================================"
echo "Terraform Infrastructure Destruction"
echo "======================================"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Warning
echo ""
print_error "WARNING: This will destroy all infrastructure resources!"
echo ""
echo "This includes:"
echo "  - EC2 instances"
echo "  - VPC and networking components"
echo "  - Security groups"
echo "  - (Optional) S3 bucket and DynamoDB table"
echo ""

read -p "Are you sure you want to continue? Type 'yes' to confirm: " confirm

if [ "$confirm" != "yes" ]; then
    print_status "Destruction cancelled."
    exit 0
fi

# Destroy main infrastructure
print_status "Destroying main infrastructure..."
terraform destroy -auto-approve

print_status "Main infrastructure destroyed successfully!"

# Ask about backend
echo ""
print_warning "Do you want to destroy the backend infrastructure (S3 + DynamoDB)?"
print_warning "This will delete your Terraform state bucket!"
read -p "Destroy backend? (y/n): " destroy_backend

if [ "$destroy_backend" = "y" ] || [ "$destroy_backend" = "Y" ]; then
    print_status "Destroying backend infrastructure..."
    cd modules/backend
    terraform destroy -auto-approve
    cd ../..
    print_status "Backend infrastructure destroyed!"
fi

echo ""
print_status "All selected resources have been destroyed."
echo ""
print_warning "Remember to:"
echo "  1. Take screenshots of the destroy output"
echo "  2. Verify in AWS Console that resources are deleted"
echo "  3. Check for any remaining resources to avoid charges"
