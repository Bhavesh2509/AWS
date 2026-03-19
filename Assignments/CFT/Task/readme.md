# AWS Three-Tier Web Application — CloudFormation Nested Stacks

A fully automated, production-ready web application infrastructure on AWS using CloudFormation nested stacks. The architecture provisions a VPC, Application Load Balancer, Auto Scaling EC2 instances running nginx, and an S3 bucket for static assets and log shipping.

---

## Architecture Overview

```
Internet
    │
    ▼
[Application Load Balancer]  ← public subnets (us-east-1a, us-east-1b)
    │
    ▼
[Auto Scaling Group]         ← private subnets (us-east-1a, us-east-1b)
  EC2 (nginx)  EC2 (nginx)
    │
    ▼
[S3 Bucket]                  ← static assets + nginx log shipping
```

---

## Repository Structure

```
.
├── Parent.yaml       # Root stack — orchestrates all nested stacks
├── Network.yaml      # VPC, subnets, IGW, NAT, route tables
├── ALB.yaml          # Application Load Balancer, Target Group, Listener
├── S3.yaml           # S3 bucket + Lambda custom resource to seed index.html
├── Compute.yaml      # IAM role, Launch Template, Auto Scaling Group
└── README.md
```

---

## Prerequisites

- AWS CLI installed and configured (`aws configure`)
- An existing S3 bucket to host the CloudFormation templates (the **template bucket** — separate from the app bucket)
- IAM permissions for: CloudFormation, EC2, ELB, S3, IAM, Lambda, Auto Scaling

---

## Deployment Steps

### Step 1 — Upload templates to your S3 template bucket

```bash
TEMPLATE_BUCKET=your-template-bucket-name

aws s3 cp Network.yaml  s3://$TEMPLATE_BUCKET/Network.yaml
aws s3 cp ALB.yaml      s3://$TEMPLATE_BUCKET/ALB.yaml
aws s3 cp S3.yaml       s3://$TEMPLATE_BUCKET/S3.yaml
aws s3 cp Compute.yaml  s3://$TEMPLATE_BUCKET/Compute.yaml
aws s3 cp Parent.yaml   s3://$TEMPLATE_BUCKET/Parent.yaml
```

> ⚠️ All 5 files must be in the same bucket and at the root prefix. The Parent stack references them as `https://<bucket>.s3.amazonaws.com/<file>.yaml`.

### Step 2 — Deploy the Parent stack via Console

1. Go to **CloudFormation → Create stack → With new resources**
2. Choose **Upload a template file** → select `Parent.yaml`
3. Stack name: `parentstack` (or any name you like)
4. Parameter — `TemplateBucket`: enter your template bucket name (just the name, not the URL)
5. Click through → acknowledge IAM capabilities → **Create stack**

### Step 2 (alternative) — Deploy via CLI

```bash
aws cloudformation create-stack \
  --stack-name parentstack \
  --template-url https://$TEMPLATE_BUCKET.s3.amazonaws.com/Parent.yaml \
  --parameters ParameterKey=TemplateBucket,ParameterValue=$TEMPLATE_BUCKET \
  --capabilities CAPABILITY_IAM \
  --region us-east-1
```

### Step 3 — Monitor deployment

In the Console go to **CloudFormation → Stacks**. You will see the parent stack and 4 nested stacks appear. Full deployment takes approximately 5–8 minutes due to NAT Gateway and EC2 provisioning.

Deployment order (enforced by DependsOn):
```
NetworkStack → S3Stack → ALBStack → ComputeStack
```

### Step 4 — Get the app URL

Once the parent stack shows `CREATE_COMPLETE`, go to:

**CloudFormation → parentstack → Outputs tab → AppURL**

Open that URL in your browser. You should see the nginx page served from S3.

---

## Template Deep Dive

### Network.yaml

**Purpose:** Provisions the entire network layer — VPC, subnets, internet gateway, NAT gateway, and route tables.

**Resources:**

`VPC` — Creates an isolated network with CIDR `10.0.0.0/16` giving 65,536 IP addresses. `EnableDnsSupport` and `EnableDnsHostnames` are both set to `true` — required for SSM Session Manager to resolve AWS service endpoints from within the VPC.

`IGW` + `Attach` — The Internet Gateway is the entry/exit point for internet traffic. It has no state itself; the `Attach` resource binds it to the VPC. The `PublicRoute` has `DependsOn: Attach` because you cannot create a route pointing to an IGW that isn't attached yet.

`PublicSubnet1/2` — Two subnets in separate AZs (`us-east-1a`, `us-east-1b`). `MapPublicIpOnLaunch: true` means any resource launched here automatically gets a public IP. This is required for the ALB to be internet-facing.

`PrivateSubnet1/2` — Two subnets with no direct internet access. EC2 instances live here. They reach the internet only through the NAT Gateway for outbound calls (yum installs, S3 access, SSM).

`EIP` + `NAT` — The Elastic IP is a static public IP address. The NAT Gateway uses it to masquerade outbound traffic from private subnets. NAT is placed in `PublicSubnet1` (must be in a public subnet). `DependsOn: NAT` is added to `PrivateRoute` to prevent CloudFormation from creating the route before the NAT is ready.

`PublicRT` / `PrivateRT` — Separate route tables for public and private subnets. Public route table sends `0.0.0.0/0` to the IGW. Private route table sends `0.0.0.0/0` to the NAT Gateway.

`SubnetRouteTableAssociation` (×4) — Associates each subnet with the correct route table. Without these, subnets use the VPC's default route table which has no internet route.

**Outputs:** `VpcId`, `PublicSubnet1`, `PublicSubnet2` (separate, not joined), `PrivateSubnets` (comma-joined for the ASG `VPCZoneIdentifier`).

> Why are public subnets output separately? The ALB `Subnets` property requires a YAML list. Passing a comma-joined string and using `!Split` in the ALB template is fragile — CloudFormation occasionally misparses it. Passing them as two discrete parameters and referencing them directly as a list is reliable.

---

### ALB.yaml

**Purpose:** Provisions the internet-facing Application Load Balancer, the Target Group that tracks EC2 health, and the Listener that routes HTTP traffic.

**Parameters:** `VpcId`, `PublicSubnet1`, `PublicSubnet2` (two separate subnet IDs), plus health check tuning parameters with sensible defaults.

**Resources:**

`ALBSG` — Security group allowing inbound TCP port 80 from `0.0.0.0/0` (the internet). This is intentionally open — the ALB is the only public entry point. EC2 instances only accept traffic from this security group, not from the internet directly.

`ALB` — The load balancer itself. `Scheme: internet-facing` places it in public subnets with a public DNS name. `Subnets` lists both public subnets directly as a YAML list (no `!Split`). No `Name` property — hardcoded names cause `AlreadyExists` errors if the stack is ever redeployed after a failed teardown.

`TargetGroup` — Defines how the ALB checks instance health and routes traffic. `TargetType: instance` means it routes to EC2 instance IDs. The health check hits `/health` every 30 seconds — an instance must return HTTP 200-299 three consecutive times to become healthy, and three failures to become unhealthy. No `Name` property for the same reason as the ALB.

`Listener` — Binds port 80 on the ALB to the Target Group. Any HTTP request hitting the ALB on port 80 is forwarded to a healthy instance in the Target Group.

**Outputs:** `TargetGroupArn` (passed to Compute stack), `ALBSG` (passed to Compute stack so EC2 SG can reference it), `ALBDNS` (passed to Parent stack Outputs as the app URL).

---

### S3.yaml

**Purpose:** Creates the S3 bucket used for static assets and log shipping, and seeds it with an `index.html` file using a Lambda-backed CloudFormation Custom Resource.

**Resources:**

`AppBucket` — A plain S3 bucket with no hardcoded name (CloudFormation generates one). No public access — EC2 instances read from it using IAM role permissions, not public URLs.

`Role` — IAM role for the Lambda function. Has two policies:
- `AWSLambdaBasicExecutionRole` (managed) — grants permission to write CloudWatch Logs. Without this, Lambda failures are completely silent and CloudFormation hangs until timeout with no error message.
- `S3Write` (inline) — grants `s3:PutObject` on the bucket so the Lambda can upload `index.html`.

`Func` — A Python 3.9 Lambda function with its code inline in the template (`ZipFile`). It reads the bucket name from the Custom Resource properties, uploads a minimal HTML file, and calls `cfnresponse.send` to signal SUCCESS or FAILED back to CloudFormation. The `cfnresponse` module is built into the Lambda runtime — no extra packaging needed.

`Upload` — A `Custom::Upload` resource that triggers the Lambda during stack creation. CloudFormation passes the resource properties to the Lambda as the `event` object. `DependsOn: Role` ensures the IAM role is fully attached before the Lambda tries to run.

**Outputs:** `BucketName` — passed to the Compute stack so EC2 instances know which bucket to pull from and ship logs to.

---

### Compute.yaml

**Purpose:** Provisions the EC2 IAM role, Launch Template, and Auto Scaling Group that runs the nginx application tier.

**Parameters:** `VpcId`, `PrivateSubnets`, `TargetGroupArn`, `BucketName`, `ALBSG`.

**Resources:**

`InstanceSG` — Security group for EC2 instances. Critically, the inbound rule uses `SourceSecurityGroupId: !Ref ALBSG` rather than a CIDR range. This means only traffic originating from the ALB security group is allowed on port 80 — not from the internet, not from other EC2 instances, only from the ALB itself.

`Role` — EC2 IAM role with two policies:
- `AmazonSSMManagedInstanceCore` (managed) — enables SSM Session Manager so you can shell into instances without SSH or a bastion host.
- `S3Access` (inline) — grants `s3:GetObject` on the whole bucket (to pull `index.html`) and `s3:PutObject` scoped specifically to `logs/*` (to ship nginx logs). The least-privilege scope means a compromised instance cannot overwrite `index.html`.

`Profile` — An Instance Profile wraps the IAM role so EC2 can assume it. EC2 cannot directly use an IAM Role — it needs the Instance Profile wrapper.

`LT` — The Launch Template defines everything about how instances start:

- `ImageId` uses `{{resolve:ssm:...}}` — a CloudFormation dynamic reference that fetches the latest Amazon Linux 2 AMI ID from AWS SSM Parameter Store at deploy time. This must be a plain string — wrapping it in `!Sub` causes a parse error because CloudFormation's `!Sub` and the `{{}}` syntax conflict.

- `UserData` runs at first boot. Key points:
  - `amazon-linux-extras install nginx1 -y` — nginx is not in the base yum repository on Amazon Linux 2. It must be installed from the Extras library. Using `yum install nginx` silently does nothing.
  - The health file (`echo OK > /usr/share/nginx/html/health`) is written **before** the S3 copy. This ensures ALB health checks pass even if the S3 copy is slow or fails.
  - The S3 copy uses `||` fallback so a failure doesn't abort the entire boot script.
  - `\$(hostname)` — the backslash escapes the `$` from CloudFormation's `!Sub` processor. Without it, CloudFormation tries to resolve `hostname` as a template parameter and fails at deploy time. At runtime on the instance, `\$` becomes `$` and bash executes `$(hostname)` normally.

`ASG` — The Auto Scaling Group maintains 2–4 instances across the two private subnets. `HealthCheckType: ELB` means the ASG respects the ALB's health check results — if the ALB marks an instance unhealthy, the ASG terminates and replaces it. `HealthCheckGracePeriod: 300` gives instances 5 minutes before health checks start — necessary because `yum update` + `amazon-linux-extras` + nginx startup on a cold instance takes 2–3 minutes.

---

### Parent.yaml

**Purpose:** The orchestrator. Deploys all nested stacks in the correct order and wires their outputs together as inputs.

**Parameter:** `TemplateBucket` — the S3 bucket where the nested template files are hosted.

**Stack deployment order:**

```
NetworkStack ──┐
               ├──► ALBStack ──► ComputeStack
S3Stack ───────┘
```

`NetworkStack` and `S3Stack` have no dependencies and deploy in parallel. `ALBStack` has `DependsOn: NetworkStack` because it needs subnet IDs. `ComputeStack` has `DependsOn: ALBStack` because it needs the Target Group ARN and ALB Security Group ID.

**Cross-stack wiring:**

| Parameter passed to | Value comes from |
|---|---|
| `ALBStack.VpcId` | `NetworkStack.Outputs.VpcId` |
| `ALBStack.PublicSubnet1` | `NetworkStack.Outputs.PublicSubnet1` |
| `ALBStack.PublicSubnet2` | `NetworkStack.Outputs.PublicSubnet2` |
| `ComputeStack.VpcId` | `NetworkStack.Outputs.VpcId` |
| `ComputeStack.PrivateSubnets` | `NetworkStack.Outputs.PrivateSubnets` |
| `ComputeStack.TargetGroupArn` | `ALBStack.Outputs.TargetGroupArn` |
| `ComputeStack.BucketName` | `S3Stack.Outputs.BucketName` |
| `ComputeStack.ALBSG` | `ALBStack.Outputs.ALBSG` |

**Output:** `AppURL` — the full HTTP URL of the ALB DNS name, shown in the stack Outputs tab after deployment.

---

## Troubleshooting Guide

### ALB / TargetGroup failed to create

**Symptom:** `The following resource(s) failed to create: [ALB, TargetGroup]`

**Causes and fixes:**
- **Hardcoded Name conflict** — if you previously deployed and deleted the stack but the ALB name `app-alb` still exists, CloudFormation cannot create it again. Fix: remove `Name` from the ALB and TargetGroup (already done in these templates).
- **Subnet issue** — the ALB requires subnets in at least 2 different AZs passed as a proper list. Using `!Split` on a comma-joined string is unreliable. Fix: pass `PublicSubnet1` and `PublicSubnet2` as separate parameters (already done).
- **Check the exact error:** CloudFormation → ALBStack → Events tab → `CREATE_FAILED` row → Status reason.

---

### Instances are Unhealthy in Target Group

**Symptom:** EC2 → Target Groups → app-tg → Targets shows all instances as `unhealthy`.

**Diagnosis steps:**
1. Go to **EC2 → Instances → select instance → Actions → Monitor and troubleshoot → Get system log**
2. Look for errors around `nginx` or `aws s3 cp`
3. Check **EC2 → Target Groups → app-tg → Targets** — click an instance for the specific health check failure reason

**Common causes:**

| Symptom | Cause | Fix |
|---|---|---|
| `No package nginx available` in system log | Used `yum install nginx` on Amazon Linux 2 | Use `amazon-linux-extras install nginx1 -y` |
| `Failed to start nginx.service: Unit not found` | nginx was never installed | Same as above |
| Health check returns 404 | `/health` file not created | Ensure `echo OK > /health` runs before S3 copy |
| `Connection refused` | nginx not running | Check system log for startup errors |
| Instances not listed in target group at all | ASG failed to launch | Check ASG Activity tab for launch errors |

---

### 502 Bad Gateway

**Symptom:** ALB URL returns 502.

**Meaning:** The ALB is running but cannot reach any healthy backend instance.

**Steps:**
1. Check Target Group — are any instances `healthy`? If all are `unhealthy`, see section above.
2. Check instance security group — inbound rule on port 80 must reference the ALB security group ID, not `0.0.0.0/0`.
3. Check instances are in **private** subnets — if they ended up in public subnets the routing is misconfigured.
4. Wait — instances need up to 5 minutes to boot, install packages, and pass the 3 consecutive health checks before becoming healthy.

---

### S3 Custom Resource Upload failed

**Symptom:** CloudFormation → S3Stack → Events shows `CREATE_FAILED` on the `Upload` resource.

**Causes:**
- Lambda has no CloudWatch Logs permissions — the failure is silent and CloudFormation times out. Fix: add `AWSLambdaBasicExecutionRole` managed policy to the Lambda IAM Role (already done).
- Check **CloudWatch → Log Groups → /aws/lambda/\<function-name\>** for the actual Python exception.

---

### UserData script errors

**Symptom:** nginx not running, health file missing, S3 copy didn't happen.

**How to check without SSH:**
- EC2 → Instances → select instance → **Actions → Monitor and troubleshoot → Get system log**
- Scroll to the bottom — cloud-init output is at the end
- Look for lines containing `error`, `failed`, or `No package`

---

### Stack stuck in UPDATE_ROLLBACK or DELETE_FAILED

**Cause:** Usually a resource that can't be deleted (non-empty S3 bucket, ENI still attached to NAT).

**Fix:**
1. Manually empty the S3 app bucket: S3 → bucket → Empty
2. For stuck ENIs: EC2 → Network Interfaces → detach/delete manually
3. Retry the CloudFormation delete

---

### Redeployment fails with "already exists"

**Cause:** Previous stack didn't fully clean up, or resources had hardcoded names.

**Fix:**
- These templates have no hardcoded `Name` on ALB or TargetGroup — CloudFormation generates unique names
- If you hardcoded names in a previous version, manually delete the lingering resources in the console before redeploying

---

## Key Design Decisions

**Why nested stacks?** Each stack manages its own lifecycle. You can update the Compute stack (e.g. change instance type) without touching networking. Stacks can be developed and tested independently.

**Why are EC2 instances in private subnets?** Instances have no public IPs and are unreachable from the internet. All inbound traffic must pass through the ALB. This is standard security practice for application tiers.

**Why NAT Gateway instead of NAT Instance?** NAT Gateway is managed by AWS — no patching, no single point of failure, scales automatically. NAT Instances are cheaper but require manual management.

**Why SSM instead of SSH?** No key pairs, no bastion host, no open port 22. SSM Session Manager provides shell access through the AWS console and CLI using IAM permissions only.

**Why ship logs to S3?** EC2 instances in an ASG are ephemeral — they can be terminated at any time. Shipping logs to S3 every minute ensures logs are preserved even after instance termination.