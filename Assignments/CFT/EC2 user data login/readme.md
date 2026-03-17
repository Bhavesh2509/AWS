# 🚀 CloudFormation: EC2 + VPC with Password Login (No Key Pair)

## 📌 Overview

This project provisions:

* A custom **VPC**
* Public **Subnet**
* **Internet Gateway + Route Table**
* **Security Group**
* **EC2 Instance**

It also uses **UserData** to:

* Enable **SSH password authentication**
* Set a **custom password**
* Allow login **without a key pair**

---

## 🏗️ Architecture

```
VPC
 ├── Public Subnet
 │     ├── Route Table → IGW
 │     └── EC2 Instance
 │           └── Security Group (SSH + HTTP)
```

---

## ⚙️ Prerequisites

* AWS CLI configured
* IAM permissions for:

  * CloudFormation
  * EC2
  * VPC
* Valid AMI ID (Amazon Linux / Ubuntu)

---

## 📄 Deployment Steps

### 🔹 1. Validate Template

```bash
aws cloudformation validate-template \
  --template-body file://template.yaml
```

---

### 🔹 2. Create Stack

```bash
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters \
    ParameterKey=Password,ParameterValue=YourPassword123 \
    ParameterKey=AmiId,ParameterValue=ami-xxxx \
    ParameterKey=KeyName,ParameterValue=""
```

👉 Note:

* `KeyName` can be empty if not using key pair
* Password will be used for SSH login

---

### 🔹 3. Wait for Completion

```bash
aws cloudformation wait stack-create-complete \
  --stack-name my-stack
```

---

### 🔹 4. Get Outputs

```bash
aws cloudformation describe-stacks \
  --stack-name my-stack \
  --query "Stacks[0].Outputs"
```

---

### 🔹 5. Connect to EC2 (Password Login)

```bash
ssh ec2-user@<PublicIP>
```

Enter password when prompted.

---

## ⏱️ Important Timing

| Stage              | Status                 |
| ------------------ | ---------------------- |
| Instance launched  | ❌ Login NOT possible   |
| Cloud-init running | ❌ Still not ready      |
| After ~30–60 sec   | ✅ Password login works |

---

## 🔐 UserData Logic (What Happens)

1. Instance boots
2. Cloud-init executes script
3. Password is set
4. SSH config updated:

   * `PasswordAuthentication yes`
5. SSH service restarted
6. Password login enabled

---

## ⚠️ Security Considerations

* Password SSH is **less secure** than key-based auth
* Avoid:

  * Weak passwords
  * Open SSH (`0.0.0.0/0`) in production

### Recommended:

* Restrict SSH to your IP
* Use strong password
* Prefer SSM or key-based access

---

## 🧪 Troubleshooting

### ❌ 1. Permission denied (publickey)

**Cause:** Password auth not enabled yet
**Fix:** Wait 30–60 seconds and retry

---

### ❌ 2. Permission denied (password)

**Causes:**

* Wrong username
* Password not set
* SSH config not updated

**Fix:**

* Use correct user:

  * Amazon Linux → `ec2-user`
  * Ubuntu → `ubuntu`

---

### ❌ 3. Connection timed out

**Cause:** Security Group issue
**Fix:**

* Allow inbound:

```text
Port: 22
Source: 0.0.0.0/0 (or your IP)
```

---

### ❌ 4. No Public IP

**Fix:**

* Ensure:

```yaml
MapPublicIpOnLaunch: true
```

---

### ❌ 5. UserData failed

Check logs:

```bash
/var/log/cloud-init-output.log
```

---

### ❌ 6. Completely locked out

**Cause:** No key + failed script
**Fix options:**

* Use EC2 Instance Connect (if enabled)
* Use SSM (if role attached)
* Otherwise → terminate and recreate

---

## 🧠 Learning Concepts

### 🔹 1. CloudFormation Parameters

* Allow dynamic input at runtime
* Avoid hardcoding values
* Can be overridden during stack creation

---

### 🔹 2. UserData (cloud-init)

* Runs only at **first boot**
* Used for:

  * Installing packages
  * Configuring services
  * Setting passwords

---

### 🔹 3. EC2 Authentication Flow

Default:

```
SSH → Key-based auth only
```

Modified:

```
UserData → Enable password → Restart SSH → Password login works
```

---

### 🔹 4. Boot Sequence Understanding

```
EC2 Start
   ↓
SSH Starts (key-only)
   ↓
UserData Runs
   ↓
Password Enabled
   ↓
SSH Restart
```

---

### 🔹 5. Risks of No Key Pair

* No fallback access
* Full dependency on UserData
* High chance of lockout

---

## 🚀 Improvements You Can Add

* Private subnet + NAT Gateway
* Application Load Balancer
* Auto Scaling Group
* IAM Role for SSM access
* Remove SSH and use SSM only

---

## ✅ Best Practices

✔ Always keep a fallback (Key or SSM)
✔ Use parameters for flexibility
✔ Validate templates before deployment
✔ Check logs for debugging
✔ Avoid password auth in production

---

## 🎯 Summary

| Feature               | Status                 |
| --------------------- | ---------------------- |
| EC2 without key       | ✅ Possible             |
| Password login        | ✅ Enabled via UserData |
| First login immediate | ❌ Not possible         |
| Safe for production   | ⚠️ Not recommended     |

---

## 💡 Final Thought

This setup is great for:

* Learning CloudFormation
* Understanding EC2 boot process
* Practicing automation

But for real-world usage:
👉 Prefer **key-based auth or SSM**

---
