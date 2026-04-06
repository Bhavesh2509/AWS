# Exercise 1 — Access the Web Application

**Estimated Time:** 10 minutes  
**Tags:** webapp, php, browser

---

## Objective

Open the deployed PHP web application in your browser and understand what it does.

---

## Background

The web application is a simple PHP app running on Apache on your EC2 instance. It connects to an RDS MySQL database and lets you insert and delete records from a `users` table. The entire app was deployed automatically when the CloudFormation stack launched — no manual setup was done.

---

## Steps

### Step 1.1 — Open the Web Application

1. Copy the **WebAppURL** value from your lab credentials panel. It will look like:
   ```
   http://98.88.182.123
   ```
2. Paste it into your browser and press Enter.

> ⚠️ **Important:** The URL must start with `http://` — not `https://`. The app runs on port 80 only. If you type `https://` the page will not load.

---

### Step 1.2 — Understand the Page

You should see a page titled **"CloudLabs Web Application"** with:

- A form with **Name** and **Email** fields
- A **Save** button
- A table showing existing records (empty for now)
- A **Delete** button next to each record

This page is the file `/var/www/html/index.php` on your EC2 instance. You will explore that file in a later exercise.

---

### Step 1.3 — Verify the Database Connection

Look at the top of the page. If the app says **"Connected successfully"** or shows the form without any error, the PHP app has successfully connected to your RDS MySQL database.

If you see **"Connection failed"** — raise this with your instructor before continuing.

---

## ✅ Success Criteria

- [ ] Web application page loads in the browser
- [ ] No database connection error is shown
- [ ] You can see the Name and Email form

---

## 💡 Key Point

The database connection details (RDS hostname, username, password, database name) are stored in `/var/www/html/db_config.php` on the EC2 instance. You will look at this file in Exercise 4.
