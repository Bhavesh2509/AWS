# 🧪 AWS IAM Basics Lab Guide

**Contoso Startup Labs – IAM Hands-on**

---

## 🎯 Lab Objective

In this lab, you will:

* Understand **IAM Users, Roles, and Policies**
* Work with a **Permission Boundary**
* Launch and interact with an **EC2 Windows Jump VM**
* Test **restricted AWS access**

---

## 🏗️ Lab Architecture

* **VPC + Public Subnet**
* **Windows EC2 (Jump VM)**
* **IAM Role (attached to EC2)**
* **Permission Boundary (restricts actions)**

---

## 🔐 Key Concepts

### 👤 IAM User

* Represents a human user
* Used for AWS Console login

### 🖥️ IAM Role

* Used by AWS services (like EC2)
* Provides temporary credentials

### 📜 IAM Policy

* Defines **what actions are allowed**

### 🚧 Permission Boundary

* Defines the **maximum permissions allowed**
* Even if a policy allows something, boundary can block it

---

## 🚀 Lab Steps

---

### ✅ Step 1: Access the Windows VM

1. Go to **EC2 Console**
2. Select your instance
3. Click **Connect → RDP**
4. Login using:

```
Username: .\LabAdmin
Password: <your VMAdminPassword>
```

> ⏱️ Wait 5–7 minutes after deployment before logging in

---

### ✅ Step 2: Verify AWS CLI Access

Inside the VM:

```bash
aws sts get-caller-identity
```

👉 This confirms the **IAM Role is attached**

---

### ✅ Step 3: Test S3 Access

```bash
aws s3 ls
```

👉 Expected:

* Should list buckets OR work successfully

---

### ❌ Step 4: Try Restricted Action

Try creating a large EC2 instance:

```bash
aws ec2 run-instances --instance-type t2.large ...
```

👉 Expected:

```
AccessDenied
```

✔ Because of **Permission Boundary restriction**

---

### ✅ Step 5: Launch Allowed Instance

```bash
aws ec2 run-instances --instance-type t2.micro ...
```

👉 Expected:
✔ Works successfully

---

## 🔍 Understanding the Boundary

### ✔ Allowed:

* t2.micro / t3.micro EC2 instances
* Basic S3 operations
* Read-only IAM actions

### ❌ Denied:

* Creating IAM users
* Modifying permission boundaries
* Billing / organization actions
* Larger EC2 instances

---

## 🧪 Optional: IAM User Testing

If a lab IAM user is created:

1. Login to AWS Console
2. Try:

   * Creating EC2 → ✅ Allowed (only small types)
   * Creating IAM User → ❌ Denied

---

## ⚠️ Common Issues & Fixes

### ❌ Cannot login to VM

* Ensure correct format:

  ```
  .\LabAdmin
  ```
* Wait for UserData to finish

---

### ❌ AWS CLI not working

* Check IAM Role attached to EC2
* Run:

  ```bash
  aws sts get-caller-identity
  ```

---

### ❌ Access Denied errors

* This is expected behavior
* Caused by **Permission Boundary**

---

## 🧠 Key Takeaways

* IAM controls **who can do what**
* Roles are used by **services**
* Users are used by **humans**
* Permission Boundaries act as a **security guardrail**

---

## 🧹 Cleanup

To avoid charges:

1. Go to CloudFormation
2. Delete the stack
3. Ensure all resources are removed

---

## 🎉 Lab Complete!

You now understand:

✔ IAM Users vs Roles
✔ Policies vs Boundaries
✔ Real-world access control in AWS

---

💡 *Next: Try creating your own restricted IAM environment!*
