# 📘 EC2 + S3 (Least Privilege) – CloudFormation Setup Guide

---

## 🧾 Overview

This project provisions:

* EC2 Instance
* S3 Bucket
* IAM Role with **least privilege**
* Custom VPC (no default dependency)

The EC2 instance can **ONLY list objects** in the S3 bucket.

---

## 🚀 Deployment Steps

### 1. Prerequisites

* AWS Account
* EC2 Key Pair (already created in your region)
* AWS CLI (optional)

---

### 2. Deploy CloudFormation Stack

1. Go to **CloudFormation Console**
2. Click **Create Stack**
3. Upload the template file
4. Enter parameters:

   * `KeyName` → select your EC2 key pair
5. Click **Create Stack**

---

### 3. Wait for Completion

* Status should be: `CREATE_COMPLETE`
* If failed → check **Events tab**

---

## 🔍 Get Required Details

### EC2 Public IP

Go to:

* CloudFormation → Stack → **Outputs**

Example:

```
PublicIP = 3.x.x.x
```

---

### S3 Bucket Name

From Outputs:

```
BucketName = mybucket-xxxx
```

---

## 🔐 Connect to EC2

```bash
ssh -i your-key.pem ec2-user@<PublicIP>
```

---

## 🧪 Test S3 Access

### ✅ List objects (allowed)

```bash
aws s3 ls s3://<your-bucket-name>
```

---

### ❌ Upload (expected to fail)

```bash
aws s3 cp file.txt s3://<your-bucket-name>/
```

Reason: `PutObject` not allowed

---

## 📦 Upload Object to S3

### Option 1 – AWS Console

1. Go to S3
2. Open your bucket
3. Click **Upload**
4. Add file → Upload

---

### Option 2 – CLI (local machine)

```bash
aws s3 cp test.txt s3://<your-bucket-name>/
```

---

## 🧠 IAM Permissions Explained

### Allowed:

* `s3:ListBucket`

### Not Allowed:

* `s3:GetObject`
* `s3:PutObject`
* `s3:ListAllMyBuckets`

---

## ⚠️ Important Concepts

| Action     | Resource   |
| ---------- | ---------- |
| ListBucket | bucket ARN |
| GetObject  | bucket/*   |

---

## 🐞 Troubleshooting

---

### ❌ Error: AccessDenied (ListObjectsV2)

```
not authorized to perform s3:ListBucket
```

#### Cause:

* Trying to access wrong bucket

#### Fix:

```bash
aws s3 ls s3://<your-bucket-name>
```

---

### ❌ Error: Cannot see bucket in UI

#### Causes:

* Wrong region selected
* Bucket name unknown

#### Fix:

* Switch to correct region (top-right in AWS Console)
* Check CloudFormation → Outputs

---

### ❌ Error: aws s3 ls fails

#### Cause:

* This lists ALL buckets

#### Fix:

Use:

```bash
aws s3 ls s3://<your-bucket-name>
```

---

### ❌ Error: EC2 cannot access S3

#### Check IAM role:

```bash
aws sts get-caller-identity
```

If fails → role not attached

---

### ❌ Error: SSH not working

#### Fix:

```bash
chmod 400 your-key.pem
```

Check:

* Security group allows port 22
* Correct public IP

---

### ❌ Error: AMI not found

#### Fix:

* Replace AMI ID with region-specific Amazon Linux 2

---

### ❌ Error: Stack failed (subnet issue)

```
No subnets found for default VPC
```

#### Fix:

* Use custom VPC (already handled in final template)

---

## 🔧 Optional Enhancements

---

### Allow Read Access

Add to IAM policy:

```yaml
- Effect: Allow
  Action:
    - s3:GetObject
  Resource: arn:aws:s3:::your-bucket-name/*
```

---

### Allow Upload

```yaml
- Effect: Allow
  Action:
    - s3:PutObject
  Resource: arn:aws:s3:::your-bucket-name/*
```

---

### Restrict Bucket to EC2 Role Only

Add bucket policy for tighter security.

---

## 🏁 Final Workflow

1. Deploy stack
2. Get bucket name from Outputs
3. Upload file via console/CLI
4. SSH into EC2
5. Run:

```bash
aws s3 ls s3://<your-bucket-name>
```

---

## 📌 Key Takeaways

* Always use **least privilege IAM**
* Avoid using `aws s3 ls` without bucket
* Region mismatch is a common issue
* CloudFormation Outputs = source of truth

---

## 🚀 Next Learning Steps

* Private EC2 (no public IP)
* VPC Endpoints for S3
* Bucket policies
* Auto-scaling architectures

---

**Done ✅**
