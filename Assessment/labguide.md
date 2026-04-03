# AWS Web Application Deployment - Lab Overview

## What Was Built

This lab environment demonstrates a fully automated AWS web application deployment using AWS CloudFormation. The entire infrastructure was provisioned automatically without any manual steps.

The following AWS resources were created automatically by the CloudFormation template:

| Resource | Details |
|---|---|
| **Amazon VPC** | Custom VPC (10.0.0.0/16) with two public subnets, Internet Gateway, and route tables |
| **Security Groups** | EC2 Security Group (HTTP port 80, SSH port 22, RDP port 3389) and RDS Security Group (MySQL port 3306 from EC2 only) |
| **IAM Role** | Least-privilege EC2 instance role for CloudFormation signaling and CloudWatch Logs |
| **Amazon RDS** | MySQL 8.0 database (db.t3.micro) with the `webappdb` database and `users` table created automatically |
| **Amazon EC2** | Amazon Linux 2 instance (t3.small) with Apache, PHP 8.2, MySQL client, and xRDP installed via User Data |
| **Elastic IP** | Static public IP associated with the EC2 instance |

## What the EC2 User Data Script Did

On first boot, the EC2 instance automatically:

1. Installed Apache (httpd), PHP 8.2, MySQL client, and xRDP
2. Enabled password-based SSH authentication
3. Created the lab user account with sudo privileges
4. Started and enabled the Apache web server
5. Waited for the RDS database to become available
6. Created the `users` table in the RDS MySQL database
7. Deployed the PHP web application (`index.php` and `db_config.php`)
8. Sent a success signal to CloudFormation to mark the stack as complete

## Accessing the Web Application

1. Copy the **WebAppURL** from the Environment Details panel on the left.
2. Open it in a new browser tab.
3. Enter a **Full Name** and **Address** in the form and click **Save to Database**.
4. The record will be stored in RDS and displayed in the table below the form.

## Environment Details

All connection details are available in the **Environment Details** panel on the left side of this page, including the web application URL, EC2 IP address, SSH command, RDP connection, and login credentials.