# Exploring a Live AWS Web Application — EC2, PHP & MySQL

## Overview

In this lab you will interact with a fully deployed AWS web application. The entire infrastructure — networking, compute, database, and application — was automatically provisioned by a CloudFormation template before the lab started. You do not need to create or configure anything.

You will:
- Use the browser-based PHP app to insert and manage data
- Connect to the EC2 instance over SSH and explore the Linux environment
- Connect directly to the RDS MySQL database and run SQL queries
- Inspect running services, logs, and system resources

---

## Architecture

```
Your Browser
     │  HTTP (port 80)
     ▼
┌─────────────────────────────┐
│  EC2 Instance (t3.small)    │
│  Amazon Linux 2             │
│  Apache 2.4  +  PHP 8.2     │
│  /var/www/html/index.php    │
└────────────┬────────────────┘
             │  MySQL (port 3306) — internal only
             ▼
┌─────────────────────────────┐
│  RDS MySQL 8.0 (db.t3.micro)│
│  database: webappdb         │
│  table:    users            │
└─────────────────────────────┘
```

Your SSH session (port 22) and RDP session (port 3389) both connect directly to the EC2 instance. RDS is **not** reachable from the internet — only from EC2.

---

## Credentials

All values below are available in your **CloudLabs panel** on the right side of your screen.

| What You Need      | Where to Find It         |
|--------------------|--------------------------|
| Web app URL        | `WebAppURL`              |
| EC2 public IP      | `EC2ElasticIP`           |
| SSH command        | `SSHCommand`             |
| Linux username     | `LinuxUsername`          |
| Linux password     | `LinuxPassword`          |
| RDS hostname       | `RDSEndpoint`            |
| DB password        | `DBPassword`             |
| DB username        | `dbadmin` (fixed)        |
| Database name      | `webappdb` (fixed)       |

---

## Lab Structure

| Lab | Title | Time |
|-----|-------|------|
| Lab 1 | Web App, SSH & File Exploration | ~25 min |
| Lab 2 | MySQL Queries & Services        | ~25 min |
| Lab 3 | Challenge                       | ~10 min |

**Total estimated time:** 60–90 minutes

---

## Prerequisites

- Basic Linux command line familiarity (`ls`, `cat`, `cd`, `systemctl`)
- Basic understanding of what a web server and a database are
- No AWS Console access is needed for this lab

---

> **Note:** Do not stop or reboot the EC2 instance or delete the RDS instance during the lab. All changes you make to the database are persistent for the duration of your lab session.
