# Automation of Basic AWS Web Application Deployment

## Lab Overview

In this lab, a complete AWS web application infrastructure has been deployed automatically using an AWS CloudFormation template. The environment includes an EC2 web server, an RDS MySQL database, Apache web server, and a PHP application — all provisioned without any manual steps.

## Architecture

| Component | Details |
|---|---|
| **EC2 Instance** | Amazon Linux 2, t3.small, Apache + PHP 8.2 |
| **RDS Database** | MySQL 8.0, db.t3.micro |
| **Web Server** | Apache (httpd) serving PHP application on port 80 |
| **Networking** | Custom VPC, public subnets, Internet Gateway |
| **Security** | EC2 Security Group (HTTP/SSH/RDP), RDS Security Group (MySQL from EC2 only) |
| **IAM** | Least-privilege EC2 role for CloudFormation signaling |

## What Was Automated

The CloudFormation template automatically performed all of the following:

1. Created a custom VPC with public subnets across two Availability Zones
2. Created an Internet Gateway and configured routing
3. Created Security Groups for EC2 (HTTP, SSH, RDP) and RDS (MySQL from EC2 only)
4. Created an IAM Role for the EC2 instance with least-privilege permissions
5. Provisioned an RDS MySQL 8.0 database instance
6. Launched an EC2 instance with a User Data script that:
   - Installed Apache, PHP 8.2, MySQL client, and xRDP
   - Enabled password-based SSH authentication
   - Created the lab user account
   - Started and enabled Apache web server
   - Waited for RDS to become available
   - Created the `users` database table
   - Deployed the PHP web application (`index.php` and `db_config.php`)
7. Allocated an Elastic IP and associated it with the EC2 instance

## Lab Credentials

Your environment credentials are available in the **Environment Details** panel on the left side of this page.

| Item | Where to Find It |
|---|---|
| Web Application URL | `WebAppURL` in Environment Details |
| EC2 IP Address | `EC2ElasticIP` in Environment Details |
| SSH Command | `SSHCommand` in Environment Details |
| RDP Connection | `RDPConnection` in Environment Details |
| Linux Username | `LinuxUsername` in Environment Details |
| Linux Password | Available in Environment Details |
| RDS Endpoint | `RDSEndpoint` in Environment Details |

## Duration

Estimated time to complete this lab: **30 minutes**