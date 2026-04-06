# Exercise 4 — Explore the Web Server and Application Files

**Estimated Time:** 15 minutes  
**Tags:** linux, apache, php, files

---

## Objective

Navigate the EC2 file system to find and read the application files, understand how the PHP app connects to RDS, and see the Apache web server configuration.

---

## Steps

### Step 4.1 — List the Web Application Files

```bash
ls -la /var/www/html/
```

You should see:
```
index.php       ← the main web application
db_config.php   ← the database connection config
```

Note the permissions on `db_config.php` — it should be `640` (owner can read/write, group can read, others cannot). This prevents other users on the system from reading the database password.

---

### Step 4.2 — Read the Database Config File

```bash
cat /var/www/html/db_config.php
```

You will see the PHP file that stores the RDS connection details:
- The **RDS endpoint hostname** (a long AWS-generated hostname)
- The **database name** (`webappdb`)
- The **username** (`dbadmin`)
- The **password** (the value CloudLabs generated)

This file was written automatically by the UserData script when the EC2 instance first booted.

> 🔐 In a production system, credentials would never be stored in a flat file like this. They would be stored in AWS Secrets Manager or Parameter Store. For this lab environment, this approach is acceptable.

---

### Step 4.3 — Read the Main Application File

```bash
cat /var/www/html/index.php
```

Read through the PHP code and identify:

1. **Where it includes db_config.php** — look for `require` or `include`
2. **Where it handles the INSERT** — look for `INSERT INTO users`
3. **Where it handles the DELETE** — look for `DELETE FROM users`
4. **Where it runs the SELECT to display records** — look for `SELECT * FROM users`

---

### Step 4.4 — Check Apache Configuration

Apache is the web server that receives your browser requests and hands them to PHP.

**Check if Apache is running:**
```bash
systemctl status httpd
```

**Find the Apache config directory:**
```bash
ls /etc/httpd/conf/
```

**Check which user Apache runs as:**
```bash
ps aux | grep httpd | head -3
```

You should see Apache worker processes running as the `apache` user (not root — this is a security best practice).

---

### Step 4.5 — Check PHP Version

```bash
php --version
```

Expected: `PHP 8.2.x`

Now check which PHP modules are loaded (these are the ones installed by the UserData script):

```bash
php -m | grep -E "mysqli|mysqlnd|Core"
```

The `mysqli` and `mysqlnd` modules are what allow PHP to talk to MySQL/RDS.

---

### Step 4.6 — Check the UserData Log

The entire setup of this instance was automated. You can see exactly what ran:

```bash
cat /var/log/userdata.log
```

Scroll through the log to see every step — package installs, user creation, RDS polling, PHP app deployment. The last line should say:

```
+ echo 'UserData completed successfully'
```

---

## ✅ Success Criteria

- [ ] `db_config.php` found and readable — contains a real RDS hostname (not a placeholder)
- [ ] `index.php` found — can identify the INSERT, DELETE, and SELECT sections
- [ ] Apache status shows `Active (running)`
- [ ] PHP version is 8.2.x
- [ ] UserData log last line confirms successful completion

---

## 💡 Key Points

- `/var/www/html` is Apache's **document root** — any file here is served to web browsers
- `db_config.php` uses permission `640` to protect credentials
- PHP 8.2 had to be installed via `amazon-linux-extras` because Amazon Linux 2 ships with PHP 5.4 by default
