#!/bin/bash

# One-click Terraform deploy + SSH helper
# This script deploys the infrastructure and optionally opens an SSH session

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TF_DIR="$PROJECT_ROOT/terraform"

echo "=========================================="
echo "Terraform One-Click Deploy + SSH"
echo "=========================================="
echo ""

# Check if Terraform is installed
if ! command -v terraform >/dev/null 2>&1; then
    echo "Error: Terraform is not installed."
    echo "Install it with: brew install terraform"
    echo "Or visit: https://www.terraform.io/downloads"
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "Error: AWS credentials not configured."
    echo "Run: aws configure"
    echo "Or set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables"
    exit 1
fi

cd "$TF_DIR"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "Error: terraform.tfvars not found."
    echo ""
    echo "Please create it from the example:"
    echo "  cp terraform.tfvars.example terraform.tfvars"
    echo ""
    echo "Then edit terraform.tfvars and set:"
    echo "  - key_pair_name (must exist in AWS)"
    echo "  - aws_region (optional, defaults to us-east-1)"
    echo "  - project_name (optional, defaults to vpc-bastion-nat)"
    exit 1
fi

echo "Initializing Terraform (if needed)..."
terraform init -input=false >/dev/null 2>&1

echo ""
echo "Planning deployment (preview of changes)..."
terraform plan

echo ""
read -p "Do you want to apply these changes? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo "Applying Terraform (this may take 3-5 minutes)..."
terraform apply -auto-approve

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""

# Get outputs
BASTION_CMD=$(terraform output -raw ssh_bastion_command 2>/dev/null || echo "")
PRIVATE_CMD=$(terraform output -raw ssh_private_command 2>/dev/null || echo "")
BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null || echo "")
PRIVATE_IP=$(terraform output -raw private_instance_ip 2>/dev/null || echo "")
NAT_IP=$(terraform output -raw nat_gateway_ip 2>/dev/null || echo "")

echo "Infrastructure Details:"
echo "  Bastion Public IP:  $BASTION_IP"
echo "  Private EC2 IP:     $PRIVATE_IP"
echo "  NAT Gateway IP:     $NAT_IP"
echo ""

if [ -n "$BASTION_CMD" ]; then
    echo "To SSH into the bastion from your machine:"
    echo "  $BASTION_CMD"
    echo ""
fi

if [ -n "$PRIVATE_CMD" ]; then
    echo "Once on the bastion, SSH into the private EC2 with:"
    echo "  $PRIVATE_CMD"
    echo ""
fi

# Extract key path from SSH command
KEY_PATH=$(echo "$BASTION_CMD" | grep -o '\-i [^ ]*' | cut -d' ' -f2 || echo "")

if [ -n "$BASTION_CMD" ] && [ -n "$KEY_PATH" ] && [ -f "$KEY_PATH" ]; then
    read -p "SSH into bastion now? (y/n): " answer
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        echo ""
        echo "Opening SSH session to bastion..."
        echo "Once connected, you can SSH to private EC2 with: $PRIVATE_CMD"
        echo ""
        eval "$BASTION_CMD"
    else
        echo ""
        echo "You can SSH later using the commands shown above."
    fi
else
    echo "Note: SSH key not found at expected path."
    echo "You'll need to manually SSH using the commands above."
fi

echo ""
echo "To destroy all resources when done testing:"
echo "  cd terraform && terraform destroy"

