# Lab 3 — Challenge: Insert via CLI, Verify in Browser

**Estimated Time:** 10 minutes

---

## Objective

Insert a record directly into the MySQL database using the CLI — **bypassing the web app entirely** — then verify it appears in the browser without submitting any form.

This proves that the PHP web app and the MySQL CLI are both reading from and writing to the **same underlying data store**.

---

## The Task

Insert a record with these exact values:

| Field | Value         |
|-------|---------------|
| name  | `LabTest`     |
| email | `lab@test.com`|

> If a `LabTest` record already exists from Lab 1, delete it first or update the email — the validation check looks for exactly one record with `name = 'LabTest'`.

---

## Steps

### Step 1 — Connect to MySQL

Inside your SSH session:

```bash
export MYSQL_PWD='<DBPassword>'
mysql -h <RDSEndpoint> -u dbadmin webappdb
```

---

### Step 2 — Write and Run the INSERT

Using what you learned in Lab 2 about the `users` table structure, write the `INSERT INTO` statement yourself.

<details>
<summary>Hint — click to expand if stuck</summary>

```sql
INSERT INTO users (name, email) VALUES ('LabTest', 'lab@test.com');
```

The `id` column is auto-increment — you do not need to supply it.

</details>

---

### Step 3 — Verify in MySQL

```sql
SELECT * FROM users WHERE name = 'LabTest';
```

Confirm the record exists, then exit:

```sql
EXIT;
```

---

### Step 4 — Verify in the Browser

Open your browser, go to **WebAppURL**, and refresh the page.

The `LabTest` record should appear in the table — even though you never used the form.

---

### Step 5 — Bonus: Round-Trip Delete

1. In the browser, click **Delete** next to `LabTest` and confirm.
2. Go back to your SSH session and reconnect to MySQL.
3. Run:
   ```sql
   SELECT * FROM users WHERE name = 'LabTest';
   ```
4. The record should be gone — confirming the PHP `DELETE` button runs a real `DELETE FROM users` SQL statement against the same database.

---

## ✅ Validation Checks

CloudLabs will automatically verify:

| Check | Query | Expected |
|-------|-------|----------|
| chk01 | `SELECT COUNT(*) FROM webappdb.users` | > 0 |
| chk02 | `SELECT COUNT(*) FROM webappdb.users WHERE name = 'LabTest'` | = 1 |

Make sure `LabTest` exists in the database (do not delete it after the bonus step, or re-insert it) before submitting.

---

## 🎉 Lab Complete

You have completed all three labs. Here is what you covered:

| Topic | What You Did |
|-------|--------------|
| Web Application | Opened the PHP app, inserted and deleted records via the browser |
| SSH Access | Connected to EC2 with password authentication, verified OS and instance details |
| Application Files | Read `index.php` and `db_config.php`, traced the full request flow |
| MySQL CLI | Connected to RDS from EC2, ran SELECT / DESCRIBE / SHOW queries |
| Services | Verified Apache, xRDP, and sshd with `systemctl`, checked open ports |
| Logs | Read Apache access logs, identified GET vs POST requests |
| System Health | Checked memory and disk usage, understood why t3.small was chosen |
| Challenge | Inserted directly via CLI, observed the record appear in the browser |
