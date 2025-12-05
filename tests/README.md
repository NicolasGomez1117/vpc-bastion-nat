# Test Results

This directory contains test results and validation outputs.

## Test Files

1. **curl-results.txt** - Results from curl tests on private instance
2. **nmap-scan.txt** - Port scan results showing private instance is not accessible
3. **traceroute.txt** - Traceroute output from private instance showing NAT Gateway routing
4. **nat-gateway-ip.txt** - NAT Gateway public IP verification
5. **bastion-sg.json** - Bastion security group configuration (JSON export)

## Running Tests

Use the provided `scripts/verify.sh` script to automatically run tests and save results here.

Alternatively, run tests manually:

```bash
# Test NAT Gateway
ssh -i key.pem ec2-user@34.205.50.56 \
  "ssh -i key.pem ec2-user@10.0.2.10 'curl https://api.ipify.org'" \
  > tests/curl-results.txt

# Port scan
nmap -p 22 10.0.2.10 > tests/nmap-scan.txt

# Traceroute
ssh -i key.pem ec2-user@34.205.50.56 \
  "ssh -i key.pem ec2-user@10.0.2.10 'traceroute 8.8.8.8'" \
  > tests/traceroute.txt
```

## Expected Results

- **curl-results.txt**: Should show NAT Gateway's public IP
- **nmap-scan.txt**: Should show port 22 as filtered/closed
- **traceroute.txt**: Should show routing through NAT Gateway
- **nat-gateway-ip.txt**: Should contain the NAT Gateway's Elastic IP

