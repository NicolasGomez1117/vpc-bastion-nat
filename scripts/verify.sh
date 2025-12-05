#!/bin/bash

# Verification script for VPC + Bastion + NAT project
# This script runs various tests to verify the infrastructure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TESTS_DIR="$PROJECT_ROOT/tests"

# Create tests directory if it doesn't exist
mkdir -p "$TESTS_DIR"

echo "=========================================="
echo "VPC + Bastion + NAT Verification Script"
echo "=========================================="
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed."
    exit 1
fi

# Get stack name or instance details
read -p "Enter CloudFormation stack name (or press Enter to skip): " STACK_NAME
read -p "Enter Bastion public IP: " BASTION_IP
read -p "Enter Private EC2 private IP: " PRIVATE_IP
read -p "Enter path to SSH key (e.g., ~/.ssh/key.pem): " SSH_KEY

if [ -z "$SSH_KEY" ]; then
    echo "Error: SSH key path is required."
    exit 1
fi

# Expand ~ to home directory
SSH_KEY="${SSH_KEY/#\~/$HOME}"

if [ ! -f "$SSH_KEY" ]; then
    echo "Error: SSH key file not found: $SSH_KEY"
    exit 1
fi

echo ""
echo "Running verification tests..."
echo ""

# Test 1: Verify private instance is not reachable from internet
echo "Test 1: Verifying private instance is not reachable from internet..."
if timeout 5 ssh -i "$SSH_KEY" -o ConnectTimeout=3 -o StrictHostKeyChecking=no ec2-user@"$PRIVATE_IP" "echo 'Connected'" 2>/dev/null; then
    echo "❌ FAILED: Private instance is reachable from internet (security issue!)"
else
    echo "✅ PASSED: Private instance is not reachable from internet"
fi
echo ""

# Test 2: Verify NAT Gateway functionality
echo "Test 2: Verifying NAT Gateway functionality..."
NAT_IP=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ec2-user@"$BASTION_IP" "ssh -i $SSH_KEY -o StrictHostKeyChecking=no ec2-user@$PRIVATE_IP 'curl -s https://api.ipify.org'" 2>/dev/null || echo "")
if [ -n "$NAT_IP" ]; then
    echo "✅ PASSED: Private instance can reach internet via NAT Gateway"
    echo "   NAT Gateway IP: $NAT_IP"
    echo "$NAT_IP" > "$TESTS_DIR/nat-gateway-ip.txt"
else
    echo "❌ FAILED: Private instance cannot reach internet"
fi
echo ""

# Test 3: Port scan on private instance (from local machine)
echo "Test 3: Scanning private instance ports (should be filtered)..."
if command -v nmap &> /dev/null; then
    nmap -p 22 "$PRIVATE_IP" > "$TESTS_DIR/nmap-scan.txt" 2>&1
    if grep -q "filtered\|closed" "$TESTS_DIR/nmap-scan.txt"; then
        echo "✅ PASSED: Port 22 is filtered/closed from internet"
    else
        echo "⚠️  WARNING: Port scan results unclear"
    fi
    echo "   Results saved to tests/nmap-scan.txt"
else
    echo "⚠️  SKIPPED: nmap not installed"
fi
echo ""

# Test 4: Traceroute from private instance
echo "Test 4: Running traceroute from private instance..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ec2-user@"$BASTION_IP" \
    "ssh -i $SSH_KEY -o StrictHostKeyChecking=no ec2-user@$PRIVATE_IP 'traceroute -m 5 8.8.8.8'" \
    > "$TESTS_DIR/traceroute.txt" 2>&1 || echo "Traceroute failed or timed out" > "$TESTS_DIR/traceroute.txt"
echo "✅ Traceroute results saved to tests/traceroute.txt"
echo ""

# Test 5: Verify security group rules
if [ -n "$STACK_NAME" ]; then
    echo "Test 5: Verifying security group configurations..."
    BASTION_SG=$(aws cloudformation describe-stack-resources \
        --stack-name "$STACK_NAME" \
        --query "StackResources[?LogicalResourceId=='BastionSecurityGroup'].PhysicalResourceId" \
        --output text 2>/dev/null || echo "")
    
    if [ -n "$BASTION_SG" ]; then
        echo "   Bastion Security Group: $BASTION_SG"
        aws ec2 describe-security-groups --group-ids "$BASTION_SG" --query 'SecurityGroups[0].IpPermissions' --output json > "$TESTS_DIR/bastion-sg.json" 2>/dev/null || true
    fi
    echo "✅ Security group details saved"
fi
echo ""

# Test 6: Connectivity test
echo "Test 6: Testing connectivity..."
echo "   Testing: Local → Bastion"
if ssh -i "$SSH_KEY" -o ConnectTimeout=5 -o StrictHostKeyChecking=no ec2-user@"$BASTION_IP" "echo 'Connected to bastion'" 2>/dev/null; then
    echo "   ✅ Local → Bastion: SUCCESS"
else
    echo "   ❌ Local → Bastion: FAILED"
fi

echo "   Testing: Bastion → Private EC2"
if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ec2-user@"$BASTION_IP" \
    "ssh -i $SSH_KEY -o ConnectTimeout=5 -o StrictHostKeyChecking=no ec2-user@$PRIVATE_IP 'echo Connected to private instance'" 2>/dev/null; then
    echo "   ✅ Bastion → Private EC2: SUCCESS"
else
    echo "   ❌ Bastion → Private EC2: FAILED"
fi
echo ""

echo "=========================================="
echo "Verification complete!"
echo "Test results saved to: $TESTS_DIR"
echo "=========================================="

