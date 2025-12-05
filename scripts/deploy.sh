#!/bin/bash

# Deployment script for VPC + Bastion + NAT project
# This script helps deploy the infrastructure using Terraform or CloudFormation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "VPC + Bastion + NAT Deployment Script"
echo "=========================================="
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Warning: Terraform is not installed. CloudFormation deployment will be used."
    USE_TERRAFORM=false
else
    USE_TERRAFORM=true
fi

# Function to get current public IP
get_my_ip() {
    curl -s https://api.ipify.org
}

# Function to deploy with Terraform
deploy_terraform() {
    echo "Deploying with Terraform..."
    cd "$PROJECT_ROOT/terraform"
    
    if [ ! -f "terraform.tfvars" ]; then
        echo "Error: terraform.tfvars not found. Please create it from terraform.tfvars.example"
        exit 1
    fi
    
    terraform init
    terraform plan
    echo ""
    read -p "Do you want to apply these changes? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        terraform apply
        echo ""
        echo "Deployment complete! Check outputs above for connection details."
    else
        echo "Deployment cancelled."
    fi
}

# Function to deploy with CloudFormation
deploy_cloudformation() {
    echo "Deploying with CloudFormation..."
    
    MY_IP=$(get_my_ip)
    echo "Detected your IP: $MY_IP/32"
    
    read -p "Enter your AWS Key Pair name: " KEY_PAIR
    read -p "Enter stack name (default: vpc-bastion-nat): " STACK_NAME
    STACK_NAME=${STACK_NAME:-vpc-bastion-nat}
    
    aws cloudformation create-stack \
        --stack-name "$STACK_NAME" \
        --template-body file://"$PROJECT_ROOT/cloudformation/vpc-bastion-nat.yaml" \
        --parameters \
            ParameterKey=MyIP,ParameterValue="$MY_IP/32" \
            ParameterKey=KeyPairName,ParameterValue="$KEY_PAIR" \
        --capabilities CAPABILITY_NAMED_IAM
    
    echo ""
    echo "Stack creation initiated. Waiting for completion..."
    aws cloudformation wait stack-create-complete --stack-name "$STACK_NAME"
    
    echo ""
    echo "Stack created successfully!"
    echo ""
    echo "Outputs:"
    aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query 'Stacks[0].Outputs' --output table
}

# Main deployment logic
echo "Select deployment method:"
echo "1) Terraform"
echo "2) CloudFormation"
read -p "Enter choice (1 or 2): " choice

case $choice in
    1)
        if [ "$USE_TERRAFORM" = true ]; then
            deploy_terraform
        else
            echo "Error: Terraform is not installed."
            exit 1
        fi
        ;;
    2)
        deploy_cloudformation
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

