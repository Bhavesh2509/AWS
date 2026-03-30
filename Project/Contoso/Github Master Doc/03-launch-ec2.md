# Lab Guide — Page 4 of 6 — Launch an EC2 Instance with the IAM Role

## Overview

Now that the role exists, you will launch an EC2 instance and attach the role to it via an instance profile. The instance will inherit the role's permissions — meaning it can read S3 and describe EC2 without any hardcoded credentials.

**Estimated time:** 25 minutes

> **Reminder:** Only `t2.micro` and `t3.micro` instance types are permitted in this lab. Any other type will be denied.

---

## Step 1 — Open the EC2 Console

1. In the AWS Console, search for **EC2** and open it
2. Click **Launch instance**

---

## Step 2 — Configure the instance

Fill in the following:

| Setting | Value |
|---|---|
| Name | `LabTestInstance` |
| AMI | Amazon Linux 2023 (default, free tier eligible) |
| Instance type | `t2.micro` |
| Key pair | Proceed without a key pair (not needed for this exercise) |

---

## Step 3 — Attach the IAM role

1. Expand **Advanced details**
2. Under **IAM instance profile**, select `LabEC2InstanceRole`

---

## Step 4 — Launch the instance

1. Leave all other settings as default
2. Click **Launch instance**
3. Click on the instance ID to open its details page
4. Wait until **Instance state** shows `Running` and **Status check** shows `2/2 checks passed`

---

## Step 5 — Verify the role is attached

1. On the instance details page, click the **Security** tab
2. Under **IAM Role**, confirm `LabEC2InstanceRole` is shown
3. Click on the role name to open it in IAM and confirm the policy is attached

---

## Step 6 — Verify via CLI

```powershell
aws ec2 describe-instances --filters "Name=tag:Name,Values=LabTestInstance" `
  --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name,Role:IamInstanceProfile.Arn}"
```

You should see the instance ID, state as `running`, and the instance profile ARN containing `LabEC2InstanceRole`.

---

## Step 7 — Test the role permissions from CLI

First get the role ARN:

```powershell
$roleArn = (aws iam get-role --role-name LabEC2InstanceRole | ConvertFrom-Json).Role.Arn
Write-Host $roleArn
```

Then simulate actions:

```powershell
aws iam simulate-principal-policy `
  --policy-source-arn $roleArn `
  --action-names "s3:ListAllMyBuckets" "s3:GetObject" "ec2:DescribeInstances" "ec2:RunInstances"
```

Check the output:

| Action | Expected result |
|---|---|
| `s3:ListAllMyBuckets` | `allowed` |
| `s3:GetObject` | `allowed` |
| `ec2:DescribeInstances` | `allowed` |
| `ec2:RunInstances` | `implicitDeny` |

---

## Summary

You launched a `t2.micro` EC2 instance with the IAM role attached via an instance profile. The instance can now make AWS API calls using the role's permissions without any hardcoded credentials. In the next task you will assume this role directly using STS.

---

**Page 4 of 6** | [← Previous: Task 2 — Create IAM Role](02-create-iam-role.md) | [Next: Task 4 — Assume Role via STS →](04-assume-role-sts.md)
