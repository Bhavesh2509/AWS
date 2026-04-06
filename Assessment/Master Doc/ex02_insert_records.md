# Exercise 2 — Insert and Manage Records via the App

**Estimated Time:** 10 minutes  
**Tags:** webapp, php, mysql, crud

---

## Objective

Use the web application to insert records into the MySQL database and delete them — demonstrating a full create/delete cycle through a PHP front end.

---

## Steps

### Step 2.1 — Insert Your First Record

1. In the **Name** field, type your first name (e.g. `Alice`)
2. In the **Email** field, type a test email (e.g. `alice@lab.com`)
3. Click **Save**

The page will reload and your record should appear in the table below the form.

---

### Step 2.2 — Insert More Records

Insert at least **3 more records** using different names and emails. Use these if you like:

| Name    | Email              |
|---------|--------------------|
| Bob     | bob@lab.com        |
| Carol   | carol@lab.com      |
| LabTest | labtest@lab.com    |

> 📝 **Note:** The record named `LabTest` is used in Exercise 7's validation check — make sure you add it.

---

### Step 2.3 — Delete a Record

1. Find any record in the table (not `LabTest`)
2. Click the **Delete** button next to it
3. Confirm the deletion if prompted
4. Verify the record disappears from the table

---

### Step 2.4 — Observe What's Happening

Every time you click Save or Delete, the browser is sending a form submission to `index.php`. The PHP code then:

1. Reads the form values (`$_POST['name']`, `$_POST['email']`)
2. Runs an `INSERT INTO users` or `DELETE FROM users` SQL query against RDS
3. Redirects back to the page so the table refreshes

You will see this PHP code directly in Exercise 4, and query the database directly in Exercise 5.

---

## ✅ Success Criteria

- [ ] At least 3 records visible in the table
- [ ] A record named `LabTest` exists in the table
- [ ] Successfully deleted at least one record

---

## 💡 Key Point

The data you insert here is stored in the **RDS MySQL database**, not on the EC2 instance itself. Even if the EC2 instance was stopped and restarted, your data would still be there — because it lives in RDS.
