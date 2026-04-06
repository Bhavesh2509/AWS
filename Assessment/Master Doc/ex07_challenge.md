# Exercise 7 — Challenge: Add a New Record via MySQL CLI

**Estimated Time:** 10 minutes  
**Tags:** mysql, sql, challenge

---

## Objective

Insert a record directly into the MySQL database using the CLI — bypassing the web app entirely — and then verify it appears in the web application without doing anything else.

This demonstrates that the web app and the MySQL CLI are both looking at the **same underlying data**.

---

## The Challenge

Insert a record into the `users` table with the following values:

| Field | Value         |
|-------|---------------|
| name  | `LabTest`     |
| email | `lab@test.com`|

> If you already added `LabTest` via the web app in Exercise 2, insert a second one with a different email, or delete the old one first and re-add via CLI.

---

## Steps

### Step 7.1 — Connect to MySQL

```bash
export MYSQL_PWD='<your-db-password>'
mysql -h <RDS-endpoint> -u dbadmin webappdb
```

---

### Step 7.2 — Insert the Record

Write and run the SQL INSERT statement yourself. The table structure is:

```sql
DESCRIBE users;
```

Use what you learned in Exercise 5 about the columns to write a correct `INSERT INTO` statement.

<details>
<summary>💡 Hint — click to reveal if stuck</summary>

```sql
INSERT INTO users (name, email) VALUES ('LabTest', 'lab@test.com');
```

The `id` column is auto-increment so you do not need to supply it.

</details>

---

### Step 7.3 — Verify in MySQL

Before checking the web app, confirm the record is in the database:

```sql
SELECT * FROM users WHERE name = 'LabTest';
```

Note the `id` value assigned to your new record.

```sql
EXIT;
```

---

### Step 7.4 — Verify in the Web App

Open your browser and go to the **WebAppURL**:
```
http://<EC2ElasticIP>
```

Refresh the page. Your `LabTest` record should appear in the table — even though you never used the form.

---

### Step 7.5 — Bonus: Delete via Web App, Confirm via CLI

1. In the browser, click **Delete** next to the `LabTest` record
2. Go back to your SSH session and reconnect to MySQL
3. Run:
   ```sql
   SELECT * FROM users WHERE name = 'LabTest';
   ```
4. The record should be gone — confirming that the DELETE button in the PHP app runs a real SQL DELETE against the same database

---

## ✅ Success Criteria

- [ ] Record inserted via MySQL CLI successfully
- [ ] `SELECT * FROM users WHERE name = 'LabTest'` returns 1 row
- [ ] Record appears in the web application without any form submission
- [ ] (Bonus) Record deleted via web app and confirmed gone via CLI

---

## 🎉 Lab Complete

You have:
- Used a live PHP web application to manage database records
- Connected to EC2 via SSH and explored the Linux environment
- Read application files and understood how the app connects to RDS
- Connected directly to RDS MySQL and run SQL queries
- Explored running services, logs, and system resources
- Inserted data directly via the MySQL CLI and observed it in the web app

This is a complete picture of how a basic **3-tier web application** (browser → web server → database) works on AWS.
