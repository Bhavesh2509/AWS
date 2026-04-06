# Exercise 5 — Connect to RDS MySQL and Run Queries

**Estimated Time:** 15 minutes  
**Tags:** mysql, rds, sql, database

---

## Objective

Connect directly to the RDS MySQL database from the EC2 instance using the MySQL CLI and run SQL queries to inspect and manipulate the data — the same data your PHP app is using.

---

## Background

The RDS instance is **not publicly accessible from the internet** — it only accepts connections from the EC2 instance (enforced by the Security Group). So you must SSH into EC2 first, then connect to RDS from there.

---

## Steps

### Step 5.1 — Get the RDS Endpoint

First, find the RDS endpoint from the db_config file:

```bash
grep 'host' /var/www/html/db_config.php
```

Copy the hostname value — it will look like:
```
webapp-rds-2165606.cwzdble2iza4.us-east-1.rds.amazonaws.com
```

---

### Step 5.2 — Connect to MySQL

Set your DB password as an environment variable (so you don't have to type it on the command line):

```bash
export MYSQL_PWD='<your-db-password-from-lab-panel>'
```

Now connect:

```bash
mysql -h <RDS-endpoint> -u dbadmin webappdb
```

Replace `<RDS-endpoint>` with the hostname you found in Step 5.1.

You should see the MySQL prompt:
```
mysql>
```

---

### Step 5.3 — Explore the Database

**Show all databases:**
```sql
SHOW DATABASES;
```

**Confirm you are in the right database:**
```sql
SELECT DATABASE();
```
Expected: `webappdb`

**Show the tables:**
```sql
SHOW TABLES;
```
Expected: `users`

**Describe the table structure:**
```sql
DESCRIBE users;
```

Note the columns — `id` (auto-increment primary key), `name`, `email`, and likely a `created_at` timestamp.

---

### Step 5.4 — Query Your Data

**Select all records:**
```sql
SELECT * FROM users;
```

You should see all the records you inserted via the web application in Exercise 2.

**Count the records:**
```sql
SELECT COUNT(*) AS total_records FROM users;
```

**Find a specific record:**
```sql
SELECT * FROM users WHERE name = 'LabTest';
```

**Order records by newest first:**
```sql
SELECT * FROM users ORDER BY id DESC;
```

---

### Step 5.5 — Check MySQL Server Details

**Check MySQL version:**
```sql
SELECT VERSION();
```
Expected: `8.0.x`

**Check the character set (this was a known issue during development):**
```sql
SHOW VARIABLES LIKE 'character_set%';
```

You should see `utf8mb4` — this is MySQL 8.0's default. The PHP app calls `set_charset('utf8mb4')` to match this, which is why there is no charset error.

**Check current connections:**
```sql
SHOW PROCESSLIST;
```

---

### Step 5.6 — Exit MySQL

```sql
EXIT;
```

---

## ✅ Success Criteria

- [ ] Successfully connected to RDS MySQL from EC2
- [ ] `SHOW TABLES` shows the `users` table
- [ ] `SELECT * FROM users` returns the records you inserted via the web app
- [ ] `LabTest` record is present
- [ ] MySQL version confirmed as 8.0.x

---

## 💡 Key Points

- The RDS Security Group only allows port 3306 **from the EC2 Security Group** — not from the internet. This is why you must go through EC2 to reach RDS.
- Using `export MYSQL_PWD` avoids the password appearing in process lists (`ps aux`), which is a basic security practice.
- The `utf8mb4` character set supports the full Unicode range including emoji — `utf8` in MySQL is a legacy encoding that only covers 3-byte characters.
