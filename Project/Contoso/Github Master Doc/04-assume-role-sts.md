# Lab Guide — Page 5 of 5 — Assume the Role Using STS

## Overview

In the previous tasks you attached a role to an EC2 instance. Now you will assume the same role **directly from your CLI session** using AWS STS (Security Token Service). This is how applications, CI/CD pipelines, and cross-account access work in real environments — temporary credentials issued for a limited time.

**Estimated time:** 30 minutes

---

## What is STS AssumeRole?

When you call `sts:AssumeRole`, AWS returns three temporary credentials:

| Credential | What it is |
|---|---|
| `AccessKeyId` | Temporary access key (starts with `ASIA`) |
| `SecretAccessKey` | Temporary secret |
| `SessionToken` | Required alongside the key and secret |

These credentials expire after 1 hour by default and can be renewed by calling AssumeRole again.

---

## Step 1 — Update the role trust policy

Your current role only trusts `ec2.amazonaws.com`. To assume it from your CLI you need to add your IAM user as a trusted principal.

1. In the IAM Console, go to **Roles** → `LabEC2InstanceRole`
2. Click the **Trust relationships** tab
3. Click **Edit trust policy**
4. Replace the existing policy with:

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
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT_ID:user/ODL_USER"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

5. Replace `ACCOUNT_ID` and `ODL_USER` with your actual values — get them by running:

```powershell
aws sts get-caller-identity
```

6. Click **Update policy**

---

## Step 2 — Assume the role

Run the following in PowerShell:

```powershell
$creds = aws sts assume-role `
  --role-arn "arn:aws:iam::ACCOUNT_ID:role/LabEC2InstanceRole" `
  --role-session-name "LabSession01" | ConvertFrom-Json

$creds.Credentials
```

You should see output like:

```
AccessKeyId     : ASIAxxxxxxxxxxxxxxxxx
SecretAccessKey : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
SessionToken    : IQoJb3...
Expiration      : 2025-01-01T12:00:00+00:00
```

---

## Step 3 — Use the temporary credentials

Set the temporary credentials as environment variables:

```powershell
$env:AWS_ACCESS_KEY_ID     = $creds.Credentials.AccessKeyId
$env:AWS_SECRET_ACCESS_KEY = $creds.Credentials.SecretAccessKey
$env:AWS_SESSION_TOKEN     = $creds.Credentials.SessionToken
```

Verify you are now acting as the role:

```powershell
aws sts get-caller-identity
```

The output should show `assumed-role/LabEC2InstanceRole/LabSession01` in the ARN — confirming you are operating with the role's permissions.

---

## Step 4 — Test what the role can and cannot do

Test allowed actions:

```powershell
# Should succeed
aws s3 ls
aws ec2 describe-instances --query "Reservations[].Instances[].InstanceId"
```

Test a blocked action:

```powershell
# Should fail with AccessDenied
aws ec2 run-instances --image-id ami-00000000 --instance-type t2.micro --count 1
```

The `run-instances` call should return an `AccessDenied` error because `ec2:RunInstances` is not in the `LabEC2S3ReadPolicy`.

---

## Step 5 — Clear the temporary credentials

Restore your original credentials:

```powershell
Remove-Item Env:AWS_ACCESS_KEY_ID
Remove-Item Env:AWS_SECRET_ACCESS_KEY
Remove-Item Env:AWS_SESSION_TOKEN
```

Verify you are back to your original user:

```powershell
aws sts get-caller-identity
```

---

## Summary

You updated the role trust policy to allow your IAM user to assume the role, called `sts:AssumeRole` to receive temporary credentials, set them as environment variables, and verified that the role's permissions were correctly scoped. This is the foundation of how IAM roles work in production — no permanent credentials, just temporary access.

---

**Page 5 of 5** 
