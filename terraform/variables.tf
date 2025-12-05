variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "vpc-bastion-nat"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair for EC2 instances (optional - leave empty to use SSM Session Manager only)"
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (optional - will use SSM Parameter if not provided)"
  type        = string
  default     = ""
}

