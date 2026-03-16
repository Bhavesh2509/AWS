# Amazon EKS – Kubernetes Deployment

## Overview

This project deploys a containerized application stored in Amazon ECR using Amazon Elastic Kubernetes Service (EKS).
The application is exposed through a Kubernetes LoadBalancer service.

---

# Architecture

User
↓
AWS Load Balancer
↓
Kubernetes Service
↓
EKS Pods
↓
Container from ECR

---

# Step 1 – Launch EC2 Instance for Cluster Management

An EC2 instance was used to create and manage the Kubernetes cluster.

Instance configuration

Instance type

```
t3.medium
```

OS

```
Amazon Linux
```

This instance acts as the **cluster management node** where `kubectl`, `aws-cli`, and `eksctl` are installed.

---

# Step 2 – Attach IAM Role to EC2 Instance

The EC2 instance requires permissions to interact with AWS services during cluster creation.

Steps:

1. Go to AWS Console
2. Navigate to **IAM → Roles**
3. Create a new role
4. Attach it to the EC2 instance used for cluster creation

Custom policy attached:

```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"eks:*",
				"ec2:*",
				"iam:*",
				"cloudformation:*",
				"autoscaling:*",
				"elasticloadbalancing:*",
				"ecr:*",
				"logs:*"
			],
			"Resource": "*"
		}
	]
}
```

This policy allowed the EC2 instance to:

• Create the EKS cluster
• Create worker nodes
• Manage networking resources
• Pull images from ECR
• Create load balancers

Without this policy the cluster creation failed with permission errors.

---

# Step 3 – Install eksctl

Install the cluster management tool.

```
sudo yum install -y eksctl
```

Verify installation

```
eksctl version
```

---

# Step 4 – Create EKS Cluster

Create the cluster and worker node group.

```
eksctl create cluster \
--name ecs-app-cluster \
--region us-east-1 \
--nodegroup-name nodes \
--node-type t3.medium \
--nodes 2
```

This command automatically creates:

• EKS control plane
• Worker nodes
• VPC resources
• Security groups
• CloudFormation stack

---

# Step 5 – Configure kubectl Access

After cluster creation, configure kubectl.

```
aws eks update-kubeconfig \
--region us-east-1 \
--name ecs-app-cluster
```

Verify cluster connection

```
kubectl get nodes
```

Expected output

```
2 nodes Ready
```

---

# Step 6 – Create Kubernetes Deployment

Create the application deployment.

deployment.yaml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecs-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ecs-app
  template:
    metadata:
      labels:
        app: ecs-app
    spec:
      containers:
      - name: ecs-app
        image: 836763845852.dkr.ecr.us-east-1.amazonaws.com/ecs-app:latest
        ports:
        - containerPort: 5000
```

Deploy the application

```
kubectl apply -f deployment.yaml
```

---

# Step 7 – Create Kubernetes Service

Expose the deployment through a LoadBalancer.

service.yaml

```
apiVersion: v1
kind: Service
metadata:
  name: ecs-app-service
spec:
  type: LoadBalancer
  selector:
    app: ecs-app
  ports:
    - port: 80
      targetPort: 5000
```

Apply service

```
kubectl apply -f service.yaml
```

---

# Step 8 – Access Application

Check service details

```
kubectl get svc
```

The LoadBalancer DNS will appear.

Example

```
ecs-app-service-123456.us-east-1.elb.amazonaws.com
```

Access the application through the browser.

---

# Troubleshooting

## AccessDeniedException when creating cluster

Error

```
User is not authorized to perform: eks:DescribeClusterVersions
```

Cause

EC2 instance did not have proper IAM permissions.

Fix

Attach IAM role with required permissions to the EC2 instance.

---

## kubectl connection refused

Error

```
The connection to the server localhost:8080 was refused
```

Solution

Run

```
aws eks update-kubeconfig --region us-east-1 --name ecs-app-cluster
```

---

## Pods CrashLoopBackOff

Check logs

```
kubectl logs <pod-name>
```

Common causes

• Database connection failure
• Missing environment variables

---

## No Endpoints Found

Error

```
endpoints: none
```

Cause

Service selector does not match pod labels.

Ensure labels match.

---

# Result

The containerized application was successfully deployed on Amazon EKS using Kubernetes and exposed through a load balancer.
