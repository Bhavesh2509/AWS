# Amazon ECR – Docker Image Repository

## Overview

This project demonstrates building a Docker application and pushing the container image to Amazon Elastic Container Registry (ECR).
The repository is then used by ECS and EKS to deploy the application.

---

# Architecture

Local Machine / EC2
↓
Docker Build
↓
Amazon ECR Repository
↓
Used by ECS / EKS

---

# Step 1 – Create ECR Repository

1. Open AWS Console
2. Navigate to **ECR**
3. Click **Create repository**

Configuration

Repository name:

```
ecs-app
```

Visibility

```
Private
```

Click **Create repository**

---

# Step 2 – Authenticate Docker to ECR

Run the following command on the EC2 instance:

```
aws ecr get-login-password --region us-east-1 \
| docker login --username AWS \
--password-stdin 836763845852.dkr.ecr.us-east-1.amazonaws.com
```

---

# Step 3 – Build Docker Image

Navigate to the application folder.

```
docker build -t ecs-app .
```

---

# Step 4 – Tag Docker Image

```
docker tag ecs-app:latest \
836763845852.dkr.ecr.us-east-1.amazonaws.com/ecs-app:latest
```

---

# Step 5 – Push Image to ECR

```
docker push 836763845852.dkr.ecr.us-east-1.amazonaws.com/ecs-app:latest
```

---

# Verify Image

Open AWS Console

ECR → Repositories → ecs-app

The pushed image should appear.

---

# Troubleshooting

## Repository does not exist

Error

```
name unknown: The repository with name 'app' does not exist
```

Cause

Wrong repository name.

Solution

Check repository name and push again.

```
docker tag ecs-app:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/ecs-app:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/ecs-app:latest
```

---

## Docker Permission Denied

Error

```
permission denied while trying to connect to the Docker daemon socket
```

Solution

Run command using sudo or add user to docker group.

```
sudo docker push <image>
```

or

```
sudo usermod -aG docker ec2-user
```

---

# Result

Docker image successfully stored in Amazon ECR and ready to be used by ECS and EKS.
