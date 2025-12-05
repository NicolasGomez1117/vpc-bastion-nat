# Terraform Setup Guide

## How Terraform Connects to AWS

**Short answer:** Terraform uses your **AWS credentials** (same ones AWS CLI uses) to authenticate with AWS and create/manage resources in your account.

## Step-by-Step Setup

### 1. Install Terraform

**macOS (using Homebrew):**
```bash
brew install terraform
```

**Or download directly:**
- Visit: https://www.terraform.io/downloads
- Download for your OS
- Extract and add to PATH

**Verify installation:**
```bash
terraform version
```

### 2. Configure AWS Credentials

Terraform automatically uses AWS credentials from one of these sources (in order):

#### Option A: AWS CLI Configuration (Recommended)
If you already have AWS CLI configured, Terraform will use those credentials automatically:

```bash
# Check if AWS CLI is configured
aws configure list

# If not configured, run:
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key  
# - Default region (e.g., us-east-1)
# - Default output format (json)
```

#### Option B: Environment Variables
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

#### Option C: AWS Credentials File
Terraform reads from `~/.aws/credentials`:
```ini
[default]
aws_access_key_id = your-access-key
aws_secret_access_key = your-secret-key
```

### 3. Create SSH Key Pair in AWS

**Important:** You need an EC2 Key Pair in AWS before deploying:

1. Go to AWS Console → EC2 → Key Pairs
2. Click "Create key pair"
3. Name it (e.g., `saa-project1`)
4. Choose `.pem` format
5. Download the `.pem` file
6. Save it somewhere safe (e.g., `~/.ssh/saa-project1.pem`)
7. Set permissions:
   ```bash
   chmod 400 ~/.ssh/saa-project1.pem
   ```

### 4. Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
aws_region   = "us-east-1"
project_name = "vpc-bastion-nat"
key_pair_name = "saa-project1"  # Must match the key pair name in AWS
```

### 5. Test Terraform Connection

```bash
cd terraform
terraform init
```

This will:
- Download the AWS provider plugin
- Set up Terraform backend
- Verify it can connect to AWS

**If you see errors:**
- Check AWS credentials: `aws sts get-caller-identity`
- Verify region is correct
- Check AWS permissions (you need: EC2, VPC, IAM permissions)

### 6. Preview What Will Be Created

```bash
terraform plan
```

This shows you:
- What resources will be created
- What the configuration will look like
- **No changes are made** - it's just a preview

### 7. Deploy Infrastructure

```bash
terraform apply
```

Terraform will:
- Ask for confirmation
- Create all resources in your AWS account
- Show progress as it creates VPC, subnets, EC2 instances, etc.
- Take about 3-5 minutes

### 8. Get Connection Info

After deployment, Terraform outputs the SSH commands:

```bash
terraform output
```

You'll see:
- Bastion public IP
- Private EC2 IP
- Ready-to-use SSH commands

### 9. Clean Up (When Done Testing)

**Important:** Destroy everything to avoid charges:

```bash
terraform destroy
```

This will delete all resources created by Terraform.

## How It Works Behind the Scenes

1. **Terraform reads your config** (`main.tf`, `variables.tf`, etc.)
2. **Authenticates with AWS** using your credentials
3. **Creates a state file** (`.tfstate`) to track what it created
4. **Makes API calls to AWS** to create resources (VPC, EC2, etc.)
5. **Stores state locally** so it knows what to update/destroy later

## Troubleshooting

### "Error: No valid credential sources found"
- Run `aws configure` or set environment variables
- Verify: `aws sts get-caller-identity`

### "Error: InvalidKeyPair.NotFound"
- The key pair name in `terraform.tfvars` doesn't exist in AWS
- Create the key pair in AWS Console first

### "Error: UnauthorizedOperation"
- Your AWS credentials don't have enough permissions
- You need: EC2, VPC, IAM permissions

### "Error: InsufficientInstanceCapacity"
- Try a different region or availability zone
- Or wait a few minutes and try again

## Security Notes

- **Never commit `terraform.tfvars`** to git (it's in `.gitignore`)
- **Never commit `.tfstate` files** (they may contain sensitive data)
- **Keep your `.pem` key file secure** (also in `.gitignore`)
- **Use IAM roles** in production (not access keys)

## Quick Test Commands

```bash
# 1. Verify AWS connection
aws sts get-caller-identity

# 2. Initialize Terraform
cd terraform
terraform init

# 3. Preview changes
terraform plan

# 4. Deploy (if plan looks good)
terraform apply

# 5. View outputs
terraform output

# 6. Destroy when done
terraform destroy
```

