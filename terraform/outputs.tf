output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private Subnet ID"
  value       = aws_subnet.private.id
}

output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Bastion host private IP"
  value       = aws_instance.bastion.private_ip
}

output "private_instance_ip" {
  description = "Private EC2 instance IP"
  value       = aws_instance.private.private_ip
}

output "nat_gateway_ip" {
  description = "NAT Gateway public IP"
  value       = aws_eip.nat.public_ip
}

output "access_bastion_command" {
  description = "Command to access bastion (uses SSM Session Manager or SSH depending on configuration)"
  value       = var.key_pair_name != "" ? "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.bastion.public_ip}" : "aws ssm start-session --target ${aws_instance.bastion.id}"
}

output "access_private_command" {
  description = "Command to access private instance (uses SSM Session Manager or SSH depending on configuration)"
  value       = var.key_pair_name != "" ? "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.private.private_ip}" : "aws ssm start-session --target ${aws_instance.private.id}"
}

output "bastion_instance_id" {
  description = "Bastion instance ID (for SSM access)"
  value       = aws_instance.bastion.id
}

output "private_instance_id" {
  description = "Private instance ID (for SSM access)"
  value       = aws_instance.private.id
}

