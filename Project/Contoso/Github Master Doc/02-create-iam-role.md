# Lab Guide — Page 3 of 6 — Create an IAM Role and Attach the Policy

## Overview

An IAM **role** is an identity that can be assumed by AWS services, users, or applications. Unlike a user, a role has no permanent credentials — it issues temporary credentials when assumed. In this task you will create a role for EC2 to use, attach the policy from Task 1, and attach the required lab permission boundary.

**Estimated time:** 25 minutes

---

## What is a trust policy?

Every IAM role has a **trust policy** — a separate JSON document that defines *who* is allowed to assume the role. For an EC2 role, the trusted entity is the EC2 service itself:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

This tells AWS: "only EC2 instances may assume this role."

---

## Step 1 — Open the Roles section

1. In the IAM Console, click **Roles** in the left navigation pane
2. Click **Create role**

---

## Step 2 — Select trusted entity

1. Under **Trusted entity type**, select **AWS service**
2. Under **Use case**, select **EC2**
3. Click **Next**

---

## Step 3 — Attach the permission policy

1. In the search box, type `LabEC2S3ReadPolicy`
2. Check the box next to it
3. Click **Next**

---

## Step 4 — Name the role

1. Under **Role name**, enter:

```
LabEC2InstanceRole
```

2. Under **Description**, enter:

```
Lab role for EC2 — grants S3 read and EC2 describe access
```

---

## Step 5 — Attach the Permission Boundary

> This step is **mandatory** in this lab environment. Roles created without the boundary will be rejected.

1. Scroll down to **Permissions boundary**
2. Click **Set a permissions boundary**
3. Search for `LabPermissionBoundary`
4. Select it

---

## Step 6 — Create the role

1. Review the summary — confirm:
   - Trusted entity: `ec2.amazonaws.com`
   - Attached policy: `LabEC2S3ReadPolicy`
   - Permissions boundary: `LabPermissionBoundary`
2. Click **Create role**

---

## Step 7 — Verify using the CLI

```powershell
aws iam get-role --role-name LabEC2InstanceRole
```

Check the output for:

- `"RoleName": "LabEC2InstanceRole"`
- `"PermissionsBoundary"` section showing `LabPermissionBoundary`

Also verify the policy is attached:

```powershell
aws iam list-attached-role-policies --role-name LabEC2InstanceRole
```

---

## Step 8 — Create an Instance Profile

EC2 cannot directly use an IAM role — it needs an **instance profile** wrapper. The console creates this automatically, but verify it exists:

```powershell
aws iam list-instance-profiles-for-role --role-name LabEC2InstanceRole
```

You should see an instance profile named `LabEC2InstanceRole` in the output.

---

## Summary

You created an IAM role with a trust policy allowing EC2 to assume it, attached your custom policy, and set the permission boundary. In the next task you will launch an EC2 instance and attach this role to it.

---

**Page 3 of 6** | [← Previous: Task 1 — Create IAM Policy](01-create-iam-policy.md) | [Next: Task 3 — Launch EC2 Instance →](03-launch-ec2.md)
