# Lab 1 — Web App, SSH & File Exploration

**Estimated Time:** 25 minutes

---

## Exercise 1.1 — Access the Web Application

### Steps

1. Copy the **WebAppURL** from your CloudLabs credentials panel.
2. Paste it into your browser and press Enter.

> ⚠️ The URL must start with `http://` — **not** `https://`. The app runs on port 80 only. Typing `https://` will result in a blank or error page.

You should see a page titled **CloudLabs Web Application** with:
- A form with **Name** and **Address** fields
- A **Save** button
- A table showing existing records

If you see **"Connection failed"** at the top of the page, raise this with your instructor before continuing.

### Insert Records

Insert at least **3 records** using the form. Include this one exactly — it is used for the final validation check:

| Name      | Address             |
|-----------|-------------------|
| `George` | `USA` |

After each save, the page reloads and the new record appears in the table.

### Delete a Record

Delete any one record (not `George`) by clicking the **Delete** button next to it and confirming.

###  Checkpoint
- [ ] Web app loads without errors
- [ ] At least 3 records visible in the table including `George`
- [ ] Successfully deleted one record

---

## Exercise 1.2 — Connect to EC2 via SSH

### Steps

1. Open a terminal:
   - **Windows** — Command Prompt, PowerShell, or Windows Terminal
   - **Mac / Linux** — Terminal app

2. Copy the **SSHCommand** from your credentials panel and run it:
   ```bash
   ssh labuser@<EC2ElasticIP>
   ```

3. When prompted `Are you sure you want to continue connecting (yes/no)?` — type `yes` and press Enter.

4. Enter your **LinuxPassword** when prompted. You will not see characters as you type — this is normal.

### Verify You Are on the Right Machine

```bash
whoami
```
Expected: `labuser`

```bash
cat /etc/os-release | grep PRETTY
```
Expected: `Amazon Linux 2`

```bash
curl -s http://checkip.amazonaws.com
```
Expected: matches **EC2ElasticIP** in your credentials panel.

###  Checkpoint
- [ ] SSH connected without errors
- [ ] `whoami` returns `labuser`
- [ ] Public IP matches EC2ElasticIP

---

## Exercise 1.3 — Explore Application Files

All commands in this exercise run inside your SSH session.

### List the Web App Files

```bash
ls -la /var/www/html/
```

You should see two files:
- `index.php` — the main web application
- `db_config.php` — the database connection config

Note the permissions on `db_config.php`. It should show `640` — readable by owner and group, but **not** by others. This protects the database password from other users on the system.

### Read the Database Config

```bash
cat /var/www/html/db_config.php
```

You will see the RDS hostname, database name, username, and password. This file was written automatically by the EC2 UserData script at first boot.


### Read the Application Code

```bash
cat /var/www/html/index.php
```

Read through the PHP code and find:
1. Where it includes `db_config.php`
2. The `INSERT INTO users` statement
3. The `DELETE FROM users` statement
4. The `SELECT * FROM users` query that populates the table

### Check the UserData Boot Log

The entire EC2 setup was automated. You can read exactly what ran:

```bash
cat /var/log/userdata.log
```

Scroll to the bottom. The last line should be:
```
+ echo 'UserData completed successfully'
```

### Check PHP Version

```bash
php --version
```
Expected: `PHP 8.2.x`

PHP 8.2 was installed via `amazon-linux-extras` — Amazon Linux 2 ships with PHP 5.4 by default, so the UserData script had to enable the PHP 8.2 repo first.

###  Checkpoint
- [ ] `db_config.php` contains a real RDS hostname (not a `${placeholder}`)
- [ ] `index.php` found — INSERT, DELETE, and SELECT sections identified
- [ ] UserData log last line confirms successful completion
- [ ] PHP version is 8.2.x
