# AWS S3 Access Control & Policy Guide

This document summarizes the concepts, configurations, and troubleshooting steps for controlling access to objects and buckets in Amazon S3 using IAM policies and bucket policies.

---

# 1. Overview

Amazon S3 permissions are controlled using:

* **IAM Policies** (attached to users, groups, or roles)
* **Bucket Policies** (attached directly to the bucket)

Permissions are evaluated using the following order:

```
Explicit Deny
    ↓
Explicit Allow
    ↓
Implicit Deny (default)
```

An **Explicit Deny always overrides any Allow**.

---

# 2. S3 Resource Types

S3 permissions apply to two resource types:

## Bucket Resource

Used for bucket-level operations.

```
arn:aws:s3:::bucket-name
```

Example actions:

* List bucket contents
* Get bucket location
* Manage bucket policy

---

## Object Resource

Used for objects stored inside the bucket.

```
arn:aws:s3:::bucket-name/*
```

Example actions:

* Upload object
* Download object
* Delete object

---

# 3. CRUD Operations in S3

| Operation | Action          |
| --------- | --------------- |
| Create    | s3:PutObject    |
| Read      | s3:GetObject    |
| Update    | s3:PutObject    |
| Delete    | s3:DeleteObject |

Additional action required:

```
s3:ListBucket
```

This allows listing objects in a bucket.

---

# 4. Common S3 IAM Actions

## Bucket-Level Actions

| Action                 | Purpose                |
| ---------------------- | ---------------------- |
| s3:ListBucket          | List objects in bucket |
| s3:ListBucketVersions  | List object versions   |
| s3:GetBucketLocation   | Get region             |
| s3:GetBucketPolicy     | Read bucket policy     |
| s3:PutBucketPolicy     | Update bucket policy   |
| s3:DeleteBucketPolicy  | Remove policy          |
| s3:GetBucketAcl        | Read bucket ACL        |
| s3:PutBucketAcl        | Modify bucket ACL      |
| s3:GetBucketVersioning | Check versioning       |
| s3:PutBucketVersioning | Enable versioning      |

---

## Object-Level Actions

| Action                  | Purpose                 |
| ----------------------- | ----------------------- |
| s3:GetObject            | Download object         |
| s3:PutObject            | Upload object           |
| s3:DeleteObject         | Delete object           |
| s3:GetObjectAcl         | Read object ACL         |
| s3:PutObjectAcl         | Modify object ACL       |
| s3:GetObjectVersion     | Read object version     |
| s3:DeleteObjectVersion  | Delete object version   |
| s3:RestoreObject        | Restore Glacier object  |
| s3:AbortMultipartUpload | Cancel multipart upload |

---

# 5. S3 Object Keys and Folder Behavior

S3 does **not actually have folders**.

Instead it stores objects using **keys**.

Example structure shown in console:

```
bucket
 └── images
      └── logo.png
```

Actual stored key:

```
images/logo.png
```

The **entire path is the object key**.

---

# 6. Object URL Format

## General Format

```
https://BUCKET_NAME.s3.REGION.amazonaws.com/OBJECT_KEY
```

Example:

```
https://my-bucket.s3.amazonaws.com/images/logo.png
```

---

# 7. Granting Access to a Single IAM User

Example bucket policy allowing only one user access.

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT_ID:user/USERNAME"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::bucket-name/*"
    }
  ]
}
```

---

# 8. Restricting Access to a Single Object

Example allowing access only to `report.pdf`.

```
{
 "Version":"2012-10-17",
 "Statement":[
  {
   "Effect":"Allow",
   "Principal":{
     "AWS":"arn:aws:iam::ACCOUNT_ID:user/USERNAME"
   },
   "Action":"s3:GetObject",
   "Resource":"arn:aws:s3:::bucket-name/report.pdf"
  }
 ]
}
```

---

# 9. Upload Only to a Specific Folder

Example allowing upload to `uploads/` folder only.

```
{
 "Version":"2012-10-17",
 "Statement":[
  {
   "Effect":"Allow",
   "Action":"s3:PutObject",
   "Resource":"arn:aws:s3:::bucket-name/uploads/*"
  }
 ]
}
```

User can upload but cannot:

* download
* delete
* list bucket

---

# 10. Deny Everything Except GetObject

Example restricting access to read-only.

```
{
 "Version":"2012-10-17",
 "Statement":[
  {
   "Effect":"Deny",
   "NotAction":"s3:GetObject",
   "Resource":"arn:aws:s3:::bucket-name/*"
  }
 ]
}
```

---

# 11. Versioning Behavior

When versioning is enabled:

```
index.html (v3)
index.html (v2)
index.html (v1)
```

The S3 static website endpoint always serves the **latest version**.

To rollback:

1. Go to object versions
2. Delete the latest version
3. Previous version becomes active

---

# 12. Why Bucket and Object ARNs Are Both Needed

Example policy:

```
{
 "Effect":"Allow",
 "Action":"s3:ListBucket",
 "Resource":"arn:aws:s3:::my-bucket"
},
{
 "Effect":"Allow",
 "Action":[
   "s3:GetObject",
   "s3:PutObject"
 ],
 "Resource":"arn:aws:s3:::my-bucket/*"
}
```

Reason:

```
Bucket operations → bucket ARN
Object operations → object ARN
```

---

# 13. Troubleshooting

## Invalid Principal in Policy

Cause:

* IAM user ARN incorrect
* user does not exist
* wrong account ID

Fix:

Copy the ARN directly from IAM user summary.

---

## User Can Access All Objects Even When Restricted

Possible reasons:

1. User has another IAM policy like:

```
AmazonS3FullAccess
```

2. Group policy allows broader access.

Solution:

Use **explicit deny**.

---

## Cannot List Bucket

Cause:

Policy only allows:

```
arn:aws:s3:::bucket/*
```

Fix:

Add permission for:

```
arn:aws:s3:::bucket
```

with action:

```
s3:ListBucket
```

---

## Access Denied When Opening Object URL

Possible reasons:

* Bucket policy restricts access
* Object not public
* IAM credentials not used

Anonymous browser requests are treated as **public access**.

---

# 14. Key Takeaways

1. S3 permissions are divided into **bucket-level and object-level actions**.
2. Folder names are just **prefixes in the object key**.
3. Always include both resources when needed:

```
arn:aws:s3:::bucket-name
arn:aws:s3:::bucket-name/*
```

4. Explicit deny overrides all allows.
5. Entire path of an object is its **key**.

---

# 15. Quick Cheat Sheet

```
Create → PutObject
Read   → GetObject
Update → PutObject
Delete → DeleteObject
List   → ListBucket
```

---

End of Guide
