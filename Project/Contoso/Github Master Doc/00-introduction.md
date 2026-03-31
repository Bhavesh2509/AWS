# Lab Guide — Page 1 of 5 — Introduction

## Welcome

In this lab you will explore AWS Identity and Access Management (IAM) — the service that controls **who can do what** in your AWS account. You will create roles and policies from scratch, attach permissions to resources, launch an EC2 instance using those permissions, and finally assume a role using STS to see how temporary credentials work.

## Lab Environment

Your environment includes:

- A dedicated AWS account provisioned exclusively for you
- A Windows jump VM with AWS CLI v2 and Chrome pre-installed
- An IAM user (`ODL_user_XXXXXX`) already logged into the AWS Console

## How to access the AWS Console

1. Open the **AWS Console** shortcut on the desktop
2. Your sign-in URL, username, and password are on your **CloudLabs environment page**
3. Sign in and confirm you land on the AWS Console home page

## How to use the AWS CLI

Open **PowerShell** on the desktop and configure your credentials:

```powershell
aws configure
```

Enter the following when prompted:

| Prompt | Value |
|---|---|
| AWS Access Key ID | From your CloudLabs environment page |
| AWS Secret Access Key | From your CloudLabs environment page |
| Default region | `us-east-1` |
| Default output format | `json` |

Verify it works:

```powershell
aws sts get-caller-identity
```

You should see your Account ID and your `ODL_user_XXXXXX` username in the output.

## Important restrictions

| Restriction | Detail |
|---|---|
| EC2 instance types | Only `t2.micro` and `t3.micro` are allowed |
| IAM users | Creating IAM users is not permitted |
| IAM groups | Creating IAM groups is not permitted |
| Attaching policies to users | Not permitted — roles only |
| Billing and Organizations | Blocked |

> **Note:** All IAM roles you create during this lab **must** have the `LabPermissionBoundary` policy attached as a permissions boundary. The exercises will guide you through this step.

## Lab tasks overview

| Task | What you will do |
|---|---|
| Task 1 | Create an IAM policy with custom permissions |
| Task 2 | Create an IAM role and attach the policy |
| Task 3 | Launch an EC2 instance with the role attached |
| Task 4 | Assume the role using STS and verify access |

**Estimated time:** 2.5 – 3 hours

---

**Page 1 of 5** 
