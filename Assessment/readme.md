# CloudLabs AWS Web Application Deployment — Complete Study Guide

---

## 1. What We Built

A fully automated AWS web application that:
- Runs a PHP web page on an EC2 instance with Apache
- Stores and retrieves data from an RDS MySQL database
- Is deployed entirely via a single CloudFormation template
- Supports RDP access via CloudLabs Direct Web Connect
- Requires zero manual steps after launching the template

---

## 2. Architecture Overview

```
Internet
   |
   | HTTP port 80
   v
EC2 Instance (Apache + PHP 8.2)
   |
   | MySQL port 3306 (VPC internal only)
   v
RDS MySQL 8.0 (not publicly accessible from internet)
```

### Resources Created by the Template

| Resource | Type | Purpose |
|---|---|---|
| VPC | AWS::EC2::VPC | Isolated network, 10.0.0.0/16 |
| Internet Gateway | AWS::EC2::InternetGateway | Allows internet traffic |
| PublicSubnet1/2 | AWS::EC2::Subnet | Two AZs for RDS requirement |
| Route Table | AWS::EC2::RouteTable | Routes 0.0.0.0/0 to IGW |
| EC2SecurityGroup | AWS::EC2::SecurityGroup | Allows ports 80, 22, 3389 |
| RDSSecurityGroup | AWS::EC2::SecurityGroup | Allows port 3306 from EC2 SG only |
| EC2InstanceRole | AWS::IAM::Role | Least privilege IAM role |
| EC2InstanceProfile | AWS::IAM::InstanceProfile | Attaches role to EC2 |
| RDSSubnetGroup | AWS::RDS::DBSubnetGroup | RDS needs 2 subnets in 2 AZs |
| RDSInstance | AWS::RDS::DBInstance | MySQL 8.0, db.t3.micro |
| EC2Instance | AWS::EC2::Instance | t3.small, Amazon Linux 2 |
| EC2ElasticIP | AWS::EC2::EIP | Static IP for the web server |
| EC2EIPAssociation | AWS::EC2::EIPAssociation | Attaches EIP to EC2 |

---

## 3. CloudFormation Concepts

### Template Structure
```
AWSTemplateFormatVersion
Description
Parameters      ← inputs you fill in at launch
Mappings        ← lookup tables (AMI IDs per region)
Resources       ← actual AWS resources to create
Outputs         ← values shown after stack creates
```

### Key Functions

| Function | What it does | Example |
|---|---|---|
| !Ref | Reference a parameter or resource | `!Ref DBName` |
| Fn::Sub | String substitution | `"http://${EC2Instance.PublicIp}"` |
| Fn::GetAtt | Get attribute of a resource | `Fn::GetAtt: [RDSInstance, Endpoint.Address]` |
| Fn::FindInMap | Look up value in Mappings | Finds AMI ID for current region |
| Fn::Select | Pick item from list | `Fn::Select: [0, Fn::GetAZs: ...]` |
| Fn::GetAZs | Get list of AZs in region | Returns [us-east-1a, us-east-1b, ...] |
| DependsOn | Force creation order | EC2 waits for RDS to finish |

### CreationPolicy
```json
"CreationPolicy": {
  "ResourceSignal": {
    "Timeout": "PT30M",
    "Count": 1
  }
}
```
- Makes CloudFormation WAIT for a signal from the EC2 instance
- Without this, CF marks CREATE_COMPLETE before UserData finishes
- EC2 sends the signal using `cfn-signal` at the end of UserData
- If signal not received within timeout → stack fails

### DependsOn
```json
"EC2Instance": {
  "DependsOn": ["RDSInstance", "VPCGatewayAttachment"]
}
```
- EC2 won't start until RDS is fully ready
- Prevents EC2 from trying to connect to RDS before it exists

---

## 4. Security Groups — Key Concept

### EC2 Security Group
```
Inbound:
  Port 80  (HTTP)  from 0.0.0.0/0  → anyone can visit the web page
  Port 22  (SSH)   from 0.0.0.0/0  → SSH access
  Port 3389 (RDP)  from 0.0.0.0/0  → CloudLabs Direct Web Connect
```

### RDS Security Group
```
Inbound:
  Port 3306 (MySQL) from EC2SecurityGroup ID ONLY
  → Database is NOT open to the internet
  → Only traffic from EC2 instances in EC2SecurityGroup can reach it
```

**Key point:** `SourceSecurityGroupId` instead of `CidrIp` — this means "only allow traffic from resources that belong to this security group." Much safer than opening port 3306 to 0.0.0.0/0.

---

## 5. IAM Role — Least Privilege

The EC2 instance needs an IAM role to:
1. Send `cfn-signal` to CloudFormation
2. Write logs to CloudWatch

```json
{
  "Statement": [
    {
      "Action": ["cloudformation:SignalResource"],
      "Resource": "arn:aws:cloudformation:REGION:ACCOUNT:stack/STACKNAME/*"
    },
    {
      "Action": ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
      "Resource": "arn:aws:logs:REGION:ACCOUNT:log-group:/webapp/*"
    }
  ]
}
```

**Least privilege** = only give the minimum permissions needed. Never use `*` for actions or resources unless absolutely necessary.

Three pieces needed:
- `AWS::IAM::Role` — the role with permissions
- `AWS::IAM::InstanceProfile` — wraps the role so EC2 can use it
- `IamInstanceProfile` on EC2Instance — attaches the profile

---

## 6. Mappings — AMI IDs by Region

```json
"Mappings": {
  "RegionAMIMap": {
    "us-east-1": { "AMI": "ami-0c02fb55956c7d316" },
    "us-east-2": { "AMI": "ami-0b614a5d911900a9b" }
  }
}
```

Used in EC2Instance:
```json
"ImageId": {
  "Fn::FindInMap": ["RegionAMIMap", {"Ref": "AWS::Region"}, "AMI"]
}
```

**Why:** AMI IDs are different in every AWS region. Hardcoding one ID only works in one region. The mapping makes the template work everywhere.

---

## 7. RDS Configuration — Key Decisions

| Setting | Value | Why |
|---|---|---|
| Engine | MySQL | Assignment requirement |
| EngineVersion | 8.0 | Don't pin exact minor (8.0.45 may not exist in all regions) |
| DBInstanceClass | db.t3.micro | Cheapest option for lab |
| MultiAZ | false | Not needed for lab, saves cost |
| PubliclyAccessible | true | RDS in public subnet — must be true for EC2 to connect |
| BackupRetentionPeriod | 0 | Disables backups, saves cost for lab |
| DeletionPolicy | Delete | Removes RDS when stack is deleted |
| DBSubnetGroup | 2 public subnets | RDS requires minimum 2 subnets in 2 different AZs |

**Important:** `PubliclyAccessible: true` does NOT mean the database is exposed to the internet. The RDS security group still blocks all access except from the EC2 security group. It just means RDS gets a DNS hostname that EC2 can resolve within the VPC.

---

## 8. UserData Script — How It Works

UserData is a script that runs automatically when EC2 first boots. It runs as root. Everything in it is automated — no human interaction needed.

### Our UserData does:
1. Install Apache, PHP 8.2, MySQL client, cfn-bootstrap, xrdp
2. Enable password SSH (so CloudLabs can connect without a key pair)
3. Create the Linux user with password
4. Start and enable Apache
5. Set correct permissions on /var/www/html
6. Write db_config.php with RDS connection details
7. Poll RDS until it's reachable (up to 40 x 20s = ~13 min)
8. Create the `users` table in MySQL
9. Deploy index.php (the web application)
10. Send cfn-signal to CloudFormation

### Signal handler — ensures CF always gets notified:
```bash
EXIT_CODE=0
send_signal() {
  /opt/aws/bin/cfn-signal \
    --exit-code "$EXIT_CODE" \
    --stack    "STACKNAME" \
    --resource EC2Instance \
    --region   "REGION"
}
trap 'EXIT_CODE=$?; send_signal' EXIT
```
The `trap` fires on EXIT no matter what — success or failure. Without this, if any command fails, cfn-signal never runs and the stack hangs for 30 minutes before timing out.

---

## 9. The Fn::Sub Variable Conflict — Most Tricky Part

CloudFormation `Fn::Sub` and bash both use `${...}` syntax. This creates a conflict inside UserData.

**How Fn::Sub two-argument form works:**
```json
"Fn::Sub": [
  "script string with ${VarName}",
  {
    "VarName": {"Fn::GetAtt": ["RDSInstance", "Endpoint.Address"]}
  }
]
```

CF replaces `${VarName}` BEFORE the script runs on the instance.

**The problem:** Single-quoted heredocs (`<<'EOF'`) prevent bash from expanding variables — but they also prevent Fn::Sub from seeing CF variables inside them.

**Our solution:** Assign CF values to shell variables BEFORE the heredocs:
```bash
RDS_HOST="${RDSEndpoint}"   ← CF replaces ${RDSEndpoint} here
DB_NAME="${DBName}"         ← CF replaces ${DBName} here

cat > /var/www/html/db_config.php << PHPEOF
<?php
define('DB_HOST', '$RDS_HOST');   ← bash expands $RDS_HOST here
define('DB_NAME', '$DB_NAME');
?>
PHPEOF
```

**For the PHP page** (`index.php`), use single-quoted `<<'WEBEOF'` so bash does NOT expand `$conn`, `$_POST`, `$result` etc. — those are PHP variables, not bash variables.

**Rule of thumb:**
- CF vars → `${VarName}` — replaced at template deploy time
- Bash vars → `$VARNAME` (no braces) — expanded at script runtime
- PHP vars → need `<<'HEREDOC'` to protect from bash

---

## 10. Common Errors We Hit and Fixed

### Error 1: WaitCondition signal rejected
**Cause:** Used `EC2WaitHandle + EC2WaitCondition` pattern but `cfn-signal` was pointing to `EC2Instance`. These are two different patterns and can't be mixed.

**Fix:** Use `CreationPolicy` on EC2Instance directly. Remove WaitHandle and WaitCondition entirely. `cfn-signal --resource EC2Instance` is correct with CreationPolicy.

### Error 2: Heredoc never closes (YAML only)
**Cause:** In YAML, indentation added spaces before the `EOF` marker. Bash requires `EOF` at column 0.

**Fix:** Switched to JSON — no indentation issue. Or use `<<-EOF` which strips leading tabs (not spaces).

### Error 3: PHP page broken — variables are empty
**Cause:** Using unquoted heredoc `<<WEBEOF` — bash expanded all `$conn`, `$result`, `$_POST` to empty strings.

**Fix:** Single-quoted `<<'WEBEOF'` — bash writes everything literally, PHP sees its own variables correctly.

### Error 4: `for i in '{1..40}'`
**Cause:** Brace expansion `{1..40}` doesn't work inside JSON strings. It ran the loop exactly once with `i` literally equal to `{1..40}`.

**Fix:** Use `$(seq 1 40)` which works correctly in both interactive and non-interactive bash.

### Error 5: RDS never reachable — loop times out
**Cause 1:** RDS was in private subnets with no route table — completely isolated.
**Fix:** Put RDS in public subnets (same as EC2). RDS SG still blocks internet access.

**Cause 2:** `PubliclyAccessible: false` with RDS in a public subnet — AWS blocks VPC-internal connections too.
**Fix:** Set `PubliclyAccessible: true`.

### Error 6: MySQL client not found — `mariadb105`
**Cause:** Package name `mariadb105` doesn't exist in Amazon Linux 2 default repos.

**Fix:** Use `mysql` — this installs the standard MySQL client.

### Error 7: PHP 5.4 installed instead of 8.2
**Cause:** `amazon-linux-extras install php8.2` OOM-killed on t2.micro. Also `yum install php` after `enable` still pulled 5.4 from default repo.

**Fix 1:** Use `t3.small` (2GB RAM) instead of t2.micro.
**Fix 2:** `amazon-linux-extras enable php8.2` then `yum clean metadata` then `yum install -y php php-cli php-mysqlnd`.

### Error 8: PHP 500 error — `??` operator
**Cause:** PHP 5.4 doesn't support the null coalescing operator `??`. It requires PHP 7+.

**Fix:** Use `isset($_POST['name']) ? $_POST['name'] : ''` for PHP 5.4 compatibility. Or upgrade to PHP 8.2 (which we did).

### Error 9: charset error — `Server sent charset unknown to client`
**Cause:** MySQL 8.0 uses `utf8mb4` by default. PHP's old mysqli didn't recognize it.

**Fix:** Call `$conn->set_charset('utf8mb4')` right after connecting.

### Error 10: RDS identifier validation failed
**Cause:** Used stack ID fragment as identifier — it started with a number (`9ed615e0`). RDS requires identifier to start with a letter.

**Fix:** Hardcode `webapp-rds-mysql` — simple, always valid.

### Error 11: Em dash `—` in template
**Cause:** Unicode em dash (`—`) in GroupDescription fields — some CloudFormation parsers reject non-ASCII in certain string fields.

**Fix:** Replace all `—` with plain hyphen `-`.

### Error 12: `${!VAR}` escapes breaking template
**Cause:** Using `${!VAR}` to escape bash variables from Fn::Sub — CloudFormation's parser gets confused by these inside function bodies.

**Fix:** Don't use `${!VAR}`. Use plain `$VAR` (no braces) for bash variables — CF only substitutes `${...}` with braces, so braces-free bash vars are safe.

---

## 11. Networking — How Everything Connects

```
VPC 10.0.0.0/16
├── PublicSubnet1 10.0.1.0/24  (AZ 1)
│   └── EC2 Instance ──────────── Elastic IP (static public IP)
│   └── RDS Instance (PubliclyAccessible:true, but SG blocks internet)
├── PublicSubnet2 10.0.2.0/24  (AZ 2)
│   └── RDS Subnet Group (requires 2 AZs)
├── Internet Gateway
│   └── Attached to VPC
└── Route Table
    ├── 10.0.0.0/16 → local (VPC internal traffic)
    └── 0.0.0.0/0  → Internet Gateway (internet traffic)
```

**Why two subnets for RDS?** AWS requires RDS subnet groups to span at least 2 Availability Zones for high availability, even when MultiAZ is false.

**Why Elastic IP?** EC2 public IPs change on every stop/start. EIP is static — the URL in the lab guide stays the same.

---

## 12. PHP Application — How It Works

### db_config.php
```php
define('DB_HOST', 'webapp-rds-xxx.rds.amazonaws.com');
define('DB_NAME', 'webappdb');
define('DB_USER', 'dbadmin');
define('DB_PASS', 'YourPassword');
```
Written by UserData with real values injected by Fn::Sub.

### index.php — Request Flow
```
GET /index.php
  → Connect to RDS
  → SELECT all records
  → Display form + table

POST /index.php (action=insert)
  → Insert new record
  → Redirect to GET (PRG pattern)

POST /index.php (action=delete)
  → DELETE record by ID
  → Redirect to GET
```

### PRG Pattern (Post-Redirect-Get)
After every POST, we redirect with `header('Location: /index.php')`. This prevents double-submission if user refreshes the page.

### SQL Injection Prevention
- String inputs: `$conn->real_escape_string()` escapes dangerous characters
- Integer ID for delete: `(int)$_POST['id']` casts to integer — no string injection possible

---

## 13. CloudLabs-Specific Features

### CloudLabsDeploymentID Parameter
- CloudLabs injects a unique ID for each lab deployment
- Used in resource names/tags so multiple deployments don't conflict
- Pattern restricted to `[a-z0-9-]*` (lowercase only)

### CheckAcknowledgement Parameter
- CloudLabs uses this to acknowledge `CAPABILITY_NAMED_IAM`
- Required because the template creates IAM resources with custom names

### No Key Pair
- Traditional EC2 access requires a `.pem` key file
- CloudLabs uses Direct Web Connect (browser-based RDP/SSH)
- We enable password SSH: `PasswordAuthentication yes` in `/etc/ssh/sshd_config`
- Users log in with `LinuxUsername` and `LinuxPassword` parameters

### RDP via CloudLabs Direct Web Connect
- xrdp installed on EC2 — listens on port 3389
- Port 3389 opened in EC2 Security Group
- In CloudLabs portal: enable Direct Web Connect → RDP connection type
- CloudLabs proxies the RDP session through the browser

### Elastic IP for Stable URL
- `EC2ElasticIP` + `EC2EIPAssociation` resources
- EIP is created separately from EC2, then associated after EC2 is ready
- `DependsOn: EC2Instance` on the association ensures correct order
- Output `WebAppURL` = `http://<ElasticIP>`

---

## 14. Billing — What Costs Money

| Resource | Billing State | Notes |
|---|---|---|
| EC2 Running | YES | Per hour compute |
| EC2 Stopped | NO (deallocated) | Must be deallocated, not just stopped |
| EC2 Stopped (allocated) | YES | Still charged for compute |
| RDS Running | YES | Per hour |
| RDS Stopped | YES (storage) | Still charged for storage |
| Elastic IP (unattached) | YES | Charged when not associated to running instance |
| Elastic IP (attached) | NO | Free when attached to running instance |
| Data transfer in | NO | Inbound always free |
| Data transfer out | YES | Outbound charged after free tier |

**Cost optimization tools used:**
- `BackupRetentionPeriod: 0` — disables RDS backups
- `MultiAZ: false` — single AZ, half the cost
- `DeletionPolicy: Delete` — RDS cleaned up when stack deleted
- `t3.small` instead of larger types

---

## 15. Deployment Checklist

Before launching the stack:
1. Go to EC2 → Key Pairs — NOT needed (we use password SSH)
2. Know your AWS region — template has AMI IDs for 12 regions
3. Choose a strong password for DB and Linux (no `@`, `#`, `$`)
4. Have the CloudLabs Deployment ID ready (or leave as `labdeploy`)

During deployment:
1. Upload `template_final.json` to CloudFormation
2. Fill in parameters (DBPassword, LinuxUsername, LinuxPassword)
3. Acknowledge CAPABILITY_NAMED_IAM
4. Wait 15–20 minutes (RDS takes ~10 min, then EC2 UserData ~5 min)
5. Stack status: `CREATE_IN_PROGRESS` → `CREATE_COMPLETE`

After deployment:
1. Go to Outputs tab
2. Copy `WebAppURL` → open in browser with `http://` not `https://`
3. Submit a Name and Address → verify it appears in the table
4. Click Delete → verify record is removed
5. For RDP: use CloudLabs Direct Web Connect with LinuxUsername/LinuxPassword

Troubleshooting:
```bash
# Connect via EC2 Instance Connect → run:
cat /var/log/userdata.log        # full UserData execution log
ls -la /var/www/html/            # verify files were created
curl http://localhost             # test Apache locally
systemctl status httpd            # Apache status
systemctl status xrdp             # xRDP status
cat /var/www/html/db_config.php  # verify RDS endpoint is filled in
```

---

## 16. Quick Reference — Template Parameters

| Parameter | Default | Notes |
|---|---|---|
| CloudLabsDeploymentID | labdeploy | Injected by CloudLabs automatically |
| CheckAcknowledgement | FALSE | Set TRUE for IAM acknowledgement |
| DBName | webappdb | MySQL database name |
| DBUsername | dbadmin | RDS master username |
| DBPassword | (required) | Min 8 chars, no @ # $ |
| InstanceType | t3.small | Use t3.small minimum |
| LinuxUsername | labuser | OS username for SSH/RDP |
| LinuxPassword | (required) | Min 8 chars, no @ # $ |

---

## 17. Key Takeaways

1. **CloudFormation creates resources in dependency order** — you don't specify the order, CF figures it out from `Ref` and `DependsOn`

2. **Fn::Sub runs before the script** — by the time bash executes UserData, all `${CF_VARS}` are already replaced with real values

3. **Single-quoted heredocs protect PHP from bash** — `<<'EOF'` writes everything literally, crucial for PHP files

4. **RDS needs 2 subnets in 2 AZs** — even with MultiAZ=false, the subnet group requirement doesn't go away

5. **PubliclyAccessible controls DNS, not security** — the security group is what actually controls who can connect

6. **cfn-signal must always fire** — use `trap 'EXIT_CODE=$?; send_signal' EXIT` so CF always knows if setup succeeded or failed

7. **Use seq instead of brace expansion** — `$(seq 1 40)` works in non-interactive bash; `{1..40}` does not

8. **t2.micro is too small for PHP 8.2 installation** — use t3.small (2GB RAM) for reliable deployments