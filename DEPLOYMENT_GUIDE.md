# Deployment Guide - Reproducible Infrastructure

This guide explains how to deploy this Terraform project on **ANY free-tier AWS account** without hardcoded values.

## What Makes This Reproducible

✅ **No hardcoded ARNs** - All AWS resource IDs are dynamically generated  
✅ **No hardcoded account numbers** - Works on any AWS account  
✅ **No hardcoded IPs** - Your IP is auto-detected; instances get dynamic IPs  
✅ **Configurable via tfvars** - One file to customize per deployment  
✅ **IAM roles defined in Terraform** - No manual role creation needed  
✅ **SSM Session Manager included** - Secure shell access without key distribution  

## Prerequisites

1. **AWS Account** - With AWS CLI credentials configured
   ```bash
   aws configure
   # Enter your Access Key ID, Secret Access Key, Region (us-east-1), Output format (json)
   ```

2. **Terraform** - Version 1.0 or later
   ```bash
   terraform version
   ```

3. **EC2 Key Pair** - Create one in your AWS account
   ```bash
   # Option 1: Via AWS Console
   # https://console.aws.amazon.com/ec2/v2/home#KeyPairs:
   
   # Option 2: Via CLI
   aws ec2 create-key-pair --key-name my-key-pair --query 'KeyMaterial' --output text > ~/.ssh/my-key-pair.pem
   chmod 400 ~/.ssh/my-key-pair.pem
   ```

## Step 1: Prepare Configuration

```bash
cd terraform

# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your settings
# CRITICAL: Update key_pair_name to match your created key pair
nano terraform.tfvars
```

**terraform.tfvars** should contain:
```hcl
aws_region    = "us-east-1"          # Or your preferred region
project_name  = "vpc-bastion-nat"    # Or any project name
key_pair_name = "my-key-pair"        # Your actual key pair name
# ami_id = ""                         # Optional - auto-detects latest Amazon Linux 2023
```

## Step 2: Initialize Terraform

```bash
terraform init
```

This downloads AWS provider plugins and initializes the working directory.

## Step 3: Review the Plan

```bash
terraform plan -out=plan.tfplan
```

Review the output to ensure it will create:
- 1 VPC with public/private subnets
- 2 EC2 instances (bastion + private)
- 1 NAT Gateway with Elastic IP
- Route tables, security groups, IAM roles
- Total: ~14 resources

## Step 4: Deploy

```bash
terraform apply plan.tfplan
```

Wait 2-3 minutes for all resources to be created. You'll see:
- VPC creation
- Subnet and route table setup
- NAT Gateway launch (takes ~1-2 minutes)
- EC2 instance launches

## Step 5: Access Your Infrastructure

After deployment, Terraform outputs will show:

```
bastion_public_ip = "98.92.55.164"
bastion_private_ip = "10.0.1.36"
private_instance_ip = "10.0.2.254"
vpc_id = "vpc-07019cb13b6fc9ea3"
```

### Option A: Traditional SSH (via bastion jump)

```bash
# 1. SSH into bastion
ssh -i ~/.ssh/my-key-pair.pem ec2-user@<bastion_public_ip>

# 2. From bastion, SSH to private instance
ssh -i my-key-pair.pem ec2-user@<private_instance_ip>

# Or use ProxyJump in one command:
ssh -i ~/.ssh/my-key-pair.pem \
    -J ec2-user@<bastion_public_ip> \
    ec2-user@<private_instance_ip>
```

### Option B: AWS Systems Manager Session Manager (Recommended)

No SSH keys needed! This is more secure for portfolios.

```bash
# Get instance IDs from Terraform state or AWS console
BASTION_ID=$(terraform output -raw | grep bastion)
PRIVATE_ID=$(terraform output -raw | grep private)

# Start SSM session to private instance (via bastion automatically)
aws ssm start-session --target i-0be0a8b8102c9ab59 --region us-east-1
```

**Note**: You need `ssm:StartSession` IAM permission for this.

### Option C: Port Forwarding via SSM

```bash
# Forward local port 2222 to private instance's SSH port
aws ssm start-session \
  --target i-0be0a8b8102c9ab59 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["22"],"localPortNumber":["2222"]}'

# In another terminal, SSH through the tunnel
ssh -i ~/.ssh/my-key-pair.pem -p 2222 ec2-user@localhost
```

## Step 6: Verify Infrastructure

```bash
# Check VPC exists
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_id)

# Check instances are running
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=vpc-bastion-nat-*" \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name]' \
  --output table

# Check NAT Gateway is working
aws ec2 describe-nat-gateways \
  --query 'NatGateways[*].[NatGatewayId,State]' \
  --output table
```

## Clean Up (Destroy Resources)

When done testing:

```bash
terraform destroy -auto-approve
```

This removes:
- EC2 instances
- VPC and subnets
- NAT Gateway and Elastic IP
- Security groups and route tables
- IAM roles and instance profiles

**Cost**: Free tier covers all resources (EC2 t3.micro, 15 GB NAT Gateway data, etc.)

## Troubleshooting

### "InvalidKeyPair.NotFound"
- Your `key_pair_name` in terraform.tfvars doesn't match an actual key pair in your AWS account
- Create the key pair first, then update terraform.tfvars

### "AccessDenied" during terraform apply
- Your IAM user needs EC2, IAM, and VPC permissions
- Minimum required: `ec2:*`, `iam:*`, `ssm:GetParameter`
- For least-privilege, reference the IAM policy in `TERRAFORM_SETUP.md`

### Can't SSH to bastion
- Verify security group allows SSH from your IP
- Check that your public IP hasn't changed (Terraform auto-detects it)
- Verify your key pair PEM file has correct permissions: `chmod 400 ~/.ssh/my-key.pem`

### NAT Gateway takes a long time
- This is normal - NAT Gateways take 1-2 minutes to initialize
- Terraform will wait for it to be ready before continuing

## Portfolio Best Practices Applied

✅ **Infrastructure as Code** - Complete definition in `main.tf`, `variables.tf`, `outputs.tf`  
✅ **Configuration Separation** - Variables in `terraform.tfvars`, code in `main.tf`  
✅ **Example Configuration** - `terraform.tfvars.example` for new users  
✅ **No Hardcoded Secrets** - Key pairs referenced by name, not embedded  
✅ **Dynamic IP Detection** - Auto-detects your IP for security group rules  
✅ **Reproducible** - Same code deploys identically on any account  
✅ **Self-Contained IAM** - Roles and policies defined in Terraform  
✅ **SSM Integration** - Modern, secure shell access without key distribution  
✅ **Clear Documentation** - This guide for any future deployer  

## Next Steps

1. **Document your architecture** - Add a diagram (included in main README)
2. **Add monitoring** - CloudWatch alarms for NAT Gateway and EC2
3. **Implement bastion hardening** - Custom security group rules, OS hardening
4. **Add logging** - VPC Flow Logs to S3, CloudTrail for API auditing
5. **Scale to multi-AZ** - Add instances in other availability zones
6. **Automate updates** - Use Systems Manager Session Manager for patching

## References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-best-practices.html)
- [Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [AWS EC2 Key Pairs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
