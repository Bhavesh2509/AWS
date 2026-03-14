# AWS Application Load Balancer Setup with EC2 (Complete Guide)

This guide covers how to create an **Application Load Balancer (ALB)** in AWS and attach EC2 instances behind it.
It includes architecture explanation, setup steps, security configuration, and troubleshooting.

Services used:

* Amazon VPC
* Amazon EC2
* Elastic Load Balancing (Application Load Balancer)

---

# Architecture Overview

```
Internet
   |
   |
Application Load Balancer
(Public Subnets)
   |
Target Group
   |
Private / Public EC2 Instances
```

Production architecture usually looks like:

```
                    Internet
                        |
                        |
                Application Load Balancer
                   (Public Subnets)
                  /                 \
         Public Subnet AZ-A     Public Subnet AZ-B
                |                     |
         Private Subnet AZ-A     Private Subnet AZ-B
             EC2 Instance           EC2 Instance
            (No Public IP)         (No Public IP)
```

Traffic Flow:

```
User → Load Balancer → Target Group → EC2 Instances
```

---

# Prerequisites

Before creating a load balancer ensure:

* A VPC exists
* At least **2 subnets in different Availability Zones**
* EC2 instances running
* Security groups configured

---

# Step 1: Create or Verify VPC

Example VPC CIDR:

```
10.0.0.0/16
```

Typical subnet design:

| Subnet           | CIDR        | Purpose       |
| ---------------- | ----------- | ------------- |
| Public Subnet A  | 10.0.1.0/24 | Load Balancer |
| Public Subnet B  | 10.0.2.0/24 | Load Balancer |
| Private Subnet A | 10.0.3.0/24 | EC2           |
| Private Subnet B | 10.0.4.0/24 | EC2           |

---

# Step 2: Attach Internet Gateway

Attach an Internet Gateway to the VPC.

Public route table:

```
Destination: 0.0.0.0/0
Target: Internet Gateway
```

Associate this route table with **public subnets**.

Important notes:

* Internet Gateway attaches to the **VPC**
* Subnets access it through **route tables**

---

# Step 3: Launch EC2 Instances

Launch at least **2 EC2 instances**.

Recommended configuration:

| Setting               | Value             |
| --------------------- | ----------------- |
| Instance Type         | t2.micro          |
| Subnet                | Private or Public |
| Auto Assign Public IP | Optional          |

Install a web server:

```
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
```

Create a webpage:

```
echo "Server: $(hostname) - IP: $(hostname -I)" | sudo tee /var/www/html/index.html
```

---

# Step 4: Create Target Group

Navigate to:

EC2 → Target Groups → Create Target Group

Configuration:

| Field             | Value     |
| ----------------- | --------- |
| Target Type       | Instances |
| Protocol          | HTTP      |
| Port              | 80        |
| Health Check Path | /         |

Register EC2 instances as targets.

Example:

```
EC2-1
EC2-2
```

---

# Step 5: Create Application Load Balancer

Navigate to:

EC2 → Load Balancers → Create Load Balancer

Choose:

```
Application Load Balancer
```

Configuration:

| Setting | Value            |
| ------- | ---------------- |
| Scheme  | Internet Facing  |
| IP Type | IPv4             |
| VPC     | Your VPC         |
| Subnets | 2 Public Subnets |

Listener:

```
HTTP : 80
Forward to → Target Group
```

After creation AWS will generate a DNS name:

```
http://alb-name.region.elb.amazonaws.com
```

---

# Step 6: Security Group Configuration

Load Balancer Security Group:

| Type | Port | Source    |
| ---- | ---- | --------- |
| HTTP | 80   | 0.0.0.0/0 |

EC2 Security Group:

| Type | Port | Source           |
| ---- | ---- | ---------------- |
| HTTP | 80   | Load Balancer SG |

This ensures only the load balancer can reach EC2.

---

# EC2 Public IP Requirement

EC2 instances **do not need a public IP** when behind a load balancer.

Load balancer communicates using **private IP addresses** inside the VPC.

Example flow:

```
Internet → Load Balancer → 10.0.1.23
Internet → Load Balancer → 10.0.2.15
```

---

# Editing index.html via SSH

Connect to EC2 using SSH.

Overwrite page:

```
echo "Hello from Server 1" | sudo tee /var/www/html/index.html
```

Edit manually:

```
sudo nano /var/www/html/index.html
```

Restart Apache if required:

```
sudo systemctl restart httpd
```

---

# Useful Test Script for Load Balancer

```
echo "Server: $(hostname) | IP: $(hostname -I)" | sudo tee /var/www/html/index.html
```

Refreshing the load balancer will show different instance responses.

---

# Troubleshooting Guide

## 503 Service Temporarily Unavailable

Cause:

```
No healthy targets available
```

Fix steps:

1. Check Target Health

EC2 → Target Groups → Targets

Status should be:

```
healthy
```

---

## 0 Healthy Targets

Common reasons:

### Web server not running

Check:

```
sudo systemctl status httpd
```

Start if needed:

```
sudo systemctl start httpd
```

---

### Security Group Blocking Traffic

Ensure EC2 allows:

```
HTTP 80 → LoadBalancer SG
```

---

### Wrong Health Check Path

Target Group health check should be:

```
Path: /
```

---

### Port Mismatch

If Apache runs on:

```
Port 80
```

Target group must also use:

```
Port 80
```

---

### Instances Not Registered

Verify instances are registered in the target group.

---

# Debug Commands on EC2

Check web server:

```
sudo systemctl status httpd
```

Test locally:

```
curl localhost
```

Check webpage:

```
cat /var/www/html/index.html
```

---

# Important Concepts

Load Balancer never connects directly to EC2.

Traffic always flows through a **Target Group**.

Structure:

```
Load Balancer
     ↓
Target Group
     ↓
Targets (EC2 / IP / Lambda)
```

---

# Best Practices

* Use **2 Availability Zones**
* Place EC2 in **private subnets**
* Use **public subnets only for Load Balancer**
* Restrict EC2 access via security groups
* Use health checks

---

# Common Beginner Mistakes

* Only one subnet selected
* Instances not registered in target group
* Apache not installed
* Security group blocking port 80
* Health check path incorrect

---

# Summary

Setup order:

```
1. Create VPC
2. Create Subnets
3. Attach Internet Gateway
4. Launch EC2 Instances
5. Install Web Server
6. Create Target Group
7. Register EC2 Instances
8. Create Application Load Balancer
9. Test DNS endpoint
```

When configured correctly:

```
Internet → Load Balancer → Target Group → EC2 Instances
```

---

End of Guide
