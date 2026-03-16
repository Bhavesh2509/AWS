# Amazon ECS – Container Deployment

## Overview

This project deploys a Docker container stored in Amazon ECR using Amazon Elastic Container Service (ECS).

The service is exposed using an Application Load Balancer.

---

# Architecture

User
↓
Load Balancer
↓
ECS Service
↓
ECS Task
↓
Container from ECR

---

# Step 1 – Create ECS Cluster

Go to AWS Console

ECS → Clusters → Create Cluster

Cluster name

```
ecs-app-cluster
```

Launch type

```
EC2
```

---

# Step 2 – Create Task Definition

ECS → Task Definitions → Create

Configuration

Launch type

```
EC2
```

Container image

```
836763845852.dkr.ecr.us-east-1.amazonaws.com/ecs-app:latest
```

Container port

```
5000
```

Memory

```
512 MB
```

CPU

```
256
```

---

# Step 3 – Create Service

ECS → Cluster → Create Service

Configuration

Launch type

```
EC2
```

Task definition

```
ecs-app
```

Desired tasks

```
2
```

---

# Step 4 – Configure Load Balancer

Select

```
Application Load Balancer
```

Listener

```
HTTP : 80
```

Target Group

```
ecs-app-tg
```

---

# Step 5 – Access Application

After deployment, copy the Load Balancer DNS.

Example

```
http://ecs-app-lb-123456.us-east-1.elb.amazonaws.com
```

---

# Troubleshooting

## Target Group shows 0 healthy targets

Possible causes

• Security group blocking traffic
• Container port mismatch
• Health check path incorrect

Solution

Ensure:

```
Container port = 5000
Health check path = /
```

---

## 503 Service Temporarily Unavailable

Cause

Load balancer cannot reach container.

Fix

Verify

```
Security Group
Port mapping
Target group health check
```

---

## Private EC2 Instances

ECS instances do not require public IP if traffic comes through the load balancer.

---

# Result

Application deployed successfully using Amazon ECS with load balancer.
