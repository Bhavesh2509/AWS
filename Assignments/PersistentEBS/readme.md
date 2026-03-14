# AWS EC2 + EBS Persistent Website Lab (Nginx + AMI)

## Overview

This lab demonstrates how to use **persistent storage with an EC2 instance** by attaching an EBS volume, hosting website files on that volume, serving them using Nginx, and finally creating an AMI to replicate the setup.

The lab covers:

* Creating and attaching an EBS volume
* Mounting the volume inside the EC2 instance
* Hosting a website from the EBS volume
* Configuring Nginx to serve the website
* Making the mount persistent with `fstab`
* Creating an AMI from the configured instance
* Launching a new instance with the same website
* Troubleshooting common errors

---

# Architecture

```
EC2 Instance
│
├── Root Volume
│     └── Nginx
│
└── EBS Volume
      └── /data1/index.html
```

The web server runs from the root disk, while the website files are stored on a separate persistent EBS volume.

---

# Step 1: Launch EC2 Instance

Launch an EC2 instance with:

* Amazon Linux
* Security group allowing HTTP (port 80)
* SSH access

Connect via SSH:

```bash
ssh ec2-user@<public-ip>
```

---

# Step 2: Create an EBS Volume

1. Go to **EC2 → Volumes**
2. Click **Create Volume**

Example configuration:

| Setting           | Value       |
| ----------------- | ----------- |
| Volume Type       | gp3         |
| Size              | 5 GB        |
| Availability Zone | Same as EC2 |

Create the volume.

---

# Step 3: Attach Volume to EC2

1. Select the volume
2. Click **Actions → Attach Volume**
3. Select your EC2 instance

Device example:

```
/dev/xvdf
```

Inside modern EC2 instances this appears as:

```
/dev/nvme1n1
```

---

# Step 4: Verify Disk in Instance

Check attached disks:

```bash
lsblk
```

Example:

```
nvme0n1   8G  root disk
nvme1n1   5G  new EBS volume
```

---

# Step 5: Format the Volume

New disks must be formatted.

```bash
sudo mkfs.ext4 /dev/nvme1n1
```

---

# Step 6: Create Mount Directory

```bash
sudo mkdir /data1
```

---

# Step 7: Mount the Volume

```bash
sudo mount /dev/nvme1n1 /data1
```

Verify:

```bash
df -h
```

---

# Step 8: Install Nginx

```bash
sudo yum install nginx -y
```

Start service:

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

# Step 9: Create Website on EBS Volume

```bash
sudo nano /data1/index.html
```

Example HTML:

```html
<html>
<head>
<title>EBS Website</title>
</head>
<body>
<h1>Website from EBS Volume</h1>
<p>This website is stored on persistent EBS storage.</p>
</body>
</html>
```

---

# Step 10: Link Website to Nginx

Remove default files:

```bash
sudo rm -rf /usr/share/nginx/html/*
```

Create symbolic link:

```bash
sudo ln -s /data1/index.html /usr/share/nginx/html/index.html
```

Restart nginx:

```bash
sudo systemctl restart nginx
```

Access website:

```
http://EC2-PUBLIC-IP
```

---

# Step 11: Make the EBS Mount Persistent

Without persistence, mounts disappear after reboot.

Find UUID:

```bash
sudo blkid
```

Example output:

```
/dev/nvme1n1: UUID="1e3eb546-8da7-4f0a-98a3-3a03324a11be" TYPE="ext4"
```

Edit fstab:

```bash
sudo nano /etc/fstab
```

Add entry:

```
UUID=1e3eb546-8da7-4f0a-98a3-3a03324a11be /data1 ext4 defaults,nofail 0 2
```

---

# Step 12: Test fstab Configuration

Run:

```bash
sudo mount -a
```

If no errors appear, the configuration is correct.

Verify mount:

```bash
df -h
```

---

# Step 13: Reboot Test

```bash
sudo reboot
```

After reboot verify:

```bash
df -h
```

The EBS volume should automatically mount to `/data1`.

---

# Step 14: Create an AMI

Go to:

```
EC2 → Instances
```

Select instance → **Actions → Image and templates → Create Image**

AWS creates snapshots of:

* Root EBS volume
* Attached data EBS volume

---

# Step 15: Launch Instance from AMI

Navigate to:

```
EC2 → AMIs
```

Launch a new instance from the created AMI.

After boot:

```
http://NEW-INSTANCE-IP
```

The same website should appear.

---

# Troubleshooting Guide

## 1. Mount Error

```
wrong fs type, bad superblock
```

Cause:

Disk not formatted.

Solution:

```bash
sudo mkfs.ext4 /dev/nvme1n1
```

---

## 2. 403 Forbidden from Nginx

Possible causes:

### Permission issue

Fix permissions:

```bash
sudo chmod -R 755 /data1
```

---

### Missing file

Verify:

```bash
ls /data1
```

---

### Volume not mounted

Check:

```bash
df -h
```

Mount again:

```bash
sudo mount /dev/nvme1n1 /data1
```

---

## 3. Nginx Fails to Start

Check status:

```bash
sudo systemctl status nginx
```

Check logs:

```bash
sudo journalctl -xeu nginx.service
```

---

## 4. Port 80 Conflict (Docker)

Check:

```bash
sudo lsof -i :80
```

Stop container:

```bash
docker stop <container-id>
```

---

## 5. fstab Mount Error

Error example:

```
BLOCK_SIZE="4096": mount point does not exist
```

Cause:

Incorrect `fstab` entry.

Correct format:

```
UUID=<uuid> /data1 ext4 defaults,nofail 0 2
```

---

# Key Concepts Demonstrated

## Persistent Storage

EBS volumes retain data independently from EC2 instances.

## Separation of Compute and Storage

```
Compute → EC2
Storage → EBS
```

This allows:

* data persistence
* disk reuse
* instance recovery

## AMI Cloning

AMI captures the entire server configuration, allowing identical servers to be launched quickly.

---

# Final Result

You successfully created:

* EC2 server running Nginx
* Website stored on EBS
* Persistent disk mount
* AMI image of the server
* New instance with identical website

---

# Best Practices

* Always mount EBS volumes using **UUID instead of device names**
* Configure persistent mounts using **/etc/fstab**
* Test mount configuration with `mount -a`
* Store application data on separate EBS volumes
* Keep OS and application data on different disks

---

# Commands Summary

Check disks:

```bash
lsblk
```

Format disk:

```bash
mkfs.ext4 /dev/nvme1n1
```

Mount disk:

```bash
mount /dev/nvme1n1 /data1
```

Check mounts:

```bash
df -h
```

Get disk UUID:

```bash
blkid
```

Test fstab:

```bash
mount -a
```

Restart nginx:

```bash
systemctl restart nginx
```

---

# Lab Outcome

By completing this lab you have demonstrated:

* Persistent storage with EBS
* Web hosting using Nginx
* Disk mounting and Linux filesystem management
* Infrastructure cloning using AMI
* Basic AWS troubleshooting skills

---
