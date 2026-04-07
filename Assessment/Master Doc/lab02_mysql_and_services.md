# Lab 2 — MySQL Queries & Services

**Estimated Time:** 25 minutes

---

## Exercise 2.1 — Connect to RDS MySQL

The RDS instance is **not reachable from the internet** — only from the EC2 instance. You must SSH into EC2 first (as you did in Lab 1), then connect to RDS from there.

### Set Up the Connection

Inside your SSH session, set the DB password as an environment variable so you do not have to type it on the command line:

```bash
export MYSQL_PWD='<DBPassword from credentials panel>'
```

Now connect to MySQL:

```bash
mysql -h <RDSEndpoint> -u dbadmin webappdb
```

Replace `<RDSEndpoint>` with the value from your credentials panel.

You should see the MySQL prompt:
```
mysql>
```

### Explore the Database

**Show all databases:**
```sql
SHOW DATABASES;
```

**Confirm you are in the right database:**
```sql
SELECT DATABASE();
```
Expected: `webappdb`

**Show tables:**
```sql
SHOW TABLES;
```
Expected: `users`

**Describe the table structure:**
```sql
DESCRIBE users;
```

Note the columns: `id` (auto-increment primary key), `name`, `address`, and a `created_at` timestamp.

### Query Your Data

**Select all records:**
```sql
SELECT * FROM users;
```

These are the same records you inserted via the web app in Lab 1.

**Count records:**
```sql
SELECT COUNT(*) AS total_records FROM users;
```

**Find your George record:**
```sql
SELECT * FROM users WHERE name = 'George';
```

**Order by newest first:**
```sql
SELECT * FROM users ORDER BY id DESC;
```

### Check MySQL Server Info

**MySQL version:**
```sql
SELECT VERSION();
```
Expected: `8.0.x`

**Character set :**
```sql
SHOW VARIABLES LIKE 'character_set_server';
```

Expected: `utf8mb4` — MySQL 8.0's default. The PHP app calls `set_charset('utf8mb4')` to match this, which is why there is no charset error when connecting.

### Exit MySQL

```sql
EXIT;
```

---

## Exercise 2.2 — Check Running Services and System Health

All commands run inside your SSH session.

### Check Key Services

Run each and confirm `Active: active (running)`:

```bash
systemctl status httpd
```

```bash
systemctl status xrdp
```

```bash
systemctl status sshd
```

### Check Open Ports

```bash
ss -tlnp
```

Look for these in the output:

| Port | Service |
|------|---------|
| 22   | sshd    |
| 80   | httpd   |

Port 3306 (MySQL) will **not** appear here — RDS runs on a separate managed instance, not on EC2.

### Read the Apache Access Log

Every browser request to the web app is logged here:

```bash
sudo tail -20 /var/log/httpd/access_log
```

You should see lines like:
```
<IP> - - [06/Apr/2026:10:23:11 +0000] "GET / HTTP/1.1" 200 4521
<IP> - - [06/Apr/2026:10:23:45 +0000] "POST / HTTP/1.1" 302 -
```

- `GET /` — a page load
- `POST /` with a `302` response — a form submission (insert or delete) followed by a redirect

### Check Memory

```bash
free -h
```

Total should be ~2GB. This is why `t3.small` was used — `t2.micro` (1GB) runs out of memory during PHP 8.2 installation and the instance terminates mid-setup.

### Check Disk Usage

```bash
df -h
```

Check the root filesystem `/` — the instance has an 8GB root volume. Usage should be well under 80%.

###  Checkpoint
- [ ] Apache, xRDP, and sshd all show `Active (running)`
- [ ] Ports 22, 80, and 3389 visible in `ss -tlnp`
- [ ] Apache access log shows GET and POST requests from Lab 1
- [ ] Memory shows ~2GB total
