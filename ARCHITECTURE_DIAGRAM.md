# Architecture Diagram

## Diagram Description

This document describes the architecture diagram that should be created for this project. You can use tools like:
- Draw.io / diagrams.net
- Lucidchart
- AWS Architecture Icons
- Excalidraw
- Or any diagramming tool

## Components to Include

### Network Components

1. **VPC** (10.0.0.0/16)
   - Large rectangle representing the VPC boundary
   - Label: "VPC (10.0.0.0/16)"

2. **Public Subnet** (10.0.1.0/24)
   - Rectangle within VPC
   - Label: "Public Subnet (10.0.1.0/24)"
   - Contains: Bastion Host, NAT Gateway

3. **Private Subnet** (10.0.2.0/24)
   - Rectangle within VPC (below public subnet)
   - Label: "Private Subnet (10.0.2.0/24)"
   - Contains: Private EC2 Instance

### Internet Connectivity

4. **Internet Gateway**
   - Icon/box outside VPC, connected to VPC
   - Label: "Internet Gateway"
   - Arrow from Internet Gateway to VPC

5. **NAT Gateway**
   - Icon/box in public subnet
   - Label: "NAT Gateway"
   - Connected to Internet Gateway
   - Connected to private subnet route

### Compute Resources

6. **Bastion Host**
   - EC2 icon in public subnet
   - Label: "Bastion Host (t3.micro)"
   - Public IP shown
   - Security Group icon attached

7. **Private EC2 Instance**
   - EC2 icon in private subnet
   - Label: "Private EC2 (t3.micro)"
   - Private IP shown (no public IP)
   - Security Group icon attached

### Routing

8. **Route Tables**
   - Public Route Table:
     - 10.0.0.0/16 → local
     - 0.0.0.0/0 → Internet Gateway
   - Private Route Table:
     - 10.0.0.0/16 → local
     - 0.0.0.0/0 → NAT Gateway

### Security Groups

9. **Bastion Security Group**
   - Inbound: SSH (22) from My IP only
   - Outbound: All traffic

10. **Private Security Group**
    - Inbound: SSH (22) from Bastion SG only
    - Outbound: All traffic

### Access Flow

11. **SSH Flow Arrows**
    - Arrow from "Internet" → Bastion (labeled "SSH from My IP")
    - Arrow from Bastion → Private EC2 (labeled "SSH via Bastion")

12. **Outbound Flow**
    - Arrow from Private EC2 → NAT Gateway → Internet Gateway → Internet
    - Label: "Outbound via NAT"

## Visual Layout Suggestions

```
┌─────────────────────────────────────────────────────────┐
│                    INTERNET                              │
└────────────────────┬────────────────────────────────────┘
                     │
            ┌────────▼────────┐
            │ Internet Gateway│
            └────────┬────────┘
                     │
    ┌────────────────┴────────────────┐
    │         VPC (10.0.0.0/16)       │
    │                                  │
    │  ┌──────────────────────────┐   │
    │  │ Public Subnet            │   │
    │  │ (10.0.1.0/24)            │   │
    │  │                          │   │
    │  │  [Bastion Host]          │   │
    │  │  [NAT Gateway]           │   │
    │  └──────────────────────────┘   │
    │                                  │
    │  ┌──────────────────────────┐   │
    │  │ Private Subnet           │   │
    │  │ (10.0.2.0/24)            │   │
    │  │                          │   │
    │  │  [Private EC2]           │   │
    │  └──────────────────────────┘   │
    │                                  │
    └──────────────────────────────────┘
```

## Color Coding Suggestions

- **VPC**: Light blue background
- **Public Subnet**: Light green
- **Private Subnet**: Light orange/red
- **Internet Gateway**: Blue
- **NAT Gateway**: Yellow
- **Security Groups**: Red borders/outlines
- **SSH Flow**: Green arrows
- **Data Flow**: Blue arrows

## Tools for Creating the Diagram

### Recommended Tools:

1. **Draw.io (diagrams.net)**
   - Free, web-based
   - AWS icons available
   - Export to PNG/SVG

2. **Lucidchart**
   - Professional diagrams
   - AWS template available
   - Free tier available

3. **AWS Architecture Icons**
   - Official AWS icons
   - Download from: https://aws.amazon.com/architecture/icons/
   - Use with any diagramming tool

4. **Excalidraw**
   - Hand-drawn style
   - Free and open source
   - Good for quick diagrams

## Export Requirements

- **Format**: PNG or SVG
- **Resolution**: At least 1920x1080 for clarity
- **File Name**: `architecture-diagram.png`
- **Location**: Root of project directory

## Example Diagram Checklist

- [ ] VPC boundary clearly shown
- [ ] Public and private subnets labeled with CIDR blocks
- [ ] Internet Gateway attached to VPC
- [ ] NAT Gateway in public subnet
- [ ] Bastion host in public subnet with public IP
- [ ] Private EC2 in private subnet (no public IP)
- [ ] Route table routes shown (or implied)
- [ ] Security group rules documented
- [ ] SSH access flow arrows shown
- [ ] Outbound NAT flow shown
- [ ] All components labeled clearly
- [ ] Professional appearance suitable for portfolio

