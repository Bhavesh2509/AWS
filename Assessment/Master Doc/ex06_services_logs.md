# Exercise 6 — Check Running Services and Logs

**Estimated Time:** 10 minutes  
**Tags:** linux, systemctl, logs, troubleshooting

---

## Objective

Use `systemctl` to inspect the services running on the EC2 instance, and read log files to understand what the system is doing.

---

## Steps

### Step 6.1 — Check All Key Services

Run each command and confirm the service is `Active (running)`:

**Apache web server:**
```bash
systemctl status httpd
```

**xRDP (remote desktop):**
```bash
systemctl status xrdp
```

**SSH daemon:**
```bash
systemctl status sshd
```

For each, note the following in the output:
- `Active: active (running)` — service is up
- `Main PID` — the process ID
- `since` — how long it has been running

---

### Step 6.2 — Check What Is Listening on Which Ports

```bash
ss -tlnp
```

Look for:
| Port | Service  |
|------|----------|
| 22   | sshd     |
| 80   | httpd    |
| 3389 | xrdp     |

This confirms what the Security Group rules are protecting.

---

### Step 6.3 — Check the Apache Access Log

Every time a browser loads the web app, Apache logs the request here:

```bash
sudo tail -20 /var/log/httpd/access_log
```

You should see lines like:
```
<your-IP> - - [06/Apr/2026:10:23:11 +0000] "GET / HTTP/1.1" 200 4521
<your-IP> - - [06/Apr/2026:10:23:45 +0000] "POST / HTTP/1.1" 302 -
```

- `GET /` — someone loaded the page
- `POST /` followed by a `302` — someone submitted the form (insert or delete), then got redirected back

---

### Step 6.4 — Check the Apache Error Log

```bash
sudo tail -20 /var/log/httpd/error_log
```

Ideally this should be empty or have only startup messages. Any PHP errors would appear here.

---

### Step 6.5 — Check Disk Usage

```bash
df -h
```

Note the usage on the root filesystem `/`. The EC2 instance was launched with a default 8GB root volume.

**Check what is taking up space:**
```bash
du -sh /var/www/html/ /var/log/ /tmp/
```

---

### Step 6.6 — Check Memory Usage

```bash
free -h
```

Note:
- **Total** — should be ~2GB (t3.small)
- **Used** — Apache + PHP + xRDP will consume some
- **Available** — what is left

> 💡 This is why `t3.small` was chosen over `t2.micro`. PHP 8.2 installation alone requires more than 1GB RAM — a `t2.micro` (1GB) would run out of memory mid-setup and terminate.

---

### Step 6.7 — Check Running Processes

```bash
ps aux --sort=-%mem | head -15
```

This lists the top 15 processes by memory usage. You should see `httpd`, `xrdp`, and `sshd` among them.

---

## ✅ Success Criteria

- [ ] Apache, xRDP, and sshd all show `Active (running)`
- [ ] Ports 22, 80, and 3389 visible in `ss -tlnp`
- [ ] Apache access log shows your browser requests from Exercise 1 and 2
- [ ] Disk usage is healthy (not over 80%)
- [ ] Memory shows ~2GB total (t3.small)

---

## 💡 Key Points

- `systemctl` is the standard way to manage services on modern Linux — start, stop, restart, enable (auto-start on boot), and check status
- Apache logs every single HTTP request — this is how you would debug a broken web app in production
- The `ss` command replaces the older `netstat` on modern Linux systems
