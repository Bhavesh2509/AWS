# Lab Guide — Page 2 of 5 — Create an IAM Policy

## Overview

An IAM **policy** is a JSON document that defines permissions — what actions are allowed or denied on which resources. In this task you will create a custom managed policy that grants read access to S3 and the ability to describe EC2 instances.

**Estimated time:** 20 minutes

---

## What is a managed policy?

There are two types of IAM policies:

- **Managed policies** — standalone policies you create and attach to multiple roles or users. Reusable.
- **Inline policies** — embedded directly inside a single role or user. Not reusable.

For this lab you will use a **managed policy** so it can be reused across multiple roles.

---

## Step 1 — Open the IAM Console

1. In the AWS Console, search for **IAM** in the top search bar and open it
2. In the left navigation pane, click **Policies**
3. Click **Create policy**

---

## Step 2 — Define the policy using the JSON editor

1. Click the **JSON** tab
2. Replace the default content with the following policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3ReadAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListAllMyBuckets"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowEC2Describe",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeImages",
        "ec2:DescribeRegions"
      ],
      "Resource": "*"
    }
  ]
}
```

3. Click **Next**

---

## Step 3 — Name and create the policy

1. Under **Policy name**, enter:

```
LabEC2S3ReadPolicy
```

2. Under **Description**, enter:

```
Custom lab policy — grants S3 read and EC2 describe access
```

3. Click **Create policy**

---

## Step 4 — Verify the policy was created

1. In the Policies list, search for `LabEC2S3ReadPolicy`
2. Click on it and confirm the JSON matches what you entered
3. Note the **Policy ARN** — you will need it in Task 2

> The ARN will look like:
> `arn:aws:iam::123456789012:policy/LabEC2S3ReadPolicy`

---

## Verify using the CLI

Run the following in PowerShell to confirm the policy exists:

```powershell
aws iam list-policies --scope Local --query "Policies[?PolicyName=='LabEC2S3ReadPolicy']"
```

You should see the policy listed with its ARN and creation date.

---

## Summary

You created a custom IAM managed policy with two permission statements — one for S3 read access and one for EC2 describe actions. In the next task you will create a role and attach this policy to it.

---

**Page 2 of 5** |
