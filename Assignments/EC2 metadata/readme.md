# EC2 Monitoring Dashboard (Docker + Flask)

A **self-deploying EC2 monitoring dashboard** that runs inside a Docker container and displays:

* EC2 Instance Metadata
* CPU Usage
* Memory Usage
* Disk Usage
* Network Traffic
* Docker Container Metrics
* Instance Uptime
* Live graphs with Chart.js

The entire application **auto-deploys using EC2 UserData** when the instance launches.

---

# Architecture

```
EC2 Instance
   │
   ├── UserData Script
   │      ├── Install Docker
   │      ├── Create Flask App
   │      ├── Create HTML Dashboard
   │      ├── Build Docker Image
   │      └── Run Container
   │
   └── Docker Container
           └── Flask Monitoring App
                   ├── Metrics API
                   ├── Metadata API
                   └── Web Dashboard
```

---

# Technologies Used

| Component | Purpose                   |
| --------- | ------------------------- |
| AWS EC2   | Compute instance          |
| Docker    | Container runtime         |
| Flask     | Python web framework      |
| psutil    | System metrics collection |
| requests  | Metadata API calls        |
| Chart.js  | Live graphs on dashboard  |

Graphs are rendered using **Chart.js**.

---

# Features

## 1. EC2 Metadata

Fetched using the **Instance Metadata Service (IMDSv2)**.

Displayed fields:

* Instance ID
* Instance Type
* Availability Zone
* Private IP

Metadata endpoint used:

```
http://169.254.169.254/latest/meta-data/
```

---

## 2. System Metrics

Collected using **psutil**.

| Metric          | Source                   |
| --------------- | ------------------------ |
| CPU usage       | psutil.cpu_percent()     |
| Memory usage    | psutil.virtual_memory()  |
| Disk usage      | psutil.disk_usage()      |
| Network traffic | psutil.net_io_counters() |

Graphs update every **2 seconds**.

---

## 3. Docker Metrics

Collected using:

```
docker stats --no-stream
```

Displayed format:

```
container-name | CPU 0.3% | MEM 40MiB
```

---

## 4. Instance Uptime

Calculated using Python:

```
start_time = time.time()
uptime = current_time - start_time
```

Displayed in:

```
hours : minutes : seconds
```

---

# Deployment (Using EC2 UserData)

## Step 1 — Launch EC2

Recommended instance types:

```
t2.micro
t3.micro
```

OS:

```
Amazon Linux
```

---

## Step 2 — Security Group

Allow the following ports:

| Port | Purpose |
| ---- | ------- |
| 22   | SSH     |
| 80   | HTTP    |

---

## Step 3 — Paste UserData Script

During instance launch:

```
Advanced Details → UserData
```

Paste the provided script.

The script performs the following automatically:

1. Update system packages
2. Install Docker
3. Enable Docker service
4. Create monitoring application files
5. Build Docker image
6. Run container

---

# Access the Dashboard

After the instance starts:

```
http://EC2-PUBLIC-IP
```

Dashboard shows:

* Metadata
* Uptime
* Docker stats
* CPU graph
* Memory graph
* Disk graph
* Network graph

---

# Stress Testing the Dashboard

To test monitoring graphs you can generate system load.

Install the stress tool:

```
sudo yum install stress-ng -y
```

CPU stress:

```
stress-ng --cpu 4 --timeout 120s
```

Memory stress:

```
stress-ng --vm 2 --vm-bytes 512M --timeout 120s
```

Disk stress:

```
stress-ng --hdd 2 --timeout 120s
```

Graphs should spike during the test.

---

# HTTP Traffic Stress Test

You can simulate traffic using **ApacheBench**.

Install tool:

```
sudo yum install httpd-tools -y
```

Run test:

```
ab -n 10000 -c 100 http://EC2-PUBLIC-IP/
```

Meaning:

| Parameter | Description      |
| --------- | ---------------- |
| -n        | total requests   |
| -c        | concurrent users |

This generates network traffic and CPU load.

---

# Updating the Application Inside the VM

UserData scripts run **only once during instance launch**.

To modify the application later:

SSH into EC2:

```
ssh ec2-user@EC2-PUBLIC-IP
```

Navigate to project folder:

```
cd /dashboard
```

Edit application:

```
nano app.py
```

Rebuild container:

```
docker stop $(docker ps -q)

docker rm $(docker ps -aq)

docker build -t ec2-monitor .

docker run -d -p 80:80 --restart=always ec2-monitor
```

---

# Restarting the Container

```
docker restart $(docker ps -q)
```

---

# Project Directory Structure

```
/dashboard
│
├── app.py
├── Dockerfile
├── requirements.txt
└── templates
        └── index.html
```

---

# Troubleshooting

## Dashboard Not Opening

Check if container is running:

```
docker ps
```

If not running:

```
docker logs <container-id>
```

---

## Port 80 Not Accessible

Verify security group rules:

```
Inbound → Allow HTTP (80)
```

---

## Docker Not Running

Check service:

```
systemctl status docker
```

Start Docker:

```
sudo systemctl start docker
```

---

## Metadata Not Visible

Verify IMDS access:

```
curl http://169.254.169.254/latest/meta-data/instance-id
```

If IMDSv2 is required, fetch token:

```
TOKEN=$(curl -X PUT http://169.254.169.254/latest/api/token \
-H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

curl -H "X-aws-ec2-metadata-token: $TOKEN" \
http://169.254.169.254/latest/meta-data/instance-id
```

---

## Metrics Not Updating

Check Flask logs:

```
docker logs ec2-monitor
```

---

## Container Restart Issues

Verify restart policy:

```
docker inspect ec2-monitor
```

Look for:

```
"RestartPolicy": "always"
```

---

# Useful Commands

Check containers:

```
docker ps
```

Stop container:

```
docker stop <container-id>
```

Remove container:

```
docker rm <container-id>
```

Rebuild image:

```
docker build -t ec2-monitor .
```

Run container:

```
docker run -d -p 80:80 --restart=always ec2-monitor
```

---

# What This Project Demonstrates

| Skill                  | Technology   |
| ---------------------- | ------------ |
| AWS Automation         | EC2 UserData |
| Containerization       | Docker       |
| Backend API            | Flask        |
| Monitoring             | psutil       |
| Cloud Metadata         | IMDSv2       |
| Frontend Visualization | Chart.js     |

This project resembles simplified versions of:

* **Amazon CloudWatch**
* **Grafana**

but runs entirely inside a single EC2 container.

---

# Possible Improvements

Future enhancements could include:

* Prometheus metrics exporter
* Grafana dashboards
* Multi-instance monitoring
* Load balancer integration
* Terraform infrastructure deployment
* WebSocket real-time updates
