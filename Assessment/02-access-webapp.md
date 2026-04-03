# Task 1: Access the Web Application

## Step 1: Open the Web Application

1. In the **Environment Details** panel on the left, locate the **WebAppURL** output.
2. Copy the URL (it will look like `http://xx.xx.xx.xx`).
3. Open a new browser tab and paste the URL.
4. The **CloudLabs Web Application** page should load showing a form and a records table.

> **Note:** If the page does not load immediately, wait 1-2 minutes and refresh. The EC2 User Data script may still be completing its setup.

## Step 2: Submit a Record

1. In the **Submit Your Details** form, enter your **Full Name** in the first field.
2. Enter an **Address** in the second field.
3. Click the **Save to Database** button.
4. The page will reload and your entry will appear in the **Records in RDS** table below the form.

## Step 3: Submit More Records

1. Repeat Step 2 two or three more times with different names and addresses.
2. Observe that each new record appears at the top of the table (records are ordered by most recent first).
3. The data is being stored in the **Amazon RDS MySQL** database and retrieved on each page load.

## Step 4: Delete a Record

1. In the **Records in RDS** table, locate any record.
2. Click the **Delete** button on the right side of that row.
3. A confirmation dialog will appear — click **OK**.
4. The record will be removed from the table and deleted from the RDS database.

## How It Works

When you submit the form:

1. Your browser sends an HTTP POST request to Apache running on the EC2 instance
2. Apache passes the request to PHP (`index.php`)
3. PHP reads database connection details from `db_config.php`
4. PHP connects to RDS MySQL and runs an `INSERT` query
5. PHP redirects back to the page and runs a `SELECT` query to display all records

## Verification

| Check | Expected Result |
|---|---|
| Web page loads at `WebAppURL` | CloudLabs Web Application page displays |
| Form submission works | Record appears in the table |
| Multiple records display correctly | All records shown, newest first |
| Delete works | Record removed from table and database |