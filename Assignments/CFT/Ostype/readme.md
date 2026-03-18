# 🚀 AWS CloudFormation: Conditional EC2 Deployment (Linux / Windows / Both)

## 📌 Overview

This project uses **AWS CloudFormation** to dynamically deploy infrastructure based on user input.

You can choose to launch:

* 🐧 **Linux EC2** with Apache Web Server
* 🪟 **Windows EC2** with IIS Web Server
* 🔀 **Both** (2 EC2 instances: Linux + Windows)

Each instance serves a **custom HTML page**.

---

## 🧠 Architecture

* **VPC** (10.0.0.0/16)
* **Public Subnet** (10.0.1.0/24)
* **Internet Gateway**
* **Route Table + Route**
* **Security Group**

  * HTTP (80)
  * SSH (22)
  * RDP (3389)
* **EC2 Instances (Conditional)**

  * Apache (Linux)
  * IIS (Windows)

---

## ⚙️ Parameters

| Parameter      | Description                           |
| -------------- | ------------------------------------- |
| `OSSelection`  | Choose `Linux`, `Windows`, or `Both`  |
| `InstanceType` | EC2 instance type (default: t3.micro) |
| `KeyName`      | Existing AWS Key Pair                 |
| `CustomHTML`   | Custom HTML content                   |
| `LinuxAMI`     | Linux AMI ID (region-specific)        |
| `WindowsAMI`   | Windows AMI ID (region-specific)      |

---

## 🔀 Condition Logic

| Selection | Linux EC2 | Windows EC2 |
| --------- | --------- | ----------- |
| Linux     | ✅         | ❌           |
| Windows   | ❌         | ✅           |
| Both      | ✅         | ✅           |

---

## 🚀 Deployment Steps

### 1️⃣ Login to AWS Console

Go to:
👉 CloudFormation → **Create Stack** → *With new resources*

---

### 2️⃣ Upload Template

* Upload the YAML template file
* Click **Next**

---

### 3️⃣ Enter Parameters

* Choose:

  * `Linux` OR `Windows` OR `Both`
* Select:

  * Instance type
  * Key Pair
* (Optional) Customize HTML

---

### 4️⃣ Configure Stack

* Keep defaults
* Click **Next**

---

### 5️⃣ Review & Create

* Check **Acknowledgement**
* Click **Create Stack**

---

### 6️⃣ Wait for Completion

* Status → `CREATE_COMPLETE`

---

## 🌐 Access Your Application

### 🔹 Linux Server

```
http://<Linux-Public-IP>
```

### 🔹 Windows Server

```
http://<Windows-Public-IP>
```

---

## 🔐 Access Instances

### SSH (Linux)

```bash
ssh -i key.pem ec2-user@<public-ip>
```

### RDP (Windows)

* Go to EC2 → Select instance → **Connect**
* Download password using key pair

---

## ⚠️ Important Notes

* AMIs are **region-specific**
* Windows instance takes **5–10 minutes** to initialize
* Public IP is auto-assigned via subnet setting

---

## 🛠️ Troubleshooting

### ❌ Stack Creation Failed

* Check **Events tab** in CloudFormation
* Most common issue: ❗ **Invalid AMI ID**

---

### ❌ Website Not Loading

* Ensure:

  * Security Group allows **port 80**
  * Instance is **running**
* Try:

```bash
curl localhost
```

---

### ❌ Linux Apache Not Working

SSH into instance:

```bash
sudo systemctl status httpd
sudo systemctl restart httpd
```

---

### ❌ Windows IIS Not Working

* RDP into instance
* Run:

```powershell
Get-Service W3SVC
Start-Service W3SVC
```

---

### ❌ Cannot SSH

* Check:

  * Key pair is correct
  * Port 22 open in security group
  * Use correct user:

    ```
    ec2-user
    ```

---

### ❌ Cannot RDP

* Ensure:

  * Port 3389 open
  * Instance fully initialized
  * Correct password decrypted

---

### ❌ No Public IP

* Check subnet setting:

  * `MapPublicIpOnLaunch = true`

---

## 📚 Learning Outcomes

* ✅ CloudFormation **Conditions**
* ✅ Parameterized Infrastructure
* ✅ EC2 UserData automation
* ✅ Networking setup (VPC, Subnet, IGW)
* ✅ Apache & IIS configuration
* ✅ Multi-OS deployment strategy

---

## 🔥 Future Enhancements

* Add **Application Load Balancer**
* Use **Auto Scaling Groups**
* Deploy in **private subnet with NAT Gateway**
* Add **HTTPS using ACM**
* Use **SSM instead of SSH/RDP**

---


