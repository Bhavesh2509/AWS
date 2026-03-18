---

# AWS CloudFormation: VPC with EC2 (Public) and RDS MySQL (Private)

This CloudFormation template provisions a **highly available VPC environment** with:

* A **public EC2 instance** (with SSH & HTTP access)
* A **private MySQL RDS instance** (accessible only from the EC2 instance)
* Proper **security groups, subnets, route tables, and internet gateway**

It’s ideal for learning, testing, and demo environments.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Template Parameters](#template-parameters)
3. [Resources Provisioned](#resources-provisioned)
4. [Deployment Steps](#deployment-steps)
5. [Connecting to EC2 and RDS](#connecting-to-ec2-and-rds)
6. [Troubleshooting](#troubleshooting)
7. [Security Notes](#security-notes)

---

## Prerequisites

Before launching this template, ensure:

* You have an AWS account with permission to create VPCs, EC2 instances, and RDS instances.
* A **key pair** named `Pub1` exists in the selected region (used for EC2 SSH login).
* At least **2 Availability Zones** in the region.

---

## Template Parameters

| Parameter              | Description               | Default                                                                 | Notes                                                       |
| ---------------------- | ------------------------- | ----------------------------------------------------------------------- | ----------------------------------------------------------- |
| `LatestAmazonLinuxAMI` | Amazon Linux 2023 AMI ID  | `/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64` | Can override to a specific AMI ID                           |
| `Password`             | EC2 `ec2-user` password   | `demo12345`                                                             | Used for SSH login via password (enabled in user-data)      |
| `DBPassword`           | MySQL root/admin password | `demo12345`                                                             | Must be at least 8 characters. Default is for demo purposes |

> ⚠️ **Note:** Using hardcoded passwords is insecure for production. Consider using **AWS Secrets Manager** or **SSM Parameter Store** for secure credentials.

---

## Resources Provisioned

1. **VPC:** `192.168.0.0/16`
2. **Public Subnets:** `192.168.1.0/24`, `192.168.2.0/24`
3. **Private Subnets:** `192.168.3.0/24`, `192.168.4.0/24`
4. **Internet Gateway:** Attached to VPC for public internet access
5. **Public Route Table:** Routes `0.0.0.0/0` to IGW
6. **EC2 Security Group:** SSH (22) and HTTP (80) from anywhere
7. **RDS Security Group:** MySQL (3306) only from EC2 security group
8. **RDS Subnet Group:** Includes private subnets for RDS instance
9. **EC2 Instance:** t3.micro, Amazon Linux 2023, Nginx installed, password login enabled
10. **RDS MySQL Instance:** db.t3.micro, MySQL 8.0.36, private, non-publicly accessible

---

## Deployment Steps

1. Open the **AWS CloudFormation** console.
2. Click **Create stack → With new resources (standard)**.
3. Upload the template JSON file.
4. Configure parameters (or leave defaults):

   * `LatestAmazonLinuxAMI`
   * `Password` for EC2
   * `DBPassword` for RDS
5. Click **Next → Next → Create stack**.
6. Wait until the stack shows **CREATE_COMPLETE** status.
7. Check the **Outputs** section for:

   * EC2 Public IP
   * SSH command
   * RDS endpoint
   * MySQL connect command

---

## Connecting to EC2 and RDS

### SSH into EC2

```bash
ssh ec2-user@<EC2_Public_IP>
```

> Password login is enabled through the CloudFormation **user-data script**.

### Test HTTP Server

```bash
curl http://<EC2_Public_IP>
```

You should see the default Nginx welcome page.

### Connect to RDS MySQL from EC2

```bash
mysql -h <RDS_Endpoint> -u admin -p
```

Enter the `DBPassword` specified during stack creation.

> MariaDB client is installed on EC2 for testing RDS connectivity.

---

## Troubleshooting

| Issue                          | Possible Cause                                                   | Solution                                                                  |
| ------------------------------ | ---------------------------------------------------------------- | ------------------------------------------------------------------------- |
| **Cannot SSH into EC2**        | Key pair mismatch, wrong security group, password login disabled | Verify key pair `Pub1` exists. Ensure security group allows port 22.      |
| **RDS connection fails**       | RDS SG does not allow EC2 SG, wrong endpoint                     | Check RDS security group; connect from EC2 using private endpoint.        |
| **EC2 user-data script fails** | CloudFormation syntax errors, script not executed                | Check stack **Events** for errors; validate Base64 encoding of user-data. |
| **Multi-AZ RDS issues**        | Not enough AZs or subnet misconfigured                           | Ensure at least 2 private subnets in different AZs.                       |

---

## Security Notes

* Password login is enabled for demo purposes. **Do not use this in production**.
* For production, use:

  * **Key-based SSH login**
  * **AWS Secrets Manager** or **SSM Parameter Store** for DB credentials
* Limit EC2 Security Group access to trusted IP ranges instead of `0.0.0.0/0`.

---

## Example Commands After Deployment

```bash
# SSH into EC2
ssh ec2-user@<EC2_PublicIP>

# Test HTTP server
curl http://<EC2_PublicIP>

# Connect to RDS MySQL
mysql -h <RDS_Endpoint> -u admin -p
```

---

This README provides a full guide for **launching, connecting, and troubleshooting** the stack.

---
