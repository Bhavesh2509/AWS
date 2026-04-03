# Task 3: Verify the Deployment

## Verification Checklist

Use this checklist to confirm all components of the automated deployment are working correctly.

| # | Verification Step | Expected Result | Status |
|---|---|---|---|
| 1 | Open `WebAppURL` in browser | PHP web application loads | ☐ |
| 2 | Submit name and address in form | Record appears in the table | ☐ |
| 3 | Submit multiple records | All records display, newest first | ☐ |
| 4 | Click Delete on a record | Record is removed from the table | ☐ |
| 5 | CloudFormation stack status | `CREATE_COMPLETE` | ☐ |
| 6 | EC2 instance state | `Running` | ☐ |
| 7 | RDS database status | `Available` | ☐ |
| 8 | EC2 Security Group port 80 open | Inbound rule for HTTP exists | ☐ |
| 9 | RDS Security Group port 3306 | Only allows traffic from EC2 SG | ☐ |
| 10 | SSH into EC2 with password | Login successful without key pair | ☐ |
| 11 | `/var/log/userdata.log` last line | `UserData completed successfully.` | ☐ |
| 12 | `systemctl status httpd` | `active (running)` | ☐ |

## Summary

### What Was Accomplished

In this lab, a complete AWS web application was deployed fully automatically using a single CloudFormation template. The following was achieved without any manual configuration:

- **Networking** — Custom VPC, subnets, Internet Gateway, and route tables created automatically
- **Security** — EC2 and RDS security groups configured with least-privilege access rules
- **IAM** — EC2 instance role created with only the permissions it needs
- **Database** — RDS MySQL 8.0 instance provisioned, database and table created automatically
- **Web Server** — Apache and PHP 8.2 installed, started, and enabled on boot automatically
- **Application** — PHP web application deployed automatically via EC2 User Data
- **Access** — Password-based SSH and RDP configured without requiring a key pair
- **Connectivity** — EC2 connected to RDS and verified working before CloudFormation reported success

### Key Concepts Demonstrated

| Concept | How It Was Applied |
|---|---|
| **Infrastructure as Code** | Entire stack defined in a single CloudFormation JSON template |
| **EC2 User Data** | Full server setup — packages, config, app deployment — runs automatically on first boot |
| **CreationPolicy Signaling** | CloudFormation waited for EC2 to signal success before marking stack complete |
| **Security Group Layering** | RDS only accepts MySQL connections from the EC2 Security Group, not the internet |
| **Least Privilege IAM** | EC2 role has only two permissions — CFN signal and CloudWatch Logs |
| **Separation of Config** | Database credentials in `db_config.php`, application logic in `index.php` |
| **Password Authentication** | SSH configured for password login by patching `sshd_config.d` to override cloud-init defaults |