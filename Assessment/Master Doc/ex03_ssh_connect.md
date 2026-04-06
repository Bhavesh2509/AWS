# Exercise 3 — Connect to EC2 via SSH

**Estimated Time:** 10 minutes  
**Tags:** ssh, linux, ec2

---

## Objective

Connect to your EC2 instance over SSH using password authentication and verify you are on the right machine.

---

## Your SSH Credentials

| Field    | Value                                      |
|----------|--------------------------------------------|
| Command  | From your lab panel — `ssh labuser@<IP>`   |
| Username | `labuser`                                  |
| Password | From your lab credentials panel            |

---

## Steps

### Step 3.1 — Open a Terminal

- **Windows:** Use the built-in **Command Prompt**, **PowerShell**, or **Windows Terminal**
- **Mac/Linux:** Use **Terminal**
- **CloudLabs:** You can also use the RDP desktop — open a terminal from there

---

### Step 3.2 — Run the SSH Command

Copy the **SSHCommand** value from your lab panel and run it. It will look like:

```bash
ssh labuser@98.88.182.123
```

When prompted:
```
Are you sure you want to continue connecting (yes/no)? 
```
Type `yes` and press Enter.

Then enter your **LinuxPassword** from the lab panel when prompted. You will not see characters as you type — this is normal for Linux password prompts.

---

### Step 3.3 — Verify You Are On the Right Machine

Once connected, run the following commands and note the output:

**Check the hostname:**
```bash
hostname
```

**Check who you are logged in as:**
```bash
whoami
```
Expected output: `labuser`

**Check the OS version:**
```bash
cat /etc/os-release | grep PRETTY
```
Expected output: `Amazon Linux 2`

**Check the public IP (should match your lab panel):**
```bash
curl -s http://checkip.amazonaws.com
```

---

### Step 3.4 — Check How Long the Instance Has Been Running

```bash
uptime
```

This shows how long the EC2 instance has been up since it was launched by CloudFormation.

---

## ✅ Success Criteria

- [ ] SSH connection established without errors
- [ ] `whoami` returns `labuser`
- [ ] OS is confirmed as Amazon Linux 2
- [ ] Public IP matches your lab panel EC2ElasticIP

---

## 💡 Key Point

Notice that you logged in with a **password**, not an SSH key pair. This was configured deliberately — CloudLabs uses browser-based access, so key pair distribution is impractical. The password auth was enabled in three SSH config layers during the EC2 UserData boot script to prevent cloud-init from overriding it.
