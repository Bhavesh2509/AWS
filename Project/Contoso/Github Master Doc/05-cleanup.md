# Lab Guide — Page 6 of 6 — Clean Up Resources

## Overview

In this final task you will delete all resources created during the lab. This is good practice and ensures no unexpected AWS costs remain after the session ends.

**Estimated time:** 15 minutes

---

## Step 1 — Terminate the EC2 instance

1. In the EC2 Console, go to **Instances**
2. Select `LabTestInstance`
3. Click **Instance state** → **Terminate instance**
4. Confirm termination

Via CLI:

```powershell
$instanceId = (aws ec2 describe-instances `
  --filters "Name=tag:Name,Values=LabTestInstance" `
  --query "Reservations[].Instances[].InstanceId" `
  --output text)

aws ec2 terminate-instances --instance-ids $instanceId
```

---

## Step 2 — Detach the policy from the role

```powershell
$policyArn = (aws iam list-policies --scope Local `
  --query "Policies[?PolicyName=='LabEC2S3ReadPolicy'].Arn" `
  --output text)

aws iam detach-role-policy `
  --role-name LabEC2InstanceRole `
  --policy-arn $policyArn
```

---

## Step 3 — Delete the instance profile

```powershell
aws iam remove-role-from-instance-profile `
  --instance-profile-name LabEC2InstanceRole `
  --role-name LabEC2InstanceRole

aws iam delete-instance-profile `
  --instance-profile-name LabEC2InstanceRole
```

---

## Step 4 — Delete the role

```powershell
aws iam delete-role --role-name LabEC2InstanceRole
```

---

## Step 5 — Delete the policy

```powershell
aws iam delete-policy --policy-arn $policyArn
```

---

## Step 6 — Verify everything is cleaned up

```powershell
# Both should return []
aws iam list-roles --query "Roles[?RoleName=='LabEC2InstanceRole']"
aws iam list-policies --scope Local --query "Policies[?PolicyName=='LabEC2S3ReadPolicy']"
```

---

## Lab Complete

You have successfully completed all tasks in the AWS IAM Basics Lab:

| Task | Completed |
|---|---|
| Task 1 — Create an IAM policy | ✅ |
| Task 2 — Create an IAM role and attach the policy | ✅ |
| Task 3 — Launch an EC2 instance with the role | ✅ |
| Task 4 — Assume the role using STS | ✅ |
| Task 5 — Clean up resources | ✅ |

## Key concepts covered

- IAM managed policies and JSON policy structure
- IAM roles, trust policies, and instance profiles
- Permission boundaries and how they cap effective permissions
- STS AssumeRole and temporary credentials
- EC2 instance types and free-tier restrictions

You can now delete this lab environment from your CloudLabs environment page.

---

**Page 6 of 6** | [← Previous: Task 4 — Assume Role via STS](04-assume-role-sts.md)
