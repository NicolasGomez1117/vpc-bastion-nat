# Screenshots

This directory contains screenshots demonstrating the implementation.

## Screenshots Included

✅ **vpc.png** - VPC configuration showing CIDR blocks and settings  
✅ **public-rtb.png** - Public route table showing routes to Internet Gateway  
✅ **private-rtb.png** - Private route table showing routes to NAT Gateway  
✅ **bastion-ssh.png** - Successful SSH connection to bastion host  
✅ **private-ssh.png** - Successful SSH connection to private EC2 from bastion  
✅ **bastion-sg-rules.png** - Bastion security group inbound/outbound rules  
✅ **private-sg-rules.png** - Private EC2 security group inbound/outbound rules  
✅ **nat-gateway.png** - NAT Gateway configuration and Elastic IP  

## Screenshot Descriptions

### VPC Configuration
Shows the VPC details including:
- CIDR block: 10.0.0.0/16
- DNS hostnames and DNS support enabled
- VPC ID and region

### Route Tables
- **Public Route Table**: Routes showing 10.0.0.0/16 → local and 0.0.0.0/0 → Internet Gateway
- **Private Route Table**: Routes showing 10.0.0.0/16 → local and 0.0.0.0/0 → NAT Gateway

### SSH Connections
- **Bastion SSH**: Terminal output showing successful connection to bastion host (34.205.50.56)
- **Private SSH**: Terminal output showing successful connection from bastion to private EC2 (10.0.2.10)

### Security Groups
- **Bastion Security Group**: Inbound rule allowing SSH (port 22) from specific IP only
- **Private Security Group**: Inbound rule allowing SSH (port 22) from bastion security group only

### NAT Gateway
Shows NAT Gateway details including:
- NAT Gateway ID and status
- Associated Elastic IP address
- Subnet placement (public subnet)
- Route table associations

