# Task 2: Explore the Infrastructure

## Step 1: Review the CloudFormation Stack

1. Open the **AWS Management Console** using the credentials provided in Environment Details.
2. Navigate to **CloudFormation** using the search bar at the top.
3. Click on the deployed stack (it will be named with your Deployment ID).
4. Click the **Outputs** tab — this shows all values exported by the template including the web app URL, RDS endpoint, EC2 instance ID, and IAM role name.
5. Click the **Resources** tab — this lists every AWS resource created by the template.
6. Click the **Events** tab — this shows the chronological log of how each resource was created.
7. Click the **Parameters** tab — this shows the input values used during deployment.

## Step 2: Review the EC2 Instance

1. Navigate to **EC2** in the AWS Console.
2. Click **Instances** in the left menu.
3. Find the instance named **WebApp-EC2-\<DeploymentID\>** and click on it.
4. In the **Details** tab, note the following:
   - **Public IPv4 address** — this matches the `EC2ElasticIP` output
   - **Instance type** — t3.small
   - **AMI ID** — Amazon Linux 2
5. Click the **Security** tab and review the inbound rules — you should see ports 80 (HTTP), 22 (SSH), 3389 (RDP), and 443 (HTTPS) open.
6. Click the **Monitoring** tab to view CPU and network metrics.

## Step 3: Review the Security Groups

1. In the EC2 console, click **Security Groups** in the left menu.
2. Find **WebApp-EC2-SG-\<DeploymentID\>** and click on it.
3. Click the **Inbound rules** tab — verify HTTP (80), SSH (22), RDP (3389), and HTTPS (443) are open from `0.0.0.0/0`.
4. Go back and find **WebApp-RDS-SG-\<DeploymentID\>**.
5. Click **Inbound rules** — notice port 3306 (MySQL) is only allowed from the EC2 Security Group, **not from the internet**. This is how the database is protected.

## Step 4: Review the RDS Database

1. Navigate to **RDS** in the AWS Console.
2. Click **Databases** in the left menu.
3. Click on the database instance **webapp-rds-mysql**.
4. In the **Connectivity & security** tab, note:
   - **Endpoint** — this matches the `RDSEndpoint` output
   - **Publicly accessible** — shows the database accessibility setting
5. In the **Configuration** tab, note:
   - **Engine version** — MySQL 8.0
   - **Instance class** — db.t3.micro
   - **DB name** — webappdb

## Step 5: Review the IAM Role

1. Navigate to **IAM** in the AWS Console.
2. Click **Roles** in the left menu.
3. Search for **WebApp-EC2-Role-\<DeploymentID\>** and click on it.
4. Click the **Permissions** tab and expand the attached inline policy.
5. Review the two permissions granted:
   - `cloudformation:SignalResource` — allows EC2 to notify CloudFormation when setup is complete
   - `logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents`, `logs:DescribeLogStreams` — allows EC2 to write logs to CloudWatch

## Step 6: Access the EC2 Instance via SSH

1. Open a terminal on your local machine.
2. Copy the **SSHCommand** value from the Environment Details panel.
3. Run the command — it will look like:
   ```
   ssh labuser@xx.xx.xx.xx
   ```
4. When prompted `Are you sure you want to continue connecting?` type `yes` and press Enter.
5. Enter the **Linux Password** from the Environment Details panel when prompted.
6. You are now connected to the EC2 instance.

## Step 7: Review the User Data Log

Once connected via SSH, run the following command to view the full User Data execution log:

```bash
cat /var/log/userdata.log
```

Scroll through the log to see:
- Package installation output
- SSH configuration changes
- User account creation
- xRDP setup
- Apache startup
- RDS readiness checks (`Attempt X/40...`)
- Table creation SQL
- Application deployment
- Final line: `UserData completed successfully.`

## Step 8: Review the Application Files

Run these commands to view the deployed application files:

```bash
# View the database config file
cat /var/www/html/db_config.php

# View the main PHP application
cat /var/www/html/index.php

# Check Apache is running
systemctl status httpd

# Check xRDP is running
systemctl status xrdp
```

Type `exit` to disconnect from the SSH session when done.